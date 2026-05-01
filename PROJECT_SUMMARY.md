# BagiStruk — Technical Documentation

**Status: End-to-end live** — capture → OCR (Flutter → Edge Function → LLM) → Review & Edit → Split → **Settlement** (per-participant `is_paid` toggle, auto `bills.is_settled`). Lazy anonymous sign-in (only when an action needs `auth.uid()`) so persisted email sessions survive restart. Per-user insert rate limit enforced at the database level.

---

## 1. Architecture

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

    EF -->|"priority 1\napi_key + model_name from DB"| Gemini
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

### Layer Overview

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
                            └── fetch() → Gemini / OpenRouter / NvidiaNIM
```

**Design principles:**
- All LLM API keys live in `llm_configs` (server-side only). Never bundled in the client.
- Provider failover = rows with increasing `priority`. Swapping a provider, model, or key requires no redeploy.
- `llm_logs` records every attempt (success and failure) fire-and-forget so it never blocks the user response.

---

## 2. Database Schema

Migrations are in `supabase/migrations/` and applied with `supabase db push`.

### `20260427141418_init_bagistruk_schema.sql`

Core application tables:

| Table | Purpose | Notes |
|---|---|---|
| `profiles` | User profile extending `auth.users`, includes `bank_accounts` JSONB | `update_updated_at_column` trigger active |
| `bills` | Bill header (title, total, tax, service, settled flag) | RLS: `owner_id = auth.uid()` only |
| `items` | Line items per bill (name, price, qty) | RLS via JOIN to `bills.owner_id` |
| `participants` | People sharing the bill | RLS via JOIN to `bills.owner_id` |
| `item_assignments` | M2M items ↔ participants with `share_weight` | Enables unequal splits |
| `llm_configs` | Provider/key/model rotation for the Edge Function | RLS added in migration 2 |
| `llm_logs` | Audit log of every LLM call | RLS added in migration 2 |

### `20260428090000_qty_numeric_and_llm_rls.sql`

- `items.qty INTEGER → NUMERIC(10,3)` — supports fractional quantities (e.g. `qty=0.58` kg). Matches `Item.qty: double` in the domain layer.
- `llm_configs` and `llm_logs` get `ENABLE ROW LEVEL SECURITY` with **no policies** — intentional, so only the service-role key (Edge Function) can read `api_key`. The anon/authenticated key cannot.

### `20260428120000_bills_receipt_date.sql`

- Adds nullable `receipt_date DATE` to `bills` — the date printed on the receipt as extracted by OCR, separate from `created_at` (the time the user saved).

### `20260428130000_bills_insert_rate_limit.sql`

- `BEFORE INSERT` trigger on `bills`: hard limit of **30/hour** and **200/day** per `owner_id`. Exceeding the limit raises a `P0001` exception.
- `service_role` bypasses the limit (for admin/seed operations).
- Index on `(owner_id, created_at DESC)` keeps the count-window query fast as the table grows.

---

## 3. Edge Function: `process-receipt`

Source: [supabase/functions/process-receipt/index.ts](supabase/functions/process-receipt/index.ts) (Deno)

### Wire Format

```ts
// POST /functions/v1/process-receipt
// Request body
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
  provider_used: string }        // matches llm_configs.provider_name

// Response 4xx/5xx
{ error: 'invalid_json' | 'images_required' | 'method_not_allowed' |
         'no_active_provider' | 'llm_configs_load_failed' |
         'all_providers_failed' | 'supabase_env_missing',
  attempts?: [{ provider, status, message }] }  // present on all_providers_failed
```

### Request Lifecycle

1. **CORS preflight** — `OPTIONS` → 204.
2. **Validate body** — `images: string[]` must be non-empty with all string values. Otherwise 400.
3. **Init service-role client** — uses `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (auto-injected by Supabase, no manual setup).
4. **Query `llm_configs`** — `is_active=true ORDER BY priority ASC`. Error or empty result → 500 `no_active_provider`.
5. **Failover loop** — for each row:
   - Dispatches to `callProvider(cfg)` by `cfg.provider_name.toLowerCase()`:
     - `gemini` → Gemini REST (`POST /v1beta/models/{model}:generateContent`)
     - `openrouter` → OpenAI-compatible (`POST {base_url}/chat/completions`)
     - `nvidianim` → placeholder `not_implemented`
     - unknown → `ProviderError('unsupported_provider', 400)`
   - `model_name` and `api_key` always come from the DB row — no hardcoded defaults.
   - Fire-and-forget INSERT to `llm_logs` (image_count, model, latency_ms, status_code, error/summary).
   - Success → return 200 immediately.
   - Retryable failure (`429 / 5xx / 408`) → continue to next row.
   - Non-retryable failure (other 4xx) → break loop.
