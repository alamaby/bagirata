# M3 Review Fixes — Categories, Search, Trash

Created: 2026-09-08 00:00:00 UTC

## Objective

Perbaiki temuan review M3 sebelum rilis: satu grant salah target (insight
403 untuk semua Plus), lalu edge UX + kontrak error + gap test. Semua dengan
test yang membuktikan.

## Scope

- In-scope: follow-up migration (file BARU — migration pushed tak disentuh),
  history screen, review screen, trash restore, notifier/filter state, test.
- Out-of-scope: rate-limit RPC, `https` share fallback, clock-skew countdown,
  server-side ILIKE matrix (butuh akses tulis DB).

## Tasks

### R1 — Follow-up migration (submodule, KRITIKAL)

- [ ] `20260908xxxxxx_fix_m3_insight_grant.sql`: GRANT 4-arg
  `(UUID, DATE, TEXT, TEXT)` ke `authenticated, service_role` (+ REVOKE
  PUBLIC yang benar). Tanpa ini insight Plus selalu 403.
- [ ] Tambah DROP overload baru sebelum tiap CREATE (idempoten re-run) +
  whitelist `p_category` di list/summary (cermin insight, invalid → 22023).

### C1 — Search UX (history_screen)

- [ ] `onSubmitted` flush debounce (enter langsung cari).
- [ ] Sinkron `_searchCtrl` di `onRemoveQuery`/`onReset`/filter-apply
  (fokus pun ikut clear — tutup desync).
- [ ] Bandingkan `effectiveQuery` sebelum `setQuery` (hilangkan RPC ganda
  `"kopi"` vs `"kopi "`).
- [ ] `_FilteredCountLabel`: teruskan total real (bukan `0`).

### C2 — Trash restore error typed (deleted_bills_screen)

- [ ] Ganti `toString().contains(...)` dengan match
  `ServerFailure(message: contains 'deleted_bill_not_found_or_expired')`.
- [ ] Tile tanggal pakai `AppFormat.intlLocaleOf` (konsisten locale).

### C3 — Tag UX (review screen)

- [ ] Error/count saat tag > 5 (ganti helper statis): tampilkan
  `tagLimitReached` sebagai error hanya bila overflow, plus counter `n/5`.
- [ ] Non-Plus: strip tags saat save (atau block dengan pesan) — jangan
  andalkan server saja.

### Tests

- [ ] `setQuery`/`setCategory` unit (notifier reset-safe); debounce+clear
  widget (enter flush, clear, desync-fokus); `_CategoryRow` render;
  expired-restore branch (pre-check + mapping);
- [ ] Insight zero-bill parse (total 0, MoM null, list kosong) +
  `byCategory` kosong; downgrade-retensi reasoning test
  (expiry dihitung di delete — dokumentasikan sebagai kontrak).
- [ ] Re-run: `flutter analyze` 0 error, full `flutter test`.

## Risks

- Migration aman kapan saja (GRANT idempoten); link/tag data tak tersentuh.
- Search-sync-saat-fokus: jaga caret — clear eksplisit per aksi, bukan tiap
  build (hindari caret jump saat mengetik).
- Tag strip non-Plus mengubah save payload — behind `isPlus` flag yang
  sudah ada; aman.

## Progress Log

- 2026-09-08 — Plan ditulis dari review 2 agen + verifikasi manual.
- 2026-09-08 — Semua tasks selesai. Verifikasi: analyze 0 error, test 596
  passed (591 + 5 baru/diperbaiki). R1 follow-up migration `20260908000000`.
  C1 search flush + sync + dedup + count real. C2 typed match + locale.
  C3 counter/error + strip non-Plus + test. Plus: notifier/filter/insight/
  widget tests + zero-bill + retention contract + locale harness fix.

## Notes (deferred)

- Rate-limit create RPC, `https` fallback, countdown skew, share-vs-recovery
  priority, matriks server ILIKE/downgrade/IDOR → operator checklist saat
  apply (butuh DB tulis; MCP read-only).
