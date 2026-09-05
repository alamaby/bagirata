# M2 — Share-Link Read-Only + XLSX Export

Created: 2026-09-05 12:00:00

## Objective

Beri alasan bagikan (share-link read-only dengan expiry) dan alasan upgrade (XLSX Plus), menutup backlog `TODO.md:246` (XLSX) tanpa melebarkan RLS owner-centric ke co-edit.

## Scope

- In-scope: F5 share-link read-only (1 link aktif/bill Free, rotate untuk Plus, expiry 7 hari), F7 XLSX export Plus.
- Out-of-scope: co-edit peserta non-akun, edit via link, multi-link per bill, server-side XLSX.
- Skema baru hanya `bill_share_tokens`; XLSX murni client-side.

## Milestones

1. F5.1 Migrasi + RPC share-token (operator-apply) + RLS + revoke policy.
2. F5.2 Client share-link (create/copy/revoke + layar publik read-only + deep-link).
3. F7 XLSX exporter + Plus gate + share + test.

## Tasks

- [ ] F5.1 Migrasi `bill_share_tokens(id UUID PK, bill_id FK, token_hash TEXT UNIQUE, created_by UUID, created_at, expires_at, revoked_at NULL, last_viewed_at NULL)`: index `(bill_id, revoked_at, expires_at)`; `ENABLE RLS` tanpa policyterbuka; `REVOKE ALL FROM PUBLIC, anon, authenticated` + GRANT eksplisit ke `authenticated` hanya via RPC (standar 2026-08-30). Fungsi `SECURITY DEFINER SET search_path = ''` + `public.` qualified (insiden `ensure_profile` 2026-05-02).
- [ ] F5.2 RPC: `create_bill_share_token(p_bill_id)` (upsert 1 aktif untuk Free — enforce di server via `plan_code`, bukan client; Plus boleh rotate), `revoke_bill_share_token(p_token_id)`, `resolve_share_token(p_token)` (return bill+items+participants+assignments read-only, tanpa bank info, tanpa phone bila perlu). Token opaque `crypto.randomUUID`/`nanoid`; simpan hanya `token_hash` (SHA-256) — cocok pola `crypto: ^3.0.6` (`pubspec.yaml:68`) dan `email_canonical_hash`.
- [ ] F5.3 Client create/copy/revoke di `bill_detail_screen.dart` (sejajar `_shareParticipant:125-152` dan `_ExportActions:297-363`): tombol "Salin link", state link aktif + countdown expiry, revoke manual. Share via `Share.shareUri(bagistruk://share/<token>)` — hari ini share hanya teks/file (`settlement_share_launcher.dart:19-55`, `share_plus: ^10.1.4`).
- [ ] F5.4 Layar publik `ShareBillScreen(token)` + rute deep-link `bagistruk://share/:token` (extend `app_links` yang hari ini hanya auth-callback + router callback `app_router.dart:54-91`); render read-only (tanpa edit, tanpa settlement toggle, tanpa bank block `_writeBankInfoIfAny` di `settlement_message_builder.dart:219-229`).
- [ ] F5.5 ARB: `shareLinkTitle`, `shareLinkCopy`, `shareLinkCopied`, `shareLinkExpiresIn`, `shareLinkRevoked`, `shareLinkExpired`, `shareLinkFreeLimit` (ID+EN).
- [ ] F5.6 Test (diperkuat hasil review): RPC hanya pemilik (IDOR: user B resolve token bill A → 404); token invalid/expired/revoked ditolak; boundary `expires_at==now` ±1s; tanpa leeway vs leeway 5 mnt didokumentasikan (countdown client vs `now()` server bisa selisih); revoke ganda + race resolve-vs-revoke + `last_viewed_at` konkuren; bill soft-deleted → resolve 404 (bukan bocor); bill settled vs unsettled parity (diputuskan: link tetap viewable); Free tak bisa punya 2 aktif; downgrade Plus→Free dengan 2 aktif (mana survive? create diblokir? revoke paksa?) — kunci perilaku; cold-start `bagistruk://share/<token>` (Android intent-filter + `app_links` cabang share + pengecualian guard legal/onboarding di `app_router.dart:161-197`, karena `deep_link_handler.dart:62-72` hari ini drop non-auth URI); layar publik tak memanggil write RPC (toggle/settlement/edit, bank block `_writeBankInfoIfAny` dikecualikan); rate-limit create per `bill_id`/`created_by` (preseden `20260428130000` 30/jam 200/hari); token opaque acak + simpan SHA-256 saja (`crypto:^3.0.6`), raw≠stored, `UNIQUE(token_hash)` collision.
- [ ] F7.1 Tambah dep `excel` (evaluasi `excel: ^4` vs generator manual); buat `lib/presentation/bills/export/bill_xlsx_exporter.dart` sejajar `bill_csv_exporter.dart:4-82` (RFC4180) dan `bill_pdf_exporter.dart:28-89` (sections summary/items/participants/bank): 2 sheet (Item, Peserta) reuse `state.calculateTotals()`, nama file `bagistruk-<slug>.xlsx` reuse `_safeFileName` (`bill_detail_screen.dart:227-233` — koreksi ref review; bukan di csv exporter).
- [ ] F7.2 Plus gate identik CSV/PDF (`bill_detail_screen.dart:154-163,188-197`): non-Plus → Settings; label `Export XLSX (Plus)` + `PlusInfoIcon(message: exportPlusDetail)`; `bankInfo` hanya bila `isPlus` (`:133-135,200`).
- [ ] F7.3 Share via `Share.shareXFiles` mime `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`; ARB `exportXlsx`, `exportXlsxPlusLocked`, `exportXlsxShareText`.
- [ ] F7.4 Test (diperkuat hasil review): parity angka XLSX vs CSV/PDF (subtotal/tax/service/total/status; sel numerik + `decimalDigits` vs string — CSV tulis raw `double`, PDF pakai `currency.format`); IDR/JPY 0dp vs USD/SGD 2dp (`currency_formatter.dart:28-56,206-213`); bill besar 500+ item/100+ peserta (memori, limit baris sheet, drift fix `calculateTotals`); unicode/CJK/emoji/Arab + RTL + sanitasi nama sheet; injeksi formula (`=+-@` prefix) + BOM; peserta kosong (header-only, bukan throw seperti `settlement_message_builder.dart:35-38`); gate widget: label `exportXlsxPlusLocked`, tap→`/settings` (catat `from` hilang — perbaiki atau dokumentasikan), Plus→share sheet, downgrade mid-sheet (stale `read` vs `watch`); slug tabrakan (`Bukber!!!`≡`Bukber`, emoji hilang, judul kosong→`bagistruk-bill`) → tambah suffix unik (`billId` pendek/timestamp) + uji.
- [ ] Verifikasi akhir M2: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --split-per-abi`; migrasi di-apply operator via Dashboard/submodule + `supabase migration list` sinkron (MCP read-only — jangan eksekusi DDL dari agen).

## Risks

- Share-link memperluas permukaan RLS owner-centric — risiko IDOR bila resolve langsung PostgREST; mitigasi: resolve hanya via `SECURITY DEFINER` RPC + token hash, tanpa SELECT langsung `bills` publik.
- Token bocor via chat log/forward — mitigasi: opaque + expiry 7 hari + revoke + tanpa PII sensitif (bank block dikecualikan).
- Dep `excel` menambah ukuran APK dan risiko font/locale angka; mitigasi: angka diformat via `CurrencyFormatter` existing, bukan format Excel kustom.
- Privacy: link publik = data bill keluar dari RLS user; wajib update `docs/privacy-policy.md` (tambah disclosure link 7-hari, risiko forward, tanpa bank/phone di link) + Play Data Safety + sinkron `bagistruk-landing-page/src/legalContent.ts` + `docs/release-play-store.md:140-156` sebelum aktif (`TODO.md:22`); tanpa itu F5 tidak boleh enable.

## Progress Log

- 2026-09-05 12:00:00 — Plan M2 ditulis; belum ada implementasi; migrasi menunggu operator-apply.
- 2026-09-05 12:30:00 — Review audit vs kode: perkuat F5.6/F7.4, koreksi ref `_safeFileName`, tambah checklist privacy/landing-page; belum ada implementasi.

## Notes

- Contoh: `Bill "Bukber 12 orang" → Salin link → peserta tanpa akun lihat rincian 7 hari → link kedaluwarsa`.
- Counter-argumen: share-link read-only terasa kurang ("kenapa tak bisa tandai bayar?"); jawaban: co-edit butuh model partisipan-akun + konflik tulis — non-goal; tawarkan upgrade Plus + daftar akun sebagai CTA di layar publik.
- Satu file = satu plan (aturan repo); M2 tidak digabung dengan M1/M3/M4.