6. **No successful payload** → 502 `all_providers_failed` with `attempts` array detailing each tried provider.

### URL Builder Per Provider

| Provider | `base_url` in DB | Final URL constructed |
|---|---|---|
| Gemini | `https://generativelanguage.googleapis.com` (host only) | `…/v1beta/models/{model}:generateContent?key={api_key}` |
| Gemini | `https://generativelanguage.googleapis.com/v1beta` | `…/models/{model}:generateContent?key={api_key}` |
| OpenRouter | `https://openrouter.ai/api/v1` | `…/chat/completions` |
| OpenRouter | `https://openrouter.ai/api/v1/chat/completions` | used as-is |

The builder is defensive — all conventions above are handled without double-appending path segments.

---

## 4. Flutter Pipeline

### End-to-End Flow

```
ImagePicker.pickMultiImage()
   │  XFile[]
   ▼
[receipt_capture_screen.dart]
   │  - Empty state: placeholder illustration + motivational copy (fade-in)
   │  - Image preview: M3 Card, green accent border (colorScheme.primary), radius 20
   │  - Scan button: fade-in + slide-up via flutter_animate when images are ready
   │  - Scanning overlay: Lottie (assets/lottie/scanning.json) inside the card area
   │  - Status text: shimmer while processing (flutter_animate)
   │  - ref.listen(ocrProvider) → push BillReviewScreen on OcrSuccess
   │
   ▼
[OcrNotifier].process(images, hint)             // presentation/ocr/providers/ocr_notifier.dart
   │  state: idle → processing(count) → success(OcrResult) | failure(Failure)
   ▼
[OcrRepositoryImpl] → [OCRService]              // downscale + invoke Edge Function
   │  ImageCodec.downscaleToBase64 (max 1600px, JPEG q85) — runs in parallel
   │  supabaseClient.functions.invoke('process-receipt', body)
   ▼
Supabase Edge Function (Section 3)
   │  OcrResponseDto.fromJson() → OcrResult entity
   ▼
[bill_review_screen.dart]
   │  - Title pre-filled from ocr.merchant
   │  - Confidence chip shown when ocr.confidence < 0.8
   │  - Receipt date row shown when ocr.receiptDate != null (read-only)
   │  - Editable items list (name, qty: double, price)
   │  - Tax & Service: numeric TextFields, pre-filled from detected_*
   │  - Mismatch banner when |computedTotal − detectedTotal| > 1.0
   │  - Save → IBillRepository.createBill + upsertItems
   ▼
Supabase PostgREST (tables: bills + items)
   │  BEFORE INSERT trigger: bills_insert_rate_limit (30/hr, 200/day)
   │  RLS: bills.owner_id = auth.uid()
   ▼
[bill_split_screen.dart]
   │  - Add participants, assign items per person (avatar tap → item tap)
   │  - Per-toggle persist via replaceAssignments
   │  - "Selesai" → pushReplacement to bill detail screen
   ▼
[bill_detail_screen.dart]                         // settlement loop
   │  - Header: merchant + receipt date (longDate id_ID) + total + settled badge
   │  - Per-participant Switch toggles `participants.is_paid` (optimistic UI)
   │  - On full settlement: auto-flip `bills.is_settled = true`
   │  - Reverse-flip when any participant un-toggled
```

### UI Package Roles (Scan Screen)

| Package | Used for |
|---|---|
| `flutter_animate` | fade-in/slide-up of the Scan button, shimmer on status text, fade-in empty state |
| `lottie` | scanning animation overlaid on the image card (`assets/lottie/scanning.json`) |
| `flutter_screenutil` | all dimensions via `.w/.h/.r/.sp` — baseline iPhone 12 (390×844) |

---

## 5. LLM Configuration (`llm_configs`)

Each row is one provider option, consumed in ascending `priority` order. **`model_name` is required** — the Edge Function has no fallback default.

