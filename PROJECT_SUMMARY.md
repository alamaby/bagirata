# BagiStruk — Dokumentasi Teknis

Status: **End-to-end live** — capture → OCR (Flutter → Edge Function → LLM) → Review & Edit screen → persist ke `bills` + `items`. Auto anonymous sign-in saat startup; rate limit insert per user di level DB.

---

## 1. Arsitektur

### Diagram

```mermaid
flowchart TD
    subgraph Mobile["📱 Flutter App"]
        UI["ReceiptCaptureScreen\n(flutter_animate · lottie · screenutil)"]
        Notifier["OcrNotifier\n(Riverpod StateNotifier)"]
        OCRSvc["OCRService\n(downscale → base64)"]
        BillReview["BillReviewScreen\n(edit items · save)"]
    end

    subgraph Supabase["☁️ Supabase"]
        Auth["Auth\n(anonymous + email)"]
        EF["Edge Function\nprocess-receipt\n(Deno)"]
        PG["Postgres\nbills · items · participants\nassignments · profiles"]
        LlmCfg[("llm_configs\npriority · api_key\nbase_url · model_name")]
        LlmLog[("llm_logs\ntelemetry per attempt")]
    end

    subgraph LLM["🤖 LLM Providers"]
        Gemini["Gemini\n(Google AI)"]
        OR["OpenRouter\n(multi-model)"]
        NIM["NvidiaNIM\n(optional)"]
    end

    UI -->|"XFile[] → Uint8List[]"| Notifier
    Notifier -->|"process(images)"| OCRSvc
    OCRSvc -->|"POST /functions/v1/process-receipt\nimages: base64[]"| EF
    OCRSvc -->|"sign-in anon"| Auth

    EF -->|"SELECT is_active=true\nORDER BY priority"| LlmCfg
    EF -->|"INSERT fire-and-forget"| LlmLog

    EF -->|"priority 1\napi_key + model_name dari DB"| Gemini
    EF -->|"priority 2 (failover)"| OR
    EF -->|"priority 3 (failover)"| NIM

    Gemini -->|"OcrPayload JSON"| EF
    OR -->|"OcrPayload JSON"| EF
    NIM -->|"OcrPayload JSON"| EF

    EF -->|"items · confidence · provider_used"| OCRSvc
    OCRSvc -->|"OcrResult entity"| Notifier
    Notifier -->|"OcrSuccess → navigate"| BillReview
    BillReview -->|"createBill + upsertItems"| PG
    Auth -->|"RLS auth.uid()"| PG
```

### Prosa

```
presentation/  →  domain/  ←  data/
   │                            │
   └─ providers (Riverpod)  ────┘
   │                            │
   └────  Supabase Flutter SDK  ┘
                │
                ├── PostgREST (CRUD bills/items/participants/assignments)
                ├── Auth      (anonymous + email promotion)
                └── Functions (`process-receipt` Edge Function)
                       │
                       └─ supabase-js service-role
                            ├── SELECT llm_configs WHERE is_active=true ORDER BY priority
                            ├── INSERT llm_logs (telemetry per attempt)
                            └── fetch() ke Gemini / OpenRouter / NvidiaNIM
```

**Prinsip:**
- Semua API key LLM tinggal di tabel `llm_configs` (server-side). Tidak pernah ada di klien.
- Failover provider = baris berbeda dengan `priority` lebih tinggi. Mengganti provider / model / key tidak butuh redeploy.
- Telemetry ke `llm_logs` per percobaan (sukses + gagal) — fire-and-forget supaya tidak mem-block respon user.

---

## 2. Schema Database

`supabase/migrations/` — dijalankan dengan `supabase db push`.

### `20260427141418_init_bagistruk_schema.sql`
Tabel inti aplikasi:

| Tabel | Tujuan | Catatan |
|---|---|---|
| `profiles` | Profil user (extend `auth.users`), termasuk `bank_accounts` JSONB | Trigger `update_updated_at_column` aktif |
| `bills` | Header tagihan (title, total, tax, service, settled flag) | RLS: hanya `owner_id = auth.uid()` |
| `items` | Line item per bill (name, price, qty) | RLS via JOIN ke `bills.owner_id` |
| `participants` | Orang yang ikut bayar | RLS via JOIN ke `bills.owner_id` |
| `item_assignments` | M2M items ↔ participants dengan `share_weight` | Memungkinkan split tidak rata |
| `llm_configs` | Rotasi provider/key/model untuk Edge Function | RLS belum aktif di file ini — diperbaiki di migration 2 |
| `llm_logs` | Audit log setiap panggilan LLM | RLS belum aktif di file ini — diperbaiki di migration 2 |

