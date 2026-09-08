# Share-Link Deferred Items — Rate-Limit, HTTPS Fallback, Countdown Skew

Created: 2026-09-08 UTC

## Objective

Tutup 3 item tunda M2 Notes tanpa mengubah kontrak yang sudah live:
rate-limit create RPC per user, fallback teks untuk penerima tanpa aplikasi,
dan countdown expiry yang toleran terhadap clock skew.

## Scope

- In-scope: 1 file migration BARU (submodule; file pushed tak disentuh),
  matcher + snackbar rate-limit di client, teks share 2-baris + ARB,
  helper countdown murni + tampilannya, unit/widget test.
- Out-of-scope: universal link `https://` sungguhan (butuh route di repo
  landing-page terpisah), rate-limit resolve anonim per-IP (PostgREST tak
  expose IP ke SQL), perubahan expiry 7 hari / limit Free 1-aktif.

## Tasks

### R1 — Rate-limit create per user (migration)

- [ ] `supabase/migrations/20260908______share_token_rate_limit.sql`:
  `CREATE OR REPLACE FUNCTION create_bill_share_token` = salinan penuh
  versi `20260906120000` + blok hitung `created_by = auth.uid()` dalam
  24 jam terakhir; tolak bila >= 20 dengan
  `RAISE EXCEPTION 'share_token_rate_limited: max 20 links per day'
  USING ERRCODE = 'P0001'`.
- [ ] Angka 20/hari: pemakaian normal (buat–revoke–buat ulang, rotate Plus)
  jauh di bawahnya; bot loop tertahan. Revoke tetap unlimited (idempoten,
  harmless). Resolve tak di-rate-limit di SQL (anonym, tanpa identitas).
- [ ] Standar repo: `SECURITY DEFINER SET search_path = ''`, fully-qualified,
  GRANT tak berubah (signature sama → preservasi grant existing).

### C1 — Client mengenali rate-limit (bukan "gagal umum")

- [ ] `BillShareLink.isRateLimited(Object)` terpusat
  (case-insensitive `share_token_rate_limited`); `ShareLinkResult.failed()`
  tetap untuk error lain; state tampilan dipertahankan seperti limit.
- [ ] `_ShareLinkSection`: snackbar khusus `shareLinkRateLimited`
  ("kebanyakan link hari ini, coba besok") — tanpa CTA upgrade (bukan soal plan).
- [ ] Test: fake repo gagal dengan pesan rate-limit → state utuh +
  `isRateLimited` true + `isLimitError` false.

### H1 — HTTPS fallback untuk penerima tanpa aplikasi

- [ ] Format teks share 2 baris: baris 1 link mentah `bagistruk://share/<t>`
  (tetap tappable bila app terinstal), baris 2 fallback lokal
  `shareLinkWebFallback` = "Belum punya aplikasinya? Unduh BagiStruk di sini:
  {url} — lalu ketuk link di atas lagi." dengan `AppConstants.websiteUrl`.
- [ ] Clipboard tetap link mentah saja (paste aman ke mana pun).
- [ ] `Share.shareUri` → `Share.share(text)` di 2 call site bill_detail
  (snackbar action + tombol re-share) agar fallback ikut terkirim.
- [ ] ARB ID+EN: `shareLinkWebFallback`.
- [ ] Test: builder teks murni (link + fallback + url) untuk kedua locale.

### S1 — Countdown toleran skew

- [ ] Helper murni `ShareLinkCountdown` (file baru, tanpa Flutter):
  `remaining(expiresAt, now)` clamp ≥ 0; `isExpired` = remaining ≤ 0;
  `labelKey`/bucket: hari / jam / menit untuk ARB.
- [ ] `_ShareLinkSection`: tampilkan countdown ("Berakhir dalam X") DI ATAS
  baris tanggal statis yang sudah ada; bila `isExpired` → teks kedaluwarsa
  + tombol revoke disembunyikan (revoke token mati = no-op sia-sia).
  Keputusan skew: server satu-satunya sumber kebenaran; client tak pernah
  menebak "masih valid".
- [ ] ARB ID+EN: `shareLinkCountdownDays/Hours/Minutes/ExpiredNow`
  (parameter {count}).
- [ ] Test: bucket boundaries (23:59→jam, 24:00→hari, 59s→menit,
  0/negatif→expired), clamp, dan widget section tampil countdown.

## Risks

- Salin penuh body RPC di migration baru berisiko drift bila
  `20260906120000` berubah kemudian — mitigasi: komentar header menunjuk
  file sumber + tanggal; pola ini sudah dipakai repo (follow-up M2/M3).
- Share text 2 baris di WhatsApp: baris 1 tetap link tappable; baris 2 teks
  biasa. Diterima — lebih baik dari link mati tanpa penjelasan.
- `Share.share` vs `shareUri`: kehilangan URI-semantik di receiver; isi sama,
  kompatibilitas lebih luas. Diterima.

## Progress Log

- 2026-09-08 — Plan ditulis dari pemetaan baseline.
- 2026-09-08 — Semua tasks selesai. R1 migration `20260908120000` (salinan
  penuh + blok rate-limit, selaras BIGINT/FOR UPDATE dari fix sebelumnya).
  C1 matcher + snackbar khusus. H1 teks 2-baris + ARB ID/EN. S1 helper murni
  + countdown/expired di section + widget test. Verifikasi: analyze 0 error,
  full test hijau.
