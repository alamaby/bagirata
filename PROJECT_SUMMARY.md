# BagiStruk — Dokumentasi Teknis

Status: **End-to-end live** — capture → OCR (Flutter → Edge Function → LLM) → Review & Edit screen → persist ke `bills` + `items`. Auto anonymous sign-in saat startup; rate limit insert per user di level DB.

---

## 1. Arsitektur

Clean Architecture tiga lapis dengan Riverpod sebagai DI seam:

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
- Lapis pertahanan terhadap abuse anonymous sign-in (anti-bloat MAU). Bukan pengganti captcha — captcha mencegah pembuatan akun bot, rate limit mencegah satu akun dispamming.

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
  provider_used: string }        // "Gemini" | "OpenRouter" | "NvidiaNIM"

// Response 4xx/5xx
{ error: 'invalid_json' | 'images_required' | 'method_not_allowed' |
         'no_provider_configured' | 'llm_configs_query_failed' |
         'all_providers_failed' | 'unknown_provider',
  detail?: string }
```

### Lifecycle per request

1. **CORS preflight** — `OPTIONS` → 204.
2. **Validate body** — `images: string[]` non-empty, semua string. Else 400.
3. **Query `llm_configs`** — `is_active=true ORDER BY priority ASC`. Tabel kosong / error → 500 `no_provider_configured` (fail keras, by design).
4. **Loop failover** — untuk tiap row:
   - `t0 = performance.now()`.
   - `dispatch(cfg)` switch by `provider_name.toLowerCase()`:
     - `gemini` → `callGemini(api_key, model_name ?? 'gemini-2.5-flash')` — Google REST API native.
     - `openrouter` → `callOpenAICompatible(base_url ?? 'https://openrouter.ai/api/v1', api_key, model_name ?? 'google/gemini-2.5-flash')`.
     - `nvidianim` → `callOpenAICompatible(base_url ?? 'https://integrate.api.nvidia.com/v1', api_key, model_name ?? 'meta/llama-3.2-90b-vision-instruct')`.
     - default → `ProviderError('unknown provider', 400)`.
   - **Fire-and-forget** insert ke `llm_logs` (image_count, hint, response/error, latency, status_code).
   - Sukses → break loop.
   - Gagal **retryable** (`429 / 5xx / 408`) → lanjut row berikutnya.
   - Gagal **non-retryable** (4xx selain di atas, schema mismatch) → break dengan error.
5. **No payload** → 502 `all_providers_failed` dengan `detail` dari error terakhir.
6. **Sukses** → 200 dengan `provider_used` = `cfg.provider_name` (case as-stored).

### Provider client

- **Gemini** ([callGemini](supabase/functions/process-receipt/index.ts:96-128)): `POST /v1beta/models/${model}:generateContent` dengan `inline_data` per gambar. `generationConfig.responseMimeType = "application/json"`. Timeout 20s.
- **OpenAI-compatible** ([callOpenAICompatible](supabase/functions/process-receipt/index.ts:130-167)): `POST ${baseUrl}/chat/completions` dengan `messages[].content[]` array (text + `image_url` data URI). `response_format: { type: "json_object" }`. Timeout 25s. Bekerja apa adanya untuk OpenRouter, NvidiaNIM, dan provider OpenAI-compat lainnya.

### System prompt

Single fixed prompt ([SYSTEM_PROMPT](supabase/functions/process-receipt/index.ts:24-44)) yang menginstruksi LLM mengeluarkan JSON ketat:
```
{ "items":[{"name","price","qty"}], "detected_total"|null, "detected_tax"|null,
  "detected_service"|null, "merchant"|null, "receipt_date"|null /* ISO 8601 */,
  "confidence" }
```
Aturan eksplisit: gabung duplikat by name (sum qty), `price` per-unit, qty boleh pecahan untuk barang berat/volume, multi-foto = potongan dari struk yang sama (di-merge), currency apa adanya tanpa konversi.

### Schema validation

`isOcrPayload()` ([index.ts:69-83](supabase/functions/process-receipt/index.ts:69-83)) — type-guard runtime sebelum response dikirim balik ke klien. LLM yang melanggar shape → `ProviderError('schema mismatch', 422)` → mungkin trigger failover ke provider berikutnya.

---

## 4. Pipeline Flutter

### End-to-end flow

```
ImagePicker.pickMultiImage()
   │  XFile[]
   ▼
