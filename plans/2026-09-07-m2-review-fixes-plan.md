# M2 Review Fixes — Share-Link + XLSX

Created: 2026-09-07 00:00:00 UTC

## Objective

Perbaiki temuan review M2 sebelum rilis: satu bug SQL kritikal (expiry NULL di
semua link baru), celah privilege Plus kedaluwarsa, state basi/revoke di UI
share-link, error conflation di layar publik, dan gap paritas CSV/XLSX —
dengan test yang membuktikan tiap perbaikan.

## Scope

- In-scope: follow-up migration (TANPA edit migration pushed `20260906120000`
  maupun commit submodule `5003bbf`), `BillShareLink` family refactor,
  provider layar publik, CSV bank block, helper filename, widget/provider test.
- Out-of-scope (dicatat di Notes): `https` fallback, rate-limit RPC,
  matriks downgrade/IDOR server (operator checklist), clock-skew countdown.

## Tasks

### R1 — Follow-up migration (submodule, file BARU, jangan edit pushed file)

- [ ] `supabase/migrations/20260907xxxxxx_fix_share_token_returning.sql`:
  - `CREATE OR REPLACE FUNCTION create_bill_share_token` dengan
    `RETURNING bill_share_tokens.id, bill_share_tokens.expires_at`
    (KRITIKAL: bare `expires_at` tersubstitusi OUT param → NULL; client
    `DateTime.parse("null")` lalu create selalu gagal).
  - `bill_share_caller_plan`: return `'plus'` hanya bila
    `plan_code='plus' AND status='active' AND (current_period_end IS NULL
    OR current_period_end > NOW())` (cermin `bill_history_window_days`;
    tanpa ini Plus kedaluwarsa/dibatalkan tetap bisa rotate).
  - `FOR UPDATE` di owner lookup (tutup race 2 create Free bersamaan).
  - Kualifikasi `WHERE bill_share_tokens.id`, `v_active BIGINT`, betulkan
    komentar "0 baris" → `RETURN NULL`.
  - `SECURITY DEFINER SET search_path = ''` + fully-qualified seperti biasa.

### C1 — `BillShareLink` jadi family per billId + failure tak hapus data

- [ ] `@riverpod class BillShareLink`: `build(String billId)` langsung load
  (hapus `load()` manual + `didUpdateWidget` basi A→B).
- [ ] `createAndCopy` kembalikan `ShareLinkResult({link, limited})`;
  failure (limit/gagal) TIDAK menimpa state data — snackbar baca return
  value, bukan `state.error`.
- [ ] `isLimitError(Object)` terpusat (case-insensitive `share_token_limit`).
- [ ] UI: retry di load-error; limit-error tampil + CTA Upgrade (push settings);
  revoke sukses → state null (tetap).

### C2 — Provider layar publik bedakan error vs expired + retry

- [ ] `sharedBillProvider`: `ResultFailure` → `throw` (bukan null); null hanya
  untuk token invalid/expired/revoked/deleted.
- [ ] `SharedBillScreen.AsyncError` → error view + tombol retry
  (`ref.invalidate`), bukan `_ExpiredView`.

### C3 — Join CTA di success view publik

- [ ] Tambah tombol `shareLinkJoinCta` di bawah `_SharedBillView`
  (konsisten dengan expired view; bounce login→history adalah perilaku
  router existing).

### C4 — Paritas bank block CSV

- [ ] `BillCsvExporter`: param opsional `bankInfo`, tulis blok bank bila
  `isComplete`; `_exportCsv` teruskan bankInfo bila Plus (cermin PDF/XLSX).

### C5 — Helper filename unik untuk ketiga format

- [ ] `ExportFilenames.unique(title, billId, ext)` (slug + billId8);
  CSV/PDF/XLSX pakai helper yang sama; `_safeFileName` dipertahankan untuk
  kompatibilitas internal bila masih dipakai.
- [ ] Test tabrakan slug/emoji/kosong untuk ketiga ext.

### C6 — Observability export

- [ ] `AppLogger.error` di catch `_exportXlsx` (cermin pola reminder service).

### Tests

- [ ] Provider `BillShareLink` family: create sukses (lastLink+clipboard?
  clipboard skip di unit — assert link/state), limit→state utuh,
  failure→state utuh, revoke→null, expiry parse.
- [ ] `SharedBillScreen` widget: data view, expired view (null), error+retry
  view (throw → retry invalidate → sukses).
- [ ] CSV bank block present/absent; filename helper; xlsx 500-item encode
  smoke (< wajar, assert bytes non-empty + 2 sheets).

## Risks

- Follow-up migration aman di-apply kapan saja (CREATE OR REPLACE,
  idempoten); tapi link yang terlanjur dibuat SEBELUM fix punya
  `expires_at` VALID di DB (bug hanya di RETURNING) — tidak perlu repair data.
- Family refactor mengubah call sites `billShareLinkProvider` →
  `billShareLinkProvider(billId)`; tidak ada test existing yang memakai
  provider lama (verifikasi via grep).
- CSV berubah (kolom bank baru) — format export Plus-only, konsumennya
  manusia via share sheet; diterima sebagai paritas yang diinginkan plan F7.4.

## Progress Log

- 2026-09-07 — Plan ditulis dari review 2 agen + verifikasi manual.
- 2026-09-07 — Semua tasks selesai. Verifikasi: analyze 0 error, test 557
  passed (540 + 17 baru). Perbaikan vs plan: C1 pakai family
  `billShareLinkFamily(billId)` + `ShareLinkResult` + `isLimitError` +
  retry/upgrade CTA; C2 rethrow + error view + retry; C3 join CTA;
  C4 CSV bank block; C5 `ExportFilenames` untuk 3 format; C6 AppLogger.
  R1 follow-up migration `20260907000000`. Temuan sampingan saat implementasi:
  filter analyze `" error "` meleset (format `error -`), pola grep diganti;
  mockito double-verify menghabiskan call; family autoDispose butuh listen di
  test; `appendRow([])` tak tersimpan saat decode.

## Notes (deferred, bukan diabaikan)

- `https://` fallback untuk penerima tanpa aplikasi (dead custom-scheme link).
- Rate-limit create RPC per bill/user (abuse surface kini: authenticated +
  cap 1-aktif; diterima sementara).
- Matriks server (IDOR resolve, boundary `expires_at==now` ±1s, double-revoke
  race, `last_viewed_at` concurrency, soft-delete→404, settled parity,
  Free 2nd-active blocked, downgrade 2-active) → operator checklist, butuh
  migrasi ter-apply + akses DB tulis (MCP read-only).
- Countdown vs server `expiresAt` statis: UI tampil tanggal, bukan hitung
  mundur — skew ±detik tidak material.
- Cold-start ordering (`handleInitialLink` sebelum frame pertama) +
  single-slot overwrite + share-vs-recovery priority: didokumentasikan di
  handler/router, tanpa test integrasi khusus.
- `goNamed(settings)` hilangkan `from`: preseden CSV/PDF, dibiarkan konsisten.
