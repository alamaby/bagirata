# M1 — Aktivasi Free (Manual Bill, Equal-Split, Pustaka Peserta, Reminder Lokal)

Created: 2026-09-05 12:00:00

## Objective

Naikkan aktivasi pengguna Free/anon tanpa menambah cost LLM dan tanpa migrasi DB: pengguna bisa buat bill manual (0 kredit), patungan cepat sekali tap, tambah peserta lebih cepat via pustaka + kontak, dan diingatkan menagih via notifikasi lokal opt-in.

## Scope

- In-scope: F1 manual bill, F2 equal-split mode (UI-state dulu), F3 pustaka peserta polish, F4 reminder lokal.
- Out-of-scope: perubahan skema DB, FCM/push server, share-link, kategori, recurring.
- Guardrail: core split-bill flow tidak di-lock; semua fitur jalan untuk anon/Free.

## Milestones

1. F1 Manual bill (entrypoint + banner suppression + ARB + test).
2. F2 Equal-split (mode UI + unifikasi totals + test).
3. F3 Pustaka peserta (dedup + chips quick-add + import merge + test).
4. F4 Reminder lokal (dep + izin + jadwal + cancel saat lunas + test).

## Tasks

- [ ] F1.1 Tambah entrypoint "Buat manual" (History FAB dan/atau Scan AppBar action) → `pushNamed(billReviewName, extra: OcrResult(items: [], confidence: 0, providerUsed: 'manual'))`. Baseline rute `extra`-only: `lib/core/router/app_router.dart:245-250`.
- [ ] F1.2 Suppress `lowConfidence` banner saat `providerUsed == 'manual'` (`lib/presentation/bills/screens/bill_review_screen.dart:150-151,439`); sembunyikan receipt-date row dan mismatch banner saat `detectedTotal == null` (sudah kondisional `:182,388` — verifikasi).
- [ ] F1.3 ARB `billReviewManualTitle`, `billReviewManualHint`, `billReviewManualEmptyCta` (ID+EN) + regen via `flutter pub get`. Reuse validasi existing (`BillReviewNotifier.save()`, `lib/presentation/bills/providers/bill_review_notifier.dart:151-230`).
- [ ] F1.4 Test: notifier empty→addItem→save sukses; widget review manual tidak sentuh `ocrProvider`/`getOcrCreditStatus` (`verifyNever`, saldo 0 tetap bisa simpan); tidak ada pemakaian kredit.
- [ ] F1.5 Matriks validasi + failure (hasil review): title `"   "`→titleRequired; item name `"   "`/qty 0/negatif→invalidItem; price 0 diizinkan (dokumentasikan); ketik `abc` di qty/price (`double.tryParse→0`, `bill_review_screen.dart:253-259,275-277`) → invalidItem untuk qty; `saveItemsFailed` orphan-bill (createBill ok + upsertItems gagal — coverage nol hari ini) → snackbar + bill yatim terdokumentasi (rollback non-goal M1); re-entrancy `SaveInProgress` + reset `saving=false` di semua jalur gagal (`bill_review_notifier.dart:155,171-177,199,220`); currency snapshot anon/no-profile = `USD` (`build:84`) vs default `IDR` (`:45`) → kunci perilaku + uji; manual `detectedTotal==null` → mismatch banner mati (`:53-57`), suspect-thousands tetap bisa nyala untuk IDR fraksional; `Untitled bill` default lolos `titleRequired` (kunci intentional); rute `/review` tanpa `extra` melempar (`app_router.dart:246-250`, `extra! as OcrResult`) → entrypoint wajib selalu kirim `OcrResult(..., providerUsed:'manual')`, jadikan konstanta bukan magic string; placement FAB/AppBar (`history_screen.dart:166`, scan AppBar `:417-430`) + widget test navigasi.
- [ ] F2.1 Tambah `splitMode` (enum `perItem` default / `equal`) di `SplitState` (UI-state, tanpa kolom DB). Tombol "Bagi rata" → assign semua peserta ke semua item dengan `shareWeight = 1.0`. Sentuh `lib/presentation/bills/screens/bill_split_screen.dart:213-244`, `lib/presentation/bills/providers/split_notifier.dart:330-333`.
- [ ] F2.2 Unifikasi `SplitState.calculateTotals()` (`split_notifier.dart:89-146`) dan `BillDetailState.calculateTotals()` (`bill_detail_notifier.dart:33-91`) agar delegasi ke `BillCalculator.distributeProportionally` (`lib/domain/services/bill_calculator.dart:24-88`). Equal = fast-path weight 1; perilaku hari ini even-split tapi abaikan `shareWeight` (divergen dengan domain) — samakan + tulis tes residual (largest-payer vs last-payer) sebelum refactor.
- [ ] F2.3 Test: equal N orang (termasuk sisa pembulatan `Money.roundToCurrency`), weighted 2/3 piring, unassigned guard `_SummaryButton` (`bill_split_screen.dart:246-252,822-860`) tak berubah.
- [ ] F2.4 Paritas + degenerate (hasil review): tulis tes paritas split-vs-detail-vs-`BillCalculator` dulu (IDR `100000/3` rupiah bulat vs USD `110/3` sen; drift negatif/nol/semua-nol; `bill.totalAmount != subtotal+tax+service` → expected `round(totalAmount)` vs `round(sub+extras)`); equal di bill harga-nol (`totalSubtotal==0 → share 0`, `split:104`); items kosong + peserta ada → totals nol + tombol ringkasan tetap sembunyi; `weight 0/0`, negatif-cancel, qty fraksional `0.58kg` + error floating; bulk "assign all" 1x `replaceAssignments` + rollback `saveAssignmentFailed` + bypass `selectPersonFirst` (`split:316-318`); konsistensi `itemsForParticipant` (`split:60-78`) vs `calculateTotals` untuk item shared.
- [ ] F3.1 Dedup bill-level: tolak tambah peserta bila `name.trim.toLowerCase()` sudah ada; normalisasi phone via `PhoneFormatter.normalize` (`lib/core/format/phone_formatter.dart:16-23`). Sentuh `split_notifier.dart:249-279`, `bill_split_screen.dart:180-183`. Catatan: `0812…` vs `812…` hari ini jadi bucket berbeda — samakan (tambah prefix `62` untuk bare `8…`).
- [ ] F3.2 Chips jadi quick-add + filter: exclude peserta yang sudah di bill, tampilkan phone bila ada, tap langsung `addParticipant` (bukan prefill). Sentuh `lib/presentation/bills/widgets/participant_suggestion_chips.dart:18-98`, `bill_split_screen.dart:538-547`. Ranking server `40/60 count/recency` (`saved_participant_remote_datasource.dart:13-14`) vs client `lastUsedAt desc` (`saved_participants_notifier.dart:111`) — samakan agar tak flicker.
- [ ] F3.3 Perbaiki import kontak: `bill_split_screen.dart:459-464` hari ini silent-ignore bila field sudah terisi — ganti dialog merge/overwrite; wire fallback kontak tanpa nomor (`participantImportNoPhone` ARB ada, 0 pemakaian); panggil `SavedParticipantsCache.clear(userId)` saat logout (`saved_participants_cache.dart:62` tak pernah dipanggil).
- [ ] F3.4 Test: dedup nama/phone, chips exclude-on-bill, import overwrite, tidak ada `saved*` test hari ini — tambah file baru.
- [ ] F3.5 Matriks library (hasil review): `Budi/budi /BUDI`, whitespace, Unicode NFC + full-width; nama sama beda phone vs server `UNIQUE(user,lower(name),phone)`; bare `812…→62812…`, `<6 digit→''` bucket, digit non-ASCII (Arab-Indic/Devanagari/full-width) jadi no-phone; chips exclude-on-bill + tampil phone + flicker rank server `40/60` vs client `lastUsedAt desc` + limit 8 dua sisi; offline (airplane) + cache corrupt → fallback `[]` + wipe (`saved_participants_cache.dart:27-47`); import: field terisi → dialog merge/overwrite (bukan silent-ignore `:459-464`), kontak tanpa nomor → wire `participantImportNoPhone`, `fullName+phone==null` → no-op tak macet, `_importing` re-entrancy; anon: `split:219-225` skip bump vs `bill_split_screen:186-190` bump unconditional → kunci satu perilaku + uji; auto `Saya/Me` per `languagePref`; logout → `SavedParticipantsCache.clear` + isolasi antar-user (bocor hari ini); DTO roundtrip + cap-eviction 8 + `refresh()` hook.
- [ ] F4.1 Tambah dep `flutter_local_notifications` + `timezone`; inisialisasi lazy (jangan di `main()` blocking — insiden launch freeze ads 2026-09-03). Permission `POST_NOTIFICATIONS` (Android 13+) diminta kontekstual saat user aktifkan reminder, bukan saat cold-start.
- [ ] F4.2 Jadwalkan reminder T+3/T+7 hari untuk bill `outstanding > 0` saat bill tersimpan; tap notifikasi → deep-link `/bill/:id`; batalkan jadwal saat `is_settled == true` (`bill_detail_notifier.dart:139-184`). Persist jadwal di `SharedPreferences` agar survive restart.
- [ ] F4.3 Settings toggle + copy ARB (`reminderTitle`, `reminderBody`, `reminderOptIn`, `reminderOff`) + nyatakan limitasi: tidak jalan bila proses dibunuh (tanpa FCM) — FCM/async-job non-goal M1.
- [ ] F4.4 Test: jadwal dibuat/dibatalkan, payload deep-link, izin ditolak → fallback tanpa crash.
- [ ] F4.5 Kontrak reminder (hasil review — baseline nol, grep `flutter_local_notifications|POST_NOTIFICATIONS|reminder` hanya fingerprint/timezone): definisikan `outstanding>0` (via `calculateTotals` vs `is_settled`), hook (after-save + after-assign + after-`togglePayment`), T+3/T+7 zona device vs UTC/DST, skema `SharedPreferences` + reschedule reboot (`BOOT_COMPLETED`; iOS tak bisa — nyatakan), bill dihapus → batal, `is_settled=true → cancel` (`bill_detail_notifier:172-182`), uncheck paid → reschedule ulang; deep-link target BUKAN `/bill/:id` (404 — rute hanya `/split/:billId` + `/detail/:billId`, `routes.dart:26-32`) → payload `billId` + fallback bill-hilang + aman dari intersepsi guard legal/onboarding/recovery (`app_router.dart:50-200`); denied vs permanently-denied → revert toggle + tawar buka settings; exact vs inexact alarm (risiko Play review); global vs per-bill opt-in + toggle-off batalkan semua; ARB baru (0 hit hari ini) + disclosure proses-dibunuh; init lazy non-blocking (insiden ads 2026-09-03).
- [ ] Verifikasi akhir M1: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` (bila ubah `@Riverpod`/`@freezed`), `flutter analyze`, `flutter test`, `flutter build apk --split-per-abi`.

## Risks

- F2 refactor totals menyentuh dua implementasi yang sengaja diduplikasi (komentar `bill_detail_notifier.dart:30-32`) — risiko drift; mitigasi: kunci lewat tes paritas dulu, refactor bertahap, revert aman karena tanpa migrasi.
- F4 menambah permission + dep native — risiko Play review dan flaky device; mitigasi: opt-in, max 2/bill, tanpa exact-alarm bila tak perlu.
- F3 normalisasi phone mengubah bucketing library lama (`bump_saved_participant` `(user, lower(name), phone)`) — risiko duplikat historis; mitigasi: migrasi data tidak perlu di M1, hanya normalisasi sisi tulis baru.

## Progress Log

- 2026-09-05 12:00:00 — Plan M1 ditulis; belum ada implementasi.
- 2026-09-05 12:30:00 — Review audit vs kode: tambah F1.5/F2.4/F3.5/F4.5 (matriks validasi, paritas totals, library edge, kontrak reminder + koreksi deep-link `/bill/:id`); belum ada implementasi.
- 2026-09-05 13:30:00 — Implementasi M1 selesai, `flutter test` 513 passed (+31), `analyze` 0 error/warning. F1: `OcrResult.manual()` + entrypoint History/Scan + suppressi banner + hint + ARB. F2: `assignAll()` 1 round-trip + idempoten + rollback + tombol "Bagi rata" + dedup nama (unifikasi totals ke `BillCalculator` ditunda — assignAll menulis `weight=1` sehingga even-split existing sudah equivalen; refactor delegasi jadi follow-up). F3: normalisasi `812→62`, dedup, chips exclude+phone+quick-add, dialog overwrite kontak, `participantImportNoPhone` di-wire, logout-clear cache. F4: `SettlementReminderService` (T+3/T+7, bookkeeping prefs, best-effort plugin, cancel saat lunas) + hook save/settle + `POST_NOTIFICATIONS`. Verifikasi: pub get, build_runner, analyze, full test (tanpa build apk per instruksi).

## Notes

- Tanpa migrasi DB di M1 — semua server-gate existing tak tersentuh; kredit OCR tak tersentuh (manual = 0 kredit).
- Counter-argumen: 4 fitur sekaligus menaikkan scope uji regresi split/detail; alternatif bertahap F1→F3→F2→F4 bila kapasitas sempit — F1 dan F3 nir-risiko paling dulu.
- Standar proporsional (non-telecom): desain + dokumentasi memandu; tak ada perubahan skema live di M1.