[receipt_capture_screen.dart]
   │  - tombol Scan: _starting flag flip sinkron → button langsung disabled+spinner
   │  - overlay full-screen "AI sedang membaca struk…" selama processing
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
SupabaseClient.functions.invoke()  →  Edge Function (section 3)
   │  OcrResponseDto.fromJson() → OcrResult entity
   ▼
[bill_review_screen.dart]                       // presentation/bills/screens/
   │  - Title prefilled dari ocr.merchant
   │  - Confidence chip kalau ocr.confidence < 0.8
   │  - Receipt date row kalau ocr.receiptDate != null (read-only)
   │  - Items list editable (name, qty: double, price)
   │  - Subtotal recompute realtime
   │  - Tax & Service: TextField numeric, prefilled dari detected_*, hint manual entry kalau null
   │  - Mismatch banner kalau |computedTotal − detectedTotal| > 1.0
   │  - Save → IBillRepository.createBill + upsertItems
   ▼
Supabase PostgREST (tabel bills + items)
   │  Trigger BEFORE INSERT bills_insert_rate_limit (30/hr, 200/day) gate
   │  RLS: bills.owner_id = auth.uid()
```

### Type stack

| Layer | OCR types |
|---|---|
| domain/entities | `OcrLineItem(name, price, qty: double)`, `OcrResult(items, detectedTotal, detectedTax, detectedService, merchant, receiptDate, confidence, providerUsed)`, `Bill(..., receiptDate?: DateTime, createdAt: DateTime)`, `Item(..., qty: double)` |
| data/dtos | `OcrLineItemDto`, `OcrRequestDto`, `OcrResponseDto` (freezed + json_serializable, `field_rename: snake`); `BillDto` map ke `tax_amount` / `service_charge` / `receipt_date` lewat `@JsonKey`; `ItemDto.qty: double` |
| data/services | `OCRService` — single responsibility client untuk Edge Function |
| data/repositories | `OcrRepositoryImpl`, `BillRepositoryImpl` — `Result<T, Failure>` translation |
| presentation | `OcrNotifier` (StateNotifier), `OcrState` sealed (idle/processing/success/failure); `BillReviewScreen` ConsumerStatefulWidget (form editable + save) |

### Error handling

- **`Failure`** sealed class di `core/error/failure.dart`: `NetworkFailure`, `ServerFailure`, `ParsingFailure`, `AuthFailure`, `UnknownFailure`.
- **`guardAsync()`** di `core/error/exception_mapper.dart` membungkus call ke datasource/service — translate exception framework (PostgrestException, AuthException, FormatException, dll) ke `Failure` variant.
- **`Result<T>`** discriminated union — pattern matching exhaustive di UI layer.

---

## 5. Konfigurasi LLM (`llm_configs`)

Setiap baris = satu opsi provider. Dipakai by priority asc.

```sql
INSERT INTO llm_configs(provider_name, api_key, base_url, model_name, priority, is_active) VALUES
-- Gemini sebagai primary (priority 1)
('Gemini',    'AIza...',          NULL,                                'gemini-2.5-flash',                1, TRUE),
-- OpenRouter sebagai backup (priority 2)
('OpenRouter','sk-or-...',        NULL,                                'google/gemini-2.5-flash',         2, TRUE),
-- NvidiaNIM sebagai second backup (priority 3)
('NvidiaNIM', 'nvapi-...',        'https://integrate.api.nvidia.com/v1', 'meta/llama-3.2-90b-vision-instruct', 3, TRUE);
```

**Aturan operasional:**
- `is_active=false` → row dilewati.
- Kosongkan `base_url` untuk pakai default (lihat dispatcher di Section 3).
- Kosongkan `model_name` hanya kalau Anda yakin default Edge Function masih hidup. Lebih aman selalu eksplisit.
- Untuk rotasi key: cukup `UPDATE llm_configs SET api_key='...' WHERE id=...`. Tidak perlu redeploy / restart.

**Verifikasi model valid sebelum INSERT:**
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=$KEY" \
  | jq -r '.models[] | select(.supportedGenerationMethods[]? == "generateContent") | .name'
```