```sql
INSERT INTO llm_configs(provider_name, api_key, base_url, model_name, priority, is_active) VALUES
-- Gemini as primary (priority 1)
('gemini',     'AIza...',   'https://generativelanguage.googleapis.com', 'gemini-2.0-flash',                1, TRUE),
-- OpenRouter as fallback (priority 2)
('openrouter', 'sk-or-...', 'https://openrouter.ai/api/v1',             'google/gemini-2.0-flash-exp:free', 2, TRUE);
```

**Operational rules:**
- `is_active=false` — row is skipped without deletion.
- `model_name` must be explicit. If NULL or empty, the attempt is logged to `llm_logs` as `config_invalid` and the loop continues.
- Key rotation: `UPDATE llm_configs SET api_key='...' WHERE id=...` — no redeploy needed.
- Model rotation: `UPDATE llm_configs SET model_name='...' WHERE id=...` — takes effect on the next request.
- `base_url` conventions:
  - Gemini: `https://generativelanguage.googleapis.com` (host only) — the Edge Function appends `/v1beta/models/...`.
  - OpenRouter: `https://openrouter.ai/api/v1` (no `/chat/completions`) — the Edge Function appends the endpoint.

**Verify valid Gemini models:**
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=$KEY" \
  | jq -r '.models[] | select(.supportedGenerationMethods[]? == "generateContent") | .name'
```

---

## 6. Telemetry (`llm_logs`)

Fire-and-forget insert per attempt (success and failure):

```sql
-- Sample: inspect recent calls
SELECT provider, status_code, latency_ms, response_payload
FROM llm_logs ORDER BY created_at DESC LIMIT 5;
```

- `bill_id` is NULL during OCR (a bill doesn't exist yet when scanning occurs).
- `request_payload` does not store base64 — only `{ model, image_count, hint }`.
- `response_payload` on success: `{ items_count, confidence }`. On failure: `{ error: "..." }`.

**Monitoring query:**
```sql
-- Error rate per provider over the last 24 hours
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

## 7. Adding a New LLM Provider

### OpenAI-compatible providers (Groq, Together, DeepSeek, etc.)

Insert a new row — no code change required:
```sql
INSERT INTO llm_configs(provider_name, api_key, base_url, model_name, priority, is_active)
VALUES ('groq', 'gsk_...', 'https://api.groq.com/openai/v1', 'llama-3.3-70b-versatile', 3, TRUE);
```
Then add `case "groq": return await callOpenRouter(cfg, images, hint);` in the dispatcher (or refactor into a shared `callOpenAICompatible` helper).

### Providers with a custom wire format (Anthropic, etc.)

1. Add `case "anthropic"` in the dispatcher (`index.ts`).
2. Write `callAnthropic(cfg, images, hint)` with `x-api-key` and `anthropic-version` headers.
3. Insert a row into `llm_configs`.
4. Deploy: `supabase functions deploy process-receipt`.

---

## 8. Auth & Multi-Device

- **Lazy anonymous sign-in.** [lib/main.dart](lib/main.dart) no longer calls `signInAnonymously()` at startup — that previously raced with `Supabase.initialize()`'s session restoration and overwrote a freshly-restored email session. Instead, [`IAuthRepository.ensureSignedIn()`](lib/data/datasources/auth_remote_datasource.dart) is called from action sites that require `auth.uid()` (currently the OCR `_process()` in [receipt_capture_screen.dart](lib/presentation/ocr/screens/receipt_capture_screen.dart)). It's idempotent: returns the existing user id when a session already exists, anonymous-signs-in only when there is none.
- **Session persistence is automatic** — `supabase_flutter` uses Hive/SharedPreferences locally, so previously-signed-in users (anonymous or email) stay signed-in across cold starts.
- **Anonymous sign-in must be enabled** in the Supabase Dashboard → Authentication → Providers, otherwise `ensureSignedIn()` fails when there is no session.
- `AuthRemoteDataSource` supports **promote to email** — an anonymous user can register without losing their bills (Supabase preserves `auth.uid()` when linking the identity). Logging into an existing account from an anonymous session calls the `migrate_anon_data` RPC to re-assign rows to the new uid.
- RLS on all tables filters by `auth.uid()` via `bills.owner_id`.

---

