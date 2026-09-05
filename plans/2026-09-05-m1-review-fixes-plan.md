# M1 Review Fixes — Plan Perbaikan Temuan Audit

Created: 2026-09-05 17:30:00

## Objective

Perbaiki temuan audit atas commit M1 (`4179074`) sebelum rilis: ID notifikasi tak stabil lintas-restart, async tak terjaga, bookkeeping bohong, cancel tanpa init, hook hilang (unsettle/delete), izin iOS, disclosure privasi, guard router, dan UX quick-add. Semua dengan test yang membuktikan.

## Scope

- In-scope: `settlement_reminder_service.dart` + 3 call site + sheet/chips + router review + ARB + `docs/privacy-policy.md`.
- Out-of-scope: exact alarm, FCM, DB unique index (butuh operator/migrasi — dicatat), AppBar overflow snapshot test, format display `08…`.

## Milestones

1. Service correctness (ID stabil + init bool + cancel init + bookkeeping jujur + stored IDs + izin + rehidrasi).
2. Hooks (unsettle reschedule, delete cancel, try/catch call site).
3. UX + docs (chip confirm/live-exclude, raw display, router guard, hapus ARB mati, privacy disclosure).

## Tasks

- [ ] R1 Stable IDs: ganti `billId.hashCode` → SHA-256 4 byte `& 0x3fffffff` (`crypto` sudah dep); golden test nilai tetap; simpan `ids` di prefs; cancel pakai stored IDs (fallback hash untuk legacy); uji tabrakan 1k bill.
- [ ] R2 `init(): Future<bool>`; schedule bail bila false; `scheduled.add` hanya pasca-sukses; prune entri saat semua slot skip/gagal; cancel panggil `init()` dulu.
- [ ] R3 Izin: tangkap bool Android (`null`→granted), batal+skip-tulis bila denied; tambah iOS `requestPermissions(alert/badge/sound)`; rehidrasi pending non-cancelled saat init (butuh title/body tersimpan); tambah `RECEIVE_BOOT_COMPLETED` + komentar.
- [ ] R4 Call site anti-crash: bungkus `.future.then` di review/detail dengan try/catch+log; hook unsettle (toggle & `!settled` → schedule ulang, idempoten); hook delete di history (`cancelForBill` pasca soft-delete sukses).
- [ ] R5 Mock plugin di test (`@GenerateMocks([FlutterLocalNotificationsPlugin])`, mockito) agar jalur sukses teruji: slot tercatat, cancel pakai stored IDs, rehidrasi panggil zonedSchedule, denied → tak tercatat.
- [ ] U1 Quick-add: konfirmasi bila field terisi (reuse string overwrite) sebelum `pop`; `_AddPersonSheet` jadi Consumer + `excludeNames` live dari `watch(splitFamily(billId))`.
- [ ] U2 Import tampilkan nomor mentah di field (normalisasi tetap saat save).
- [ ] U3 Router `/review`: `state.extra as OcrResult?` → redirect `/scan` bila null (tahan deep-link/restorasi).
- [ ] U4 Hapus ARB mati `reminderScheduled` (ID+EN+placeholder) + regen.
- [ ] D1 `docs/privacy-policy.md`: tambah bullet Notifications EN+ID (T+3/T+7, konten judul/total, lokal saja, kontekstual, matikan via OS) + baris How-We-Use; cek cermin in-app bila dari file sama.
- [ ] Verifikasi: pub get, build_runner, analyze (0 error/warning baru), full test, bump patch, commit, tag `v0.31.1`, push + push tag.

## Risks

- Rehidrasi tiap init bisa dobel-schedule bila ID tak stabil — ditutup R1 (ID deterministik, replace semantik).
- `requestNotificationsPermission` perilaku beda vendor/OS — mitigasi: `null`→granted, denied→skip+tulis log, tanpa crash.
- Guard router mengubah perilaku `/review` tanpa extra (sebelumnya crash) — mitigasi: redirect `/scan`, tak ada state hilang (draft manual tak ada).
- Counter-argumen: matriks izin/reboot memperbesar test; alternatif: ship tanpa rehidrasi — ditolak karena reboot-diam menghapus nilai fitur.

## Progress Log

- 2026-09-05 17:30:00 — Plan ditulis dari 2 audit paralel (9 temuan service + 8 temuan UI); belum ada perbaikan.
- 2026-09-05 18:30:00 — Semua tasks selesai.
- 2026-09-05 19:00:00 — UNIQUE(bill_id, lower(trim(name))) keluar dari daftar tunda: produksi terbukti 0 duplikat, migration `20260905120000` ditulis + mapping 23505→duplicateName + test. Menunggu push submodule + apply live (CLI belum auth). R1: ID SHA-256 + golden + stored IDs + uji 1k. R2: init bool + prune + cancel-init. R3: izin Android/iOS + rehidrasi + BOOT_COMPLETED. R4: try/catch call site + hook unsettle/delete. R5: mock plugin, 12 test. U1: chip confirm + live exclude (Consumer). U2: raw display. U3: router guard manual fallback. U4: ARB mati dihapus. D1: privacy EN+ID (cermin in-app otomatis via aset). Verifikasi: analyze 0, test 518 passed. Ditunda: DB UNIQUE (butuh operator), AppBar overflow snapshot test, format display `08…`, drift createdAt detik.

## Notes

- Contoh: `settle → restart → cancel` harus tetap hapus alarm T+7 (bukti: stored IDs).
- `createdAt` drift detik (server vs device) diterima M1 — dicatat, bukan bug.
- DB `UNIQUE(bill_id, lower(name))` ditunda ke plan migrasi operator.