### `20260428090000_qty_numeric_and_llm_rls.sql`
Follow-up migration:
- `items.qty INTEGER → NUMERIC(10,3)` — supaya item per-Kg/per-volume (mis. `qty=0.58`) bisa disimpan akurat. Sinkron dengan `Item.qty: double` di domain.
- `llm_configs` & `llm_logs` `ENABLE ROW LEVEL SECURITY`. **Tanpa policy** — sengaja, karena hanya service-role (Edge Function) yang berhak akses. Anon/authenticated key tidak boleh `SELECT api_key`.

### `20260428120000_bills_receipt_date.sql`
- `bills` tambah kolom `receipt_date DATE` (nullable) — tanggal yang tertera di struk hasil OCR. Berbeda dari `created_at` (waktu user input). NULL kalau tidak terdeteksi.

### `20260428130000_bills_insert_rate_limit.sql`
- Trigger `BEFORE INSERT` pada `bills` dengan limit **30/jam** dan **200/hari** per `owner_id`. Lampaui → `RAISE EXCEPTION` (P0001). `service_role` di-bypass untuk admin/seed.
- Index `(owner_id, created_at DESC)` supaya count-window cepat saat tabel besar.

---

## 3. Edge Function: `process-receipt`

[supabase/functions/process-receipt/index.ts](supabase/functions/process-receipt/index.ts) (Deno)

### Request / Response (wire)

```ts
// POST /functions/v1/process-receipt
// Body
{ images: string[],  // base64 JPEG, no `data:` prefix
  hint?: string }

// Response 200
{ items: [{ name, price, qty }],
  detected_total: number | null,
  detected_tax: number | null,
  detected_service: number | null,
  merchant: string | null,
  receipt_date: string | null,   // ISO 8601
  confidence: number,            // 0..1
  provider_used: string }        // nilai dari llm_configs.provider_name

// Response 4xx/5xx
{ error: 'invalid_json' | 'images_required' | 'method_not_allowed' |
         'no_active_provider' | 'llm_configs_load_failed' |
         'all_providers_failed' | 'supabase_env_missing',
  attempts?: [{ provider, status, message }] }  // saat all_providers_failed
```

### Lifecycle per request

1. **CORS preflight** — `OPTIONS` → 204.
2. **Validate body** — `images: string[]` non-empty, semua string. Else 400.
3. **Init service-role client** — `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (auto-injected oleh Supabase, tidak perlu set manual).
4. **Query `llm_configs`** — `is_active=true ORDER BY priority ASC`. Error / kosong → 500 `no_active_provider`.
5. **Loop failover** — untuk tiap row:
   - Dispatch ke `callProvider(cfg)` by `cfg.provider_name.toLowerCase()`:
     - `gemini` → Gemini REST native (`POST /v1beta/models/{model}:generateContent`).
     - `openrouter` → OpenAI-compatible (`POST {base_url}/chat/completions`).
     - `nvidianim` → placeholder `not_implemented`.
     - unknown → `ProviderError('unsupported_provider', 400)`.
   - `model_name` & `api_key` **selalu dari DB** — tidak ada default hardcoded.
   - **Fire-and-forget** INSERT ke `llm_logs` (image_count, model, latency_ms, status_code, error/summary).
   - Sukses → return 200.
   - Gagal **retryable** (`429 / 5xx / 408`) → lanjut row berikutnya.
   - Gagal **non-retryable** (4xx selain di atas) → break.
6. **No payload** → 502 `all_providers_failed` dengan array `attempts` berisi detail tiap provider yang dicoba.

### URL builder per provider

| Provider | `base_url` di DB | URL final yang dibangun |
|---|---|---|
| Gemini | `https://generativelanguage.googleapis.com` (host-only) | `…/v1beta/models/{model}:generateContent?key={api_key}` |
| Gemini | `https://generativelanguage.googleapis.com/v1beta` | `…/models/{model}:generateContent?key={api_key}` |
| OpenRouter | `https://openrouter.ai/api/v1` | `…/chat/completions` |
| OpenRouter | `https://openrouter.ai/api/v1/chat/completions` | dipakai apa adanya |

Builder bersifat defensive — menerima semua konvensi di atas tanpa double-append.

---

## 4. Pipeline Flutter

### End-to-end flow