---

## 6. Telemetry (`llm_logs`)

Insert fire-and-forget per percobaan provider:

```sql
INSERT INTO llm_logs(bill_id, provider, request_payload, response_payload, latency_ms, status_code) VALUES
(NULL, 'Gemini', '{"image_count":1,"hint":null}', '<full payload OR {"error":"..."}>', 1234, 200);
```

- `bill_id NULL` saat OCR (scan terjadi sebelum bill dibuat). Future: link saat user save bill.
- `request_payload` **tidak menyimpan base64** — terlalu besar dan tidak ada nilai diagnostik. Hanya `{ image_count, hint }`.
- `status_code = 200` kalau sukses, else status dari `ProviderError` (atau 502 untuk error tak terduga).

**Query monitoring umum:**
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

## 7. Smoke test (`smoketest.sh`)

Bash script untuk verifikasi pipeline tanpa membuka app.

- Baca `SUPABASE_URL` + `SUPABASE_ANON_KEY` dari `.env.local` (atau `.env`).
- Tahan **CRLF** (file di-edit di Windows), tanda kutip, dan whitespace.
- Validasi bentuk JWT sebelum POST (catch corruption awal).
- Build payload `{"images":[<b64>]}` murni shell (base64 alphabet aman tanpa escape JSON, tidak butuh Python/jq).
- Print HTTP code + response body (pretty via `jq` kalau ada).
- Exit 0 hanya kalau HTTP 200.

Pakai:
```bash
./smoketest.sh                      # default photo_2026-04-28_08-41-22.jpg
./smoketest.sh path/to/other.jpg
```

---

## 8. Auth & Multi-Device

- **Auto anonymous sign-in di startup** ([lib/main.dart](lib/main.dart)): setelah `Supabase.initialize()`, kalau `auth.currentUser == null` → `signInAnonymously()`. Wajib supaya RLS `auth.uid() = owner_id` lulus. Tanpa ini insert ke `bills` ditolak dengan error 42501.
- **Anonymous sign-in harus di-enable** di Supabase Dashboard → Authentication → Providers. Tanpa enable, sign-in di startup gagal dan app tidak bisa save bill.
- Captcha untuk anonymous sign-in **tidak diaktifkan saat ini** (development phase). Lapis pertahanan: rate-limit trigger di tabel `bills` (lihat migrasi `20260428130000`). Sebelum public release rekomendasi: enable hCaptcha/Turnstile di Supabase, atau migrate ke Google sign-in (lebih aman jangka panjang karena bill perlu identitas stabil).
- `AuthRemoteDataSource` mendukung **promote to email** (`updateUser({ email })`) — supaya user yang awalnya anonim bisa daftar tanpa kehilangan bill (Supabase preserve `auth.uid()` saat linking).
- RLS di `bills`/`items`/`participants`/`item_assignments` semua filter by `auth.uid()` lewat `bills.owner_id`. Anonymous user dapat UID stabil yang persist di device sampai logout/clear-data.

---

## 9. Cara Menambah Provider Baru

Misal mau tambah Anthropic Claude:

1. **Tambah branch di dispatcher** ([index.ts:170-194](supabase/functions/process-receipt/index.ts:170-194)):
   ```ts
   case "anthropic": {
     const baseUrl = cfg.base_url ?? "https://api.anthropic.com/v1";
     const model = cfg.model_name ?? "claude-haiku-4-5";
     return await callAnthropic(baseUrl, cfg.api_key, model, images, hint);
   }
   ```
   Anthropic punya wire format khas (header `x-api-key` + `anthropic-version`, struktur `messages[].content[].source.data` untuk image base64), jadi butuh fungsi `callAnthropic` baru — bukan `callOpenAICompatible`.
