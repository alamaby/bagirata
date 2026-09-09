# Manual Test M1–M4 — BagiStruk

Created: 2026-09-09 08:00:00

## Objective

Daftar uji manual user untuk M1 (aktivasi Free), M2 (share-link + XLSX), M3 (kategori/search/trash), M4 (template/duplikat + retry Plus + batch guard) pada build `0.32.2+82` (migrasi 9/9 applied, Edge `process-receipt` deployed).

## Scope

- In-scope: alur UI manual per milestone di bawah, akun anon/Free/Plus bila disebut.
- Out-of-scope: automated test, audit `llm_logs`, Play Console upload.

## Milestones

1. M1 aktivasi Free
2. M2 share + export
3. M3 organize history
4. M4 power Plus

## Tasks

### M1 — Aktivasi Free (F1–F4)

- [ ] F1 manual bill: History FAB "Buat manual" → review kosong → tambah 2 item → simpan dengan saldo kredit 0 → bill tersimpan, tanpa potong kredit.
- [ ] F1 validasi: judul spasi → `titleRequired`; item nama kosong / qty 0 → `invalidItem`; price 0 diizinkan tersimpan.
- [ ] F1 banner: review manual tak tampilkan banner `lowConfidence` / mismatch; receipt-date row tersembunyi.
- [ ] F2 equal-split: bill 3 peserta → "Bagi rata" → tiap orang dapat porsi sama; ubah satu weight → totals ikut berubah proporsional.
- [ ] F2 guard: bill tanpa peserta → tombol ringkasan tetap sembunyi; bill harga-nol → share 0, tak crash.
- [ ] F3 pustaka: tambah "Budi" lalu "budi " → ditolak duplikat (case/whitespace-insensitive); `0812…` ternormalisasi ke `62…` saat simpan, tampil `08…` di chips.
- [ ] F3 chips: peserta yang sudah di bill tak muncul di saran; tap chip langsung tambah (bukan prefill); tampil phone bila ada.
- [ ] F3 import kontak: field nama sudah terisi → dialog merge/overwrite (bukan silent-ignore); kontak tanpa nomor → pesan `participantImportNoPhone`.
- [ ] F3 logout: pustaka saran user A tak bocor ke user B setelah logout/login.
- [ ] F4 reminder: aktifkan reminder di Settings (izin notif kontekstual) → simpan bill outstanding → notifikasi T+3/T+7 terjadwal; lunaskan semua (`is_settled`) → jadwal batal.
- [ ] F4 reboot/restart: restart app → jadwal pending tetap ada (rehidrasi); hapus bill → jadwal bill itu batal; izin ditolak → toggle revert, tanpa crash.

### M2 — Share-Link + XLSX (F5, F7)

- [ ] F5 create: detail bill → "Salin link" → link `bagistruk://share/<token>` tercopy; buka ulang detail → status link aktif + tanggal expiry tampil.
- [ ] F5 publik: buka link di device/browser tanpa login → tampil read-only (items, totals, status bayar); tanpa toggle bayar, tanpa edit, tanpa blok bank, tanpa phone.
- [ ] F5 expired/invalid: token salah / kedaluwarsa / di-revoke / bill dihapus → layar kedaluwarsa (bukan error generik); error jaringan → error view + tombol retry.
- [ ] F5 revoke: revoke link → state null; link lama dibuka → kedaluwarsa.
- [ ] F5 limit Free: bill Free dengan 1 link aktif → create lagi → snackbar limit + CTA Upgrade (state link lama utuh, tak tertimpa).
- [ ] F5 rotate Plus: akun Plus create link kedua di bill sama → link lama auto-revoke, link baru aktif.
- [ ] F5 rate-limit: create >20 link/hari → snackbar `shareLinkRateLimited` ("coba besok"), tanpa CTA upgrade.
- [ ] F5 fallback teks: share via teks → 2 baris (baris 1 link mentah tappable, baris 2 "Belum punya aplikasi? Unduh…"); clipboard tetap link mentah saja.
- [ ] F5 countdown: section tampil "Berakhir dalam X hari/jam/menit" di atas tanggal statis; token mati → teks kedaluwarsa + tombol revoke hilang.
- [ ] F7 XLSX Plus: detail → Export XLSX (Plus) → file `bagistruk-<slug>-<billId8>.xlsx` 2 sheet (Item, Peserta) angka = sel numerik parity CSV/PDF; non-Plus → label terkunci + tap ke Settings.
- [ ] F7 parity: bandingkan subtotal/tax/service/total/status XLSX vs CSV vs PDF untuk bill IDR dan USD; nama sheet aneh/emoji tersanitasi; peserta kosong → header-only, tak throw.