```
ImagePicker.pickMultiImage()
   │  XFile[]
   ▼
[receipt_capture_screen.dart]
   │  - Empty state: ilustrasi placeholder + copy motivasional (fade-in)
   │  - Image preview: Card M3, border hijau accent (colorScheme.primary), radius 20
   │  - Tombol Scan: fade-in + slide-up via flutter_animate saat gambar tersedia
   │  - Overlay scanning: Lottie (assets/lottie/scanning.json) di dalam card area
   │  - Status text: shimmer saat processing (flutter_animate)
   │  - ref.listen(ocrProvider) → push BillReviewScreen saat OcrSuccess
   │
   ▼
[OcrNotifier].process(images, hint)             // presentation/ocr/providers/ocr_notifier.dart
   │  state: idle → processing(count) → success(OcrResult) | failure(Failure)
   ▼
[OcrRepositoryImpl] → [OCRService]              // downscale + invoke Edge Function
   │  ImageCodec.downscaleToBase64 (max 1600px, JPEG q85) — paralel
   │  supabaseClient.functions.invoke('process-receipt', body)
   ▼
Supabase Edge Function (Section 3)
   │  OcrResponseDto.fromJson() → OcrResult entity
   ▼
[bill_review_screen.dart]
   │  - Title prefilled dari ocr.merchant
   │  - Confidence chip kalau ocr.confidence < 0.8
   │  - Receipt date row kalau ocr.receiptDate != null (read-only)
   │  - Items list editable (name, qty: double, price)
   │  - Tax & Service: TextField numeric, prefilled dari detected_*
   │  - Mismatch banner kalau |computedTotal − detectedTotal| > 1.0
   │  - Save → IBillRepository.createBill + upsertItems
   ▼
Supabase PostgREST (tabel bills + items)
   │  Trigger BEFORE INSERT bills_insert_rate_limit (30/hr, 200/day) gate
   │  RLS: bills.owner_id = auth.uid()
```

### UI dependencies (scan screen)

| Package | Dipakai untuk |
|---|---|
| `flutter_animate` | fade-in/slide-up tombol Scan, shimmer status text, fade-in empty state |
| `lottie` | animasi scanning di atas gambar (path: `assets/lottie/scanning.json`) |
| `flutter_screenutil` | semua dimensi `.w/.h/.r/.sp` — baseline iPhone 12 (390×844) |

---

## 5. Konfigurasi LLM (`llm_configs`)

Setiap baris = satu opsi provider. Dipakai by priority asc. **`model_name` wajib diisi** — edge function tidak punya default.

```sql
INSERT INTO llm_configs(provider_name, api_key, base_url, model_name, priority, is_active) VALUES
-- Gemini sebagai primary (priority 1)
('gemini',     'AIza...',   'https://generativelanguage.googleapis.com', 'gemini-2.0-flash',          1, TRUE),
-- OpenRouter sebagai backup (priority 2)
('openrouter', 'sk-or-...', 'https://openrouter.ai/api/v1',             'google/gemini-2.0-flash-exp:free', 2, TRUE);
```

**Aturan operasional:**
- `is_active=false` → row dilewati tanpa perlu dihapus.
- `model_name` wajib eksplisit — jika NULL/empty, attempt dicatat ke `llm_logs` sebagai `config_invalid` lalu lanjut ke priority berikutnya.
- Rotasi key: `UPDATE llm_configs SET api_key='...' WHERE id=...`. Tidak perlu redeploy.
- Rotasi model: `UPDATE llm_configs SET model_name='...' WHERE id=...`. Berlaku di-request berikutnya.
- `base_url`:
  - Gemini: `https://generativelanguage.googleapis.com` (host-only) — edge function append `/v1beta/models/...` secara otomatis.
  - OpenRouter: `https://openrouter.ai/api/v1` (tanpa `/chat/completions`) — edge function append endpoint.

**Verifikasi model Gemini valid:**
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=$KEY" \
  | jq -r '.models[] | select(.supportedGenerationMethods[]? == "generateContent") | .name'
```

---

## 6. Telemetry (`llm_logs`)

Insert fire-and-forget per attempt (sukses & gagal):

```sql
-- Contoh row gagal
SELECT provider, status_code, latency_ms, response_payload
FROM llm_logs ORDER BY created_at DESC LIMIT 5;
```

- `bill_id NULL` saat OCR (scan terjadi sebelum bill dibuat).
- `request_payload` tidak menyimpan base64 — hanya `{ model, image_count, hint }`.
- `response_payload` saat sukses: `{ items_count, confidence }`. Saat gagal: `{ error: "..." }`.

**Query monitoring:**
```sql
-- Error rate per provider 24 jam terakhir
SELECT provider,
       COUNT(*) FILTER (WHERE status_code = 200) AS success,
       COUNT(*) FILTER (WHERE status_code <> 200) AS fail,
       AVG(latency_ms)::int AS avg_ms