2. **Insert baris**: `INSERT INTO llm_configs(provider_name, api_key, model_name, priority) VALUES ('Anthropic', '...', 'claude-haiku-4-5', 4);`
3. **Deploy**: `supabase functions deploy process-receipt`.

Kalau provider baru sudah OpenAI-compatible (misal Groq, Together, DeepSeek): cukup `INSERT` dengan `base_url` provider tersebut — tidak perlu code change.

---

## 10. Known Limitations & Next Steps

- **Captcha belum dipasang** — anonymous sign-in tanpa bot protection. Rate limit di `bills` adalah lapis defensif, bukan substitut. Sebelum public release: enable hCaptcha/Turnstile atau migrate ke Google sign-in.
- **`bills.owner_id DEFAULT auth.uid()`** — bagus untuk anonymous flow, tapi belum ada path untuk berbagi bill ke participant lain (mereka belum punya akses RLS).
- **`participants` tidak punya `user_id` kolom** — split bill saat ini owner-centric. Belum ada notifikasi/share-link.
- **Bill detail / edit ulang** — setelah save, belum ada screen untuk edit bill yang sudah tersimpan. Bill list hanya read-only `Card`.
- **Bill review tidak bisa balik ke capture screen** — `context.goNamed(Routes.billListName)` setelah save lompat langsung ke list. User yang batal review harus tap back-arrow manual; data scan tidak diingat.
- **`smoketest.sh`** menyimpan response ke `/tmp/sr_response.json` — Windows Git Bash mengarahkan ke path Cygwin-style; bisa di-improve pakai `mktemp`.
- **Edge Function tidak rate-limit di sisi sendiri** — bergantung pada Supabase project quota. Untuk produksi pertimbangkan circuit breaker / cooldown di tabel `llm_configs` (mis. kolom `cooldown_until`).
- **Cleanup task** — automation untuk audit `llm_logs` mingguan (error rate spike, key rotation reminder) belum dipasang. Bisa di-`/schedule` jadi cron agent.

---

## Lampiran: File-File Penting

| Path | Peran |
|---|---|
| [lib/main.dart](lib/main.dart) | Entry point, dotenv load, Supabase init, **auto anonymous sign-in** |
| [lib/core/config/env.dart](lib/core/config/env.dart) | Typed accessor `Env.supabaseUrl`, dst |
| [lib/core/config/app_constants.dart](lib/core/config/app_constants.dart) | `ocrLowConfidenceThreshold`, `billTotalMismatchTolerance`, `ocrMaxImageEdgePx`, dll |
| [lib/core/network/supabase_client_provider.dart](lib/core/network/supabase_client_provider.dart) | Riverpod provider untuk SupabaseClient |
| [lib/core/router/app_router.dart](lib/core/router/app_router.dart) | go_router config: list, capture, **review** |
| [lib/data/services/ocr_service.dart](lib/data/services/ocr_service.dart) | Klien Edge Function (downscale + invoke) |
| [lib/data/dtos/bill_dto.dart](lib/data/dtos/bill_dto.dart) | Mapping ke kolom DB (`tax_amount`, `service_charge`, `receipt_date`) |
| [lib/presentation/ocr/screens/receipt_capture_screen.dart](lib/presentation/ocr/screens/receipt_capture_screen.dart) | Capture + scanning overlay + auto-navigate ke review |
| [lib/presentation/ocr/providers/ocr_notifier.dart](lib/presentation/ocr/providers/ocr_notifier.dart) | State machine OCR |
| [lib/presentation/bills/screens/bill_review_screen.dart](lib/presentation/bills/screens/bill_review_screen.dart) | **Form review/edit + save bill** |
| [lib/domain/services/bill_calculator.dart](lib/domain/services/bill_calculator.dart) | Pure logic distribusi tax/service per participant |
| [supabase/functions/process-receipt/index.ts](supabase/functions/process-receipt/index.ts) | Edge Function utama |
| [supabase/migrations/](supabase/migrations/) | Postgres schema + RLS + rate limit trigger |
| [.env.example](.env.example) | Template env client (anon key only) |
| [smoketest.sh](smoketest.sh) | Test E2E Edge Function dari CLI |