## 9. Smoke Test (`smoketest.sh`)

```bash
./smoketest.sh                      # uses default photo_2026-04-28_08-41-22.jpg
./smoketest.sh path/to/other.jpg
```

Reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `.env`. Exit 0 only on HTTP 200.

---

## 10. Known Limitations & Next Steps

- **No CAPTCHA** — anonymous sign-in has no bot protection. The `bills` rate limit is a defensive layer, not a substitute.
- **`participants` has no `user_id` column** — bill splitting is currently owner-centric. There is no share link to send a participant their portion.
- **No bill edit screen for items/totals** — the bill detail screen (settlement) lets the owner toggle payment status and auto-flip `is_settled`, but there's no UI to reopen and re-edit the items, tax, service, or merchant of a saved bill.
- **Lottie asset** at `assets/lottie/scanning.json` is still a placeholder — replace with the final animation before release.
- **Edge Function has no self-rate-limit** — relies on the Supabase project quota. Consider a `cooldown_until` column in `llm_configs` for a circuit-breaker pattern.
- **Weekly `llm_logs` audit** is not automated — a candidate for a scheduled agent.

---

## Appendix: Key Files

| Path | Role |
|---|---|
| [lib/main.dart](lib/main.dart) | Entry point: dotenv load, Supabase init (no eager anon — session restored from local storage; lazy anon via `ensureSignedIn`) |
| [lib/core/config/env.dart](lib/core/config/env.dart) | Typed accessors: `Env.supabaseUrl`, etc. |
| [lib/core/config/app_constants.dart](lib/core/config/app_constants.dart) | `ocrLowConfidenceThreshold`, `billTotalMismatchTolerance`, `ocrMaxImageEdgePx`, etc. |
| [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) | Material 3, seed color `Color(0xFF2E7D5B)` (receipt-paper green) |
| [lib/core/router/app_router.dart](lib/core/router/app_router.dart) | go_router routes: list → capture → review |
| [lib/data/services/ocr_service.dart](lib/data/services/ocr_service.dart) | Edge Function client (downscale + invoke) |
| [lib/presentation/ocr/screens/receipt_capture_screen.dart](lib/presentation/ocr/screens/receipt_capture_screen.dart) | Capture UI: empty state, card preview, Lottie overlay, shimmer, button animation |
| [lib/presentation/ocr/widgets/receipt_preview_component.dart](lib/presentation/ocr/widgets/receipt_preview_component.dart) | M3 image card (green border, radius 20), floating remove button |
| [lib/presentation/ocr/providers/ocr_notifier.dart](lib/presentation/ocr/providers/ocr_notifier.dart) | OCR state machine (idle / processing / success / failure) |
| [lib/presentation/bills/screens/bill_review_screen.dart](lib/presentation/bills/screens/bill_review_screen.dart) | Review/edit form + save bill |
| [lib/presentation/bills/screens/bill_split_screen.dart](lib/presentation/bills/screens/bill_split_screen.dart) | Item-to-participant assignment with avatar selection + animated stack |
| [lib/presentation/bills/providers/split_notifier.dart](lib/presentation/bills/providers/split_notifier.dart) | Split state machine; `replaceAssignments` per toggle, proportional totals |
| [lib/presentation/bills/screens/bill_detail_screen.dart](lib/presentation/bills/screens/bill_detail_screen.dart) | Settlement loop: per-participant payment toggle + auto-settle bill |
| [lib/presentation/bills/providers/bill_detail_notifier.dart](lib/presentation/bills/providers/bill_detail_notifier.dart) | `toggleParticipantPaymentStatus` with optimistic UI + auto-settle evaluation |
| [lib/domain/services/bill_calculator.dart](lib/domain/services/bill_calculator.dart) | Pure logic for distributing tax/service per participant |
| [supabase/functions/process-receipt/index.ts](supabase/functions/process-receipt/index.ts) | Edge Function: DB-driven provider rotation + telemetry |
| [supabase/migrations/](supabase/migrations/) | Postgres schema, RLS, and rate-limit trigger |
| [assets/lottie/scanning.json](assets/lottie/scanning.json) | Scanning animation (replace with final Lottie before release) |
| [.env.example](.env.example) | Client env template (anon key only) |
| [smoketest.sh](smoketest.sh) | CLI E2E test for the Edge Function |