### M3 — Kategori/Search/Trash (F9, F15)

- [ ] F9 picker: review → pilih kategori `makan` tersimpan; tambah tag custom (Plus) ≤5 tersimpan; Free tambah tag → di-block/strip dengan pesan (bukan lolos diam).
- [ ] F9 filter: history → filter kategori `makan` → hanya bill makan; chip kategori tampil di tiap row; insight card tampil breakdown `by_category`.
- [ ] F9 invalid: kategori asing via API ditolak/coerce `lain`; bill lama tanpa kolom terbaca `lain`, tak crash.
- [ ] F15 search: ketik "kopi" → hasil menyempit (judul + nama item); Enter langsung cari (flush debounce); clear → daftar penuh kembali + fokus ikut clear.
- [ ] F15 search edge: query spasi/`100%`/`a_b` → hasil benar (escaping, bukan full-scan); ganti query → cursor reset (bukan append/duplikat row).
- [ ] F15 empty: query tanpa hasil → empty state tampil teks query + tombol reset.
- [ ] F15 trash: hapus bill → masuk Sampah dengan countdown (`Xd lagi`); retensi Free 30 hari / Plus 90 hari tertera benar.
- [ ] F15 restore: pulihkan dari Sampah → kembali ke history; restore bill kedaluwarsa → pesan khusus (bukan `errorGeneric`).

### M4 — Template/Duplikat + Retry Plus (F12, F14)

- [ ] F12 duplikat detail: detail → ⋮ → Duplikat → snackbar sukses + navigasi ke bill baru; angka (subtotal/tax/service/currency) sama, `createdAt` kini, `receipt_date` kosong, semua `is_paid=false`, `is_settled=false`.
- [ ] F12 duplikat history: row history → ikon copy → bill baru muncul di atas list + buka detail baru; tombol row hanya loading di row itu (tak lock global).
- [ ] F12 template save: detail → ⋮ → "Simpan sbg template" → dialog nama (maks 60 char, kosong ditolak) → snackbar tersimpan.
- [ ] F12 template use: history AppBar → ikon bookmark → sheet list (nama, `Dipakai Nx`, tanggal) → Pakai → bill baru terbuat + history refresh + buka detail baru.
- [ ] F12 template delete: sheet → hapus → dialog konfirmasi → snackbar dihapus; list refresh.
- [ ] F12 limit Free: akun Free buat template ke-6 → snackbar `billTemplateLimitReached` (Plus: tanpa batas).
- [ ] F14 retry Plus: akun Plus scan saat provider sibuk → status "Memindai N gambar… (Plus: …provider lain)" → hasil sukses 1 request (tanpa charge ganda); tombol retry in-card muncul hanya bila gagal retryable.
- [ ] F14 retry Free: akun Free gagal scan → pesan "AI sibuk" tanpa tombol retry in-card (retry via tombol scan utama, perilaku lama).
- [ ] F14 batch cap: tambah foto ke-11 via galeri/kamera/share-in → ditolak dengan pesan batas (maks 10); submit draft >10 → gagal lokal ramah, kredit tak terpotong.
- [ ] F14 413 mapping: bila server balas 413 (`too_many_images`/`images_too_large`) → judul "Foto terlalu besar" + `canRetry=false` (tak ada tombol retry in-card).

## Risks

- Reminder lokal tak jalan bila proses dibunuh (tanpa FCM) — nyatakan sebagai limitasi, bukan bug.
- Duplikat client-side tak atomik (6+ round-trip): gagal tengah bisa sisakan bill yatim — laporkan bila terjadi.
- Race cap template Free (2 create konkuren) bisa lolos 5 — diterima sementara, pola sama seperti share-token.

## Progress Log

- 2026-09-09 08:00:00 — Daftar uji manual M1–M4 ditulis dari plan + memori implementasi; belum dieksekusi user.
- 2026-09-09 05:10:00 — Checklist terverifikasi. Flutter CI `34312530711` sukses (generate/analyze/612 tests); Release Android `34312530679` sukses, AAB ter-upload ke Play internal testing, dan APK/AAB `v0.32.2` tersedia di GitHub Release.

## Notes

- Contoh cepat: `kos "Listrik Agustus" → Jadikan template → September 1-tap duplikat`; `Plus scan saat Gemini 429 → auto-coba provider lain sekali → sukses`.
- Counter-argumen: 40+ cek sekaligus berat satu sesi; bila sempit, prioritaskan M4 (duplikat/template/retry) lalu M2 share-link, karena keduanya menyentuh uang/data keluar.