FROM llm_logs
WHERE created_at > now() - interval '24 hours'
GROUP BY provider
ORDER BY provider;
```

---

## 7. Cara Menambah Provider Baru

### Provider OpenAI-compatible (Groq, Together, DeepSeek, dll)
Cukup INSERT baris baru — tidak perlu code change:
```sql
INSERT INTO llm_configs(provider_name, api_key, base_url, model_name, priority, is_active)
VALUES ('groq', 'gsk_...', 'https://api.groq.com/openai/v1', 'llama-3.3-70b-versatile', 3, TRUE);
```
Lalu tambah `case "groq": return await callOpenRouter(cfg, images, hint);` di dispatcher (atau buat fungsi shared `callOpenAICompatible`).

### Provider dengan wire format khas (Anthropic, dll)
1. Tambah `case "anthropic"` di dispatcher (`index.ts`).
2. Tulis fungsi `callAnthropic(cfg, images, hint)` dengan header `x-api-key` + `anthropic-version`.
3. INSERT baris ke `llm_configs`.
4. Deploy: `supabase functions deploy process-receipt`.

---

## 8. Auth & Multi-Device

- **Auto anonymous sign-in di startup** ([lib/main.dart](lib/main.dart)): setelah `Supabase.initialize()`, kalau `auth.currentUser == null` → `signInAnonymously()`. Wajib supaya RLS `auth.uid() = owner_id` lulus.
- **Anonymous sign-in harus di-enable** di Supabase Dashboard → Authentication → Providers.
- `AuthRemoteDataSource` mendukung **promote to email** — user anonim bisa daftar tanpa kehilangan bill (Supabase preserve `auth.uid()` saat linking).
- RLS di semua tabel filter by `auth.uid()` lewat `bills.owner_id`.

---

## 9. Smoke test (`smoketest.sh`)

```bash
./smoketest.sh                      # default photo_2026-04-28_08-41-22.jpg
./smoketest.sh path/to/other.jpg
```

Baca `SUPABASE_URL` + `SUPABASE_ANON_KEY` dari `.env`. Exit 0 hanya kalau HTTP 200.

---

## 10. Known Limitations & Next Steps

- **Captcha belum dipasang** — anonymous sign-in tanpa bot protection. Rate limit di `bills` adalah lapis defensif, bukan substitut.
- **`participants` tidak punya `user_id` kolom** — split bill saat ini owner-centric. Belum ada share-link ke participant.
- **Bill detail / edit ulang** — setelah save, belum ada screen untuk edit bill yang sudah tersimpan.
- **Lottie asset** di `assets/lottie/scanning.json` masih placeholder — ganti dengan animasi final sebelum rilis.
- **Edge Function tidak rate-limit di sisi sendiri** — bergantung Supabase project quota. Pertimbangkan kolom `cooldown_until` di `llm_configs` untuk circuit breaker.
- **`llm_logs` audit mingguan** belum otomatis — bisa di-`/schedule` jadi cron agent.

---

## Lampiran: File-File Penting

| Path | Peran |
|---|---|
| [lib/main.dart](lib/main.dart) | Entry point, dotenv load, Supabase init, auto anonymous sign-in |
| [lib/core/config/env.dart](lib/core/config/env.dart) | Typed accessor `Env.supabaseUrl`, dst |
| [lib/core/config/app_constants.dart](lib/core/config/app_constants.dart) | `ocrLowConfidenceThreshold`, `billTotalMismatchTolerance`, `ocrMaxImageEdgePx`, dll |
| [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) | Material 3, seed color `Color(0xFF2E7D5B)` (receipt-paper green) |
| [lib/core/router/app_router.dart](lib/core/router/app_router.dart) | go_router: list → capture → review |
| [lib/data/services/ocr_service.dart](lib/data/services/ocr_service.dart) | Klien Edge Function (downscale + invoke) |
| [lib/presentation/ocr/screens/receipt_capture_screen.dart](lib/presentation/ocr/screens/receipt_capture_screen.dart) | Capture UI: empty state, card preview, Lottie overlay, shimmer, animasi tombol |
| [lib/presentation/ocr/widgets/receipt_preview_component.dart](lib/presentation/ocr/widgets/receipt_preview_component.dart) | Card gambar M3 (border hijau, radius 20), floating remove button |
| [lib/presentation/ocr/providers/ocr_notifier.dart](lib/presentation/ocr/providers/ocr_notifier.dart) | State machine OCR (idle/processing/success/failure) |
| [lib/presentation/bills/screens/bill_review_screen.dart](lib/presentation/bills/screens/bill_review_screen.dart) | Form review/edit + save bill |
| [lib/domain/services/bill_calculator.dart](lib/domain/services/bill_calculator.dart) | Pure logic distribusi tax/service per participant |
| [supabase/functions/process-receipt/index.ts](supabase/functions/process-receipt/index.ts) | Edge Function: DB-driven provider rotation + telemetry |
| [supabase/migrations/](supabase/migrations/) | Postgres schema + RLS + rate limit trigger |
| [assets/lottie/scanning.json](assets/lottie/scanning.json) | Animasi scanning (ganti dengan Lottie final sebelum rilis) |
| [.env.example](.env.example) | Template env client (anon key only) |
| [smoketest.sh](smoketest.sh) | Test E2E Edge Function dari CLI |
