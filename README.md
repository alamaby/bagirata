# BagiStruk

Aplikasi Flutter untuk split-bill berbasis OCR struk: foto struk → ekstrak item via LLM (Gemini / OpenRouter / NvidiaNIM dengan failover) → review & edit → simpan ke Supabase → bagi ke participant secara proporsional (tax/service ikut share subtotal).

## Stack

- **Flutter 3.11+** — Riverpod 3 (codegen), Freezed 3, go_router 14, supabase_flutter 2, flutter_screenutil
- **Supabase** — Postgres + RLS, Auth (anonymous + email promotion), Edge Functions (Deno)
- **LLM** — multi-provider via tabel `llm_configs` (priority-ordered failover, no client-side keys)

## Setup

1. **Env**
   ```bash
   cp .env.example .env
   # Isi SUPABASE_URL + SUPABASE_ANON_KEY
   ```
2. **DB schema** (sekali per environment)
   ```bash
   supabase db push
   ```
3. **LLM provider** — INSERT minimal satu baris ke `llm_configs` (lihat [PROJECT_SUMMARY.md §5](PROJECT_SUMMARY.md)).
4. **Edge Function**
   ```bash
   supabase functions deploy process-receipt
   ```
5. **Auth** — di Supabase Dashboard, **Authentication → Providers → Anonymous Sign-Ins → Enable**. App auto-login anonim saat startup; tanpa ini insert ke `bills` ditolak RLS.
6. **Codegen + run**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

## Smoke test (tanpa app)

```bash
./smoketest.sh path/to/struk.jpg
```
HTTP 200 = pipeline OCR sehat.

## Dokumentasi lengkap

[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) — arsitektur, schema, Edge Function lifecycle, layer flow Flutter, troubleshooting.
