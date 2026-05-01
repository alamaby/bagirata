# BagiStruk

**BagiStruk** is a Flutter app that splits bills from receipt photos. Snap one or more receipts, let the AI extract every line item, review and edit the results, then assign items to participants — tax and service charges are distributed proportionally.

---

## Features

- **Receipt OCR** — Upload one or multiple receipt photos. Items, prices, quantities, merchant name, and receipt date are extracted automatically via a multi-provider LLM pipeline (Gemini, OpenRouter, NvidiaNIM with priority-ordered failover).
- **Review & Edit** — Every extracted item is editable before saving: name, quantity (supports decimals for weight/volume), and price. Tax and service amounts are pre-filled from the receipt and can be adjusted.
- **Bill Splitting** — Assign items to participants. Tax and service are distributed proportionally based on each participant's subtotal share.
- **Settlement Loop** — After splitting, a dedicated detail screen tracks per-participant payment status with optimistic toggles. When everyone has paid, the bill is auto-marked settled.
- **Anonymous-first Auth** — Sessions persist across restarts (supabase_flutter local storage). Anonymous sign-in is created lazily on the first action that requires `auth.uid()` (e.g. tapping Scan), so a previously-restored email session is never overwritten. Users can promote an anonymous account to a full email account without losing their bill history.
- **Offline-safe keys** — All LLM API keys are stored server-side in Supabase. No keys are bundled in the app or exposed to the client.
- **Rate-limited inserts** — Database-level trigger enforces 30 bills/hour and 200 bills/day per user to prevent abuse.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.11+, Dart |
| State management | Riverpod 3 (code-gen), Freezed 3 |
| Navigation | go_router 14 |
| UI utilities | flutter_screenutil, flutter_animate, Lottie |
| Backend | Supabase (Postgres + RLS, Auth, Edge Functions / Deno) |
| LLM | Gemini, OpenRouter, NvidiaNIM — provider config stored in DB |
| Localization | flutter_localizations + ARB files |

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.11
- A [Supabase](https://supabase.com) project
- At least one LLM provider API key (Gemini recommended)

### 1. Environment

```bash
cp .env.example .env
# Fill in your values:
# SUPABASE_URL=https://<project>.supabase.co
# SUPABASE_ANON_KEY=<anon-key>
```

### 2. Database schema

```bash
supabase db push
```

### 3. LLM provider

Insert at least one active row into `llm_configs`:

```sql
INSERT INTO llm_configs (provider_name, api_key, base_url, model_name, priority, is_active)
VALUES (
  'gemini',
  '<YOUR_GEMINI_API_KEY>',
  'https://generativelanguage.googleapis.com',
  'gemini-2.0-flash',
  1,
  true
);
```

See [PROJECT_SUMMARY.md §5](PROJECT_SUMMARY.md) for adding fallback providers.

### 4. Enable Anonymous Sign-In

In your Supabase Dashboard: **Authentication → Providers → Anonymous Sign-Ins → Enable**

Without this, inserts into `bills` will be rejected by Row Level Security.

### 5. Deploy the Edge Function

```bash
supabase functions deploy process-receipt
```

### 6. Code generation & run

```bash
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## How to Use

1. **Open the app** — your previous session is restored if you have one; otherwise you stay signed-out until your first action.
2. **Tap the camera button** on the home screen to pick one or more receipt photos from your gallery.
3. **Tap Scan** — an anonymous session is created on the fly if needed, then images are sent to the OCR pipeline.
4. **Review the results** — check extracted items, adjust quantities or prices if needed, and set tax/service amounts.
5. **Add participants** — enter the names of people splitting the bill.
6. **Assign items** — mark which items each participant ordered.
7. **Save** — totals per participant (including their share of tax/service) are calculated and stored.
8. **Track settlement** — on the bill detail screen, toggle each participant's payment status. The bill auto-marks as settled when all participants are paid.
9. *(Optional)* **Create an account** — tap your profile to promote your anonymous session to a full email account and keep all your bills.

---

## Smoke Test (CLI)

```bash
./smoketest.sh path/to/receipt.jpg
```

Reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `.env`. Exit 0 = OCR pipeline is healthy.

---

## Full Technical Documentation

See [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) — architecture diagrams, database schema, Edge Function lifecycle, Flutter layer flow, LLM provider configuration, and troubleshooting.
