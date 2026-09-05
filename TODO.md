# BagiStruk TODO

Last reviewed: 2026-08-03 (Inactive-user-cleanup cron: verify_jwt off + rotated Vault secret + Vault-backed cron command. Backlog 121 akun anonymous terhapus; 1 kandidat `1b52c3a1-…` gagal karena `auth.users.confirmation_token/recovery_token/email_change_token_new = NULL` → GoTrue `Scan error … converting NULL to string` → user repair token via SQL → cron `active=true` menunggu run 02:00 UTC. Version 0.27.0+67.)

Severity:
- P0 Critical: release, legal, payment, security, data integrity blocker.
- P1 High: core flow bug atau release-quality risk.
- P2 Medium: quality, coverage, i18n, polish.
- P3 Low: deferred platform work atau exploration.

## P0 — Production Release, Compliance, dan Billing

### Post-Rollout — Legal Docs 2026-09-04 (TOP PRIORITY — rilis dulu, bump setelahnya)

- [ ] **Setelah rilis `0.29.1+74` rollout:** bump `app_config` `legal.terms_version` & `legal.privacy_version` `1 → 2` via Supabase Dashboard (MCP read-only — jangan bump sebelum rollout: aset `docs/*.md` ter-bundle, gate `LegalAcceptanceScreen` akan minta dokumen yang belum ada di app lama). SQL: `UPDATE app_config SET value = '2' WHERE key IN ('legal.terms_version','legal.privacy_version');` lalu verifikasi `SELECT key, value FROM app_config WHERE key LIKE 'legal.%';` — harus `2`/`2`. Detail: `plans/2026-09-04-legal-docs-refresh-plan.md:14,33`, `docs/privacy-policy.md:3,34,41,48,73`, `docs/terms-of-service.md:3,31`.
- [ ] Verifikasi post-bump: login user lama (Free/Plus/anonymous) → `LegalAcceptanceScreen` muncul → Accept → `profiles.accepted_terms_version` & `accepted_privacy_version = 2`. Cek Play Console Privacy Policy URL masih valid (host `docs/privacy-policy.md`).

### Operator — UNIQUE Participants Migration (TAHAN: commit lokal, belum push/apply)

- Konteks: `supabase` commit `3e30586` (file `migrations/20260905120000_participants_bill_name_unique.sql`) + parent `8177ded` (mapping 23505→duplicateName) + `32695c2` (deferred items) + patch `0.31.2+79`. Produksi terverifikasi 0 duplikat (92 baris). CLI Supabase di dev belum auth → apply via Dashboard.
- [x] **Urutan wajib:** push submodule DULU (`cd supabase && git push`), BARU push parent. (Selesai 2026-09-05.)
- [ ] Apply ke live via Dashboard SQL Editor (role postgres) isi file `supabase/migrations/20260905120000_participants_bill_name_unique.sql` apa adanya.
- [ ] Verifikasi: `\d participants` memuat `participants_bill_name_unique`; `SELECT bill_id, lower(trim(name)), COUNT(*) FROM participants GROUP BY 1,2 HAVING COUNT(*)>1;` → 0 baris.
- [ ] Sinkron: `supabase migration list` (atau Dashboard history) menunjukkan `20260905120000` applied; tidak ada drift vs remote history.
- [ ] Smoke: tambah 2 peserta nama sama beda casing di 1 bill → peserta ke-2 ditolak `billSplitDuplicateName`; tambah nama sama di bill lain → lolos.

### Google Play Policy 2026 July Cycle
- [x] Sebelum 2026-10-28, hapus `READ_CONTACTS` dan migrasikan import peserta ke Android Contact Picker. Jangan request akses buku kontak luas. (Selesai 2026-07-22: ganti `flutter_contacts` ke `flutter_native_contact_picker`, hapus permission dari manifest.)
- [x] Audit Data Safety Play Console: foto struk, kontak, email, user ID, purchase history, data finansial opsional, device ID/diagnostics, approximate location AdMob, dan app interactions. (Audit mapping selesai 2026-07-22; entry manual di Play Console pending.)
- [x] Tambah disclosure sebelum scan: foto struk dikirim ke layanan OCR AI pihak ketiga untuk ekstraksi item. (Selesai 2026-07-22: banner permanen di scan screen.)
- [x] Jangan aktifkan provider OCR baru sebelum Privacy Policy dan Data Safety diperbarui. (Privacy Policy diupdate 2026-07-22, effective date 2026-07-22.)
- [x] Verifikasi target API terbaru sebelum deadline Google Play 2026-08-31. (Selesai 2026-07-22: targetSdk = 36, compileSdk = 36 — ahead of requirement.)
- [ ] Verifikasi Android developer/package registration di Play Console sebelum 2026-09-30.

### Android signing dan Play Console
- [ ] Verifikasi release build selalu memakai upload keystore, bukan debug signing fallback.
  - Files: `android/app/build.gradle.kts`, `android/key.properties.example`, `.github/workflows/playstore.yml`.
- [ ] Generate upload keystore, simpan offline, dan isi GitHub secrets:
  `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.
- [ ] Build signed AAB dan upload ke internal testing.
  - Command: `flutter build appbundle --release`.
  - Output: `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Pastikan versionCode naik untuk setiap upload Play Console.
- [ ] Lengkapi Play Console Data safety.
  - Declare account/auth data, receipt images, bill data, ads data bila aktif, consent status, dan seluruh third-party processor.
  - Cocokkan dengan `docs/privacy-policy.md`.
- [ ] Lengkapi Play Console App content.
  - Privacy policy URL, data deletion path, ads, Advertising ID, app access, content rating, target audience.
- [ ] Konfigurasi production OAuth dan Supabase Auth.
  - Google Cloud OAuth package/fingerprint release.
  - Supabase Google provider, Site URL, Redirect URL `bagistruk://auth/callback`.
  - Custom SMTP Resend dan email template Supabase.
- [ ] Jalankan smoke test release Android.
  - Anonymous, email, Google sign-in, camera/gallery, OCR multi-photo, bill flow, deletion, legal screens, edge-to-edge.
- [ ] Review Privacy Policy dan Terms of Service secara legal sebelum production.

### Google Play Billing External Setup
- [ ] Aktifkan Google Play Billing sebelum paywall production.
- [ ] Buat produk wajib:
  - [ ] `bagistruk_plus_monthly`
  - [ ] `ocr_pack_50`
- [ ] Putuskan dan buat produk opsional bila akan dijual:
  - [ ] `bagistruk_plus_yearly`
  - [ ] `ocr_pack_150`
  - [ ] `ocr_pack_500`
- [ ] Set pricing, availability countries, tax/compliance, subscription offers, dan testing track.
- [ ] Hubungkan Play Console dengan Google Cloud project.
- [ ] Enable Google Play Android Developer API.
- [ ] Buat service account dan JSON key. Simpan hanya di secret manager/GitHub Actions/Supabase secrets.
- [ ] Beri service account izin Play Console untuk CI release dan purchase verification.
- [ ] Set `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` di GitHub Actions dan Supabase.
- [ ] Set `GOOGLE_PLAY_PACKAGE_NAME` di Supabase.
- [ ] Konfigurasi RTDN Pub/Sub dan backend reconciliation subscription/refund.
- [ ] Test purchase, restore, cancel, refund, grace period, account hold, consume, dan repurchase.

## P1 — Auth dan Release Quality

### Inactive User Cleanup Cron (2026-08-03)
- [x] Fix pipeline cleanup yang selalu HTTP 401 + `cron.job_run_details=succeeded` (false positive, hanya request ter-antre).
  - **Root cause (4 lapis)**: (1) fungsi ter-deploy `verify_jwt: true` → platform tolak POST tanpa JWT sebelum kode jalan; (2) `INACTIVE_CLEANUP_SECRET` kosong (digest sha256("")) → guard fail-open; (3) cron `timeout_milliseconds:=1000` → `pg_net` timeout 1s, response tak tertangkap; (4) secret cleanup hardcoded plaintext di `cron.job.command` tak cocok dgn secret fungsi.
  - **Fix**: rotasi secret (Vault `cron_function_secret` + env `INACTIVE_CLEANUP_SECRET` sinkron); redeploy `supabase functions deploy inactive-user-cleanup --no-verify-jwt` → `verify_jwt: false`. Migration `20260803120000_fix_inactive_cleanup_cron_vault_secret.sql` (submodule): cron baca `project_functions_url` + `cron_function_secret` dari Vault, hapus plaintext, tambah `Content-Type`, `timeout_milliseconds:=30000`, job dibuat `active=false`. Bug `supabase.rpc(...).catch(...)` invalid di supabase-js v2 → refactor `try/catch`. Secret cron.alter_job error `42501 must be owner` karena `COMMENT ON FUNCTION cron.schedule` (owner supabase_admin) — hapus baris COMMENT.
  - **Backlog**: smoke E2E hapus 121 akun anonymous, target `4e9f7788-…` terhapus. Sisa 1 kandidat.
- [x] Investigasi dan fix 1 kandidat gagal (`1b52c3a1-69a0-453c-9a69-0f4a35d3f57d`).
  - **Root cause**: `auth.users.confirmation_token/recovery_token/email_change_token_new = NULL` → GoTrue `sql: Scan error on column… converting NULL to string is unsupported` saat `DELETE /admin/users/<id>` (HTTP 500). Bukan FK/session/storage/trigger (semua reference count 0).
  - **Fix** (SQL Editor, role postgres): `UPDATE auth.users SET confirmation_token=COALESCE(confirmation_token,''), recovery_token=COALESCE(recovery_token,''), email_change_token_new=COALESCE(email_change_token_new,'') WHERE id='1b52c3a1-…' AND deleted_at IS NULL;`
  - **Verifikasi**: semua token kini NOT NULL; `deleted_at` masih NULL; tetap kandidat `delete_anonymous`; belum ada audit `anonymous_deleted` baru; **retry manual masih `error:"{}"`** → token fix tak cukup, investigasi lanjut belum tuntas.
- [ ] **Follow-up investigasi**: parse auth log pasca-repair untuk error baru; cek kolom nullable lain di `auth.users` yang di-scan GoTrue; bila perlu hard delete `delete from auth.users where is_anonymous is true and created_at < now()-interval '30 days'` (role postgres) atau `DELETE FROM auth.users WHERE id='1b52c3a1-…'` + cascade manual.
- [ ] **Follow-up verifikasi**: setelah kandidat terhapus → cek `deleted_at` + audit `anonymous_deleted` baru; pastikan backlog kosong (`list_inactive_user_cleanup_candidates` = 0).
- [ ] **Pertimbangkan hardening**: `refresh token rotation` pattern SIMD Untuk `cron` smoke tanpa perlu trigger. MCP apply_migration tak punya akses tulis `cron.job`; migrasi cron harus dijalankan manual di Dashboard SQL Editor (role postgres) — dokumentasikan di runbook.
- [ ] **Pertimbangkan**: pastikan secret lama tidak muncul di issue/chat/log (sudah dirotasi).
- [ ] Push submodule `68a4c17` + parent `2374348` ke remote (belum dilakukan).

### Email OTP 8 Digit + Mobile Deep-Link Redirect

- [x] Email OTP dari Supabase berisi 8 digit tapi layar verifikasi app hanya menerima 6 digit. Link fallback email mengarahkan ke `https://bagistruk.vercel.app` (landing page), bukan membuka app.
  - **Root cause**:
    - `lib/presentation/auth/screens/verify_otp_screen.dart` hardcoded `6` di validator + `LengthLimitingTextInputFormatter(6)` + hint `000000`. Supabase `{{ .Token }}` saat ini mengirim 8 digit (docs terbaru menyebut reauthentication eksplisit 8 digit, magic link/confirm signup ikut).
    - `lib/data/datasources/auth_remote_datasource.dart:sendEmailOtp()` memanggil `_auth.signInWithOtp(...)` tanpa `emailRedirectTo`. Tanpa parameter ini, Supabase fallback ke Site URL untuk `{{ .ConfirmationURL }}` (terlihat di URL: `redirect_to=https://bagistruk.vercel.app`). Allowlist `bagistruk://auth/callback` di Dashboard sudah benar dan custom scheme sudah terdaftar di Android/iOS, jadi blocker murni di Flutter call site.
  - **Fix**:
    - `lib/presentation/auth/screens/verify_otp_screen.dart` — `static const int _otpLength = 8` di `_VerifyOtpScreenState`, dipakai di validator, `LengthLimitingTextInputFormatter(_otpLength)`, hint `00000000`.
    - `lib/data/datasources/auth_remote_datasource.dart` — `sendEmailOtp()` kirim `emailRedirectTo: _authEmailRedirectTo` (env `AUTH_EMAIL_REDIRECT_TO`, default `bagistruk://auth/callback`).
    - `lib/l10n/app_id.arb` + `app_en.arb` — `verifyOtpBodyPrefix` & `verifyOtpInvalid` dari 6 digit ke 8 digit. Generated `lib/l10n/generated/app_l10n*.dart` diregenerasi `flutter pub get`.
    - `pubspec.yaml` — version `0.23.1+57` → `0.23.2+58` (bug fix, patch + build).
    - `plans/2026-07-25-fix-email-otp-8-digit-and-redirect-plan.md` (BARU) — plan + progress log.
  - **Verifikasi (rule 4)**:
    - `flutter pub get` — ok (l10n regenerated).
    - `flutter analyze` (full project) — tidak ada error/warning baru dari patch. Pre-existing: `test/performance_baselines.dart` signature mismatch dan `test/presentation/auth/widgets/auth_validators_test.dart` unused_import.
    - `flutter test` (full project) — 360/360 pass.
    - `flutter build apk --split-per-abi` — sukses (3 ABI APK).
- [ ] Manual QA release device: tap **Send email code** dengan email existing → input OTP 8 digit penuh, submit, login sukses. Klik link fallback email → URL mengandung `redirect_to=bagistruk%3A%2F%2Fauth%2Fcallback` dan membuka app via custom scheme (bukan landing page). Ulangi untuk email baru (template Confirm signup).
- [ ] Pastikan GitHub/Play Store build vars `AUTH_EMAIL_REDIRECT_TO=bagistruk://auth/callback` (override `.env.example` default tidak mengubah default Dashboard fallback Site URL behavior).

### Banner Ad Race Condition di Layar Scan
- [x] Banner AdMob di tab Scan tiba-tiba tidak tampil (sebelumnya bisa). Env dan unit ID tidak berubah, manifest tidak berubah, widget `BannerAdWidget(placement: scan)` masih terpasang di `lib/presentation/ocr/screens/receipt_capture_screen.dart:376`.
  - **Root cause**: race condition. `AdService.initialize()` dipindah ke background (`lib/main.dart` `_initAdsBestEffort()`) agar startup tidak freeze, tapi `BannerAdWidget.initState()` masih langsung `_load()`. Saat widget dibuat terlalu cepat, `AdService.canRequestAds()` masih `false`, lalu `_loadAd()` return permanen tanpa retry.
  - **Fix**: `lib/presentation/ads/widgets/banner_ad_widget.dart` — pecah early-return `canRequestAds`. Jika belum boleh request, log info dan panggil `_scheduleRetry()` (bounded 2s/8s/30s) alih-alih return tanpa jejak. `_scheduleRetry()` sekarang juga reset `_failedPermanently=false` di retry path supaya placeholder tetap stabil.
  - **Plan**: `plans/2026-07-25-fix-scan-banner-ad-race-condition-plan.md`.
  - **Verifikasi (rule 4)**:
    - `flutter pub get` — ok.
    - `flutter analyze` (full project) — tidak ada error/warning baru dari patch. Pre-existing issues di file lain.
    - `flutter test` (full project) — 360/360 pass.
    - `flutter build apk --split-per-abi` — sukses (3 ABI APK).
- [ ] Tambah widget/unit test untuk retry path `!canRequestAds` (saat ini sulit karena `google_mobile_ads` butuh platform channel). Pertimbangkan alternative readiness provider jika retry bounded masih gagal di device lambat.
- [ ] Manual QA cold start ke Scan: tunggu ~40s, cek log `BannerAd waiting for consent/ad readiness placement=scan attempt=...` lalu banner tampil / `BannerAd load failed placement=scan ...`.

### Email Confirmation Side Effects
- [x] Pindahkan `updateMarketingOptIn()` dan `markWelcomed()` agar tidak menulis `profiles` sebelum email confirmed.
  - Desain final: Option C — simpan pending action di `SharedPreferences`, eksekusi di router callback setelah `recoverSessionFromUri` sukses.
  - File baru: `lib/data/services/pending_registration_preferences.dart`, `lib/presentation/auth/providers/pending_registration_executor.dart`.
  - Provider: `pendingRegistrationExecutorProvider` (keepAlive).
  - RegisterScreen: simpan pending action, jangan langsung write profile.
  - Router: execute pending action di callback setelah email confirmation.
  - VerifyEmailScreen: clear pending action di `_cancel()`.
- [x] Pastikan sign-up tanpa klik email selama 7 hari tidak membuat `marketing_email_opt_in_at` atau `welcomed_at`.
  - Pending action punya TTL 7 hari di SharedPreferences.
  - Data profil baru tidak ditulis sampai email benar-benar dikonfirmasi.
- [x] Pastikan email confirmation membuat marketing consent dan welcome marker dengan source benar.
  - Executor pakai source `register_form` dan preferredLanguage dari pending.
  - MarkWelcomed dijalankan setelah marketing opt-in sukses (atau skip jika tidak opt-in).
- [x] Pastikan Google sign-in welcome flow tidak regress.
  - PostLoginWelcomeScreen tidak disentuh. Executor hanya jalan di router callback setelah `type!=recovery`.
- [x] Tambah test manual/automated untuk tiga flow tersebut.
  - Manual: sign-up, jangan klik email → cek DB. Setelah klik → cek DB.
  - Manual: Google sign-in → welcome screen tetap muncul. Email/password → welcome screen tidak muncul setelah confirm.

### Reset Password Deep-Link Redirect Loop
- [x] User klik link reset password dari email → app cold-start → app membuka Scan bukan `/reset-password`. Terjadi redirect loop: `/reset-password` → `/login?reason=reset_expired` → `/reset-password`.
   - **Root cause**:
     - `main.dart` memanggil `DeepLinkHandler.handleInitialLink()` sebelum `PasswordRecoverySession` dibuat dan diinjeksi. Initial link diproses tanpa recovery session, sehingga flag persisten tidak disetel.
     - `DeepLinkHandler` tidak menerima recovery session di konstruktor; menggunakan placeholder yang tidak mempersist flag.
     - Router menggunakan dua sumber keputusan recovery yang berbeda: `authRepository.isPasswordRecovery` (persisten, true) vs `AuthSnapshot.isPasswordRecovery` (stale, false). Guard `/reset-password` menggunakan snapshot stale lalu redirect ke `/login?reason=reset_expired`; guard recovery memaksa `/login` ke `/reset-password`. Loop terbentuk.
     - `recoverSessionFromUri()` memakai `otp_expired` sebagai tanda callback sudah diproses, sehingga token expired dinilai sukses dan menyalakan recovery flag.
     - __Round 2 (2026-07-28):__ Stale guard di `app_router.dart:199-206` menggunakan `snap?.isPasswordRecovery` masih ada meskipun guard baru di baris 113-126 sudah pakai `authRepository.isPasswordRecovery`. Guard lama ini tetap aktif sebagai source of loop.
   - **Fix (Round 1 — 2026-07-27)**:
     - `lib/main.dart` — buat `PasswordRecoverySession` sebelum `_bootstrap()`, inject ke `DeepLinkHandler.configure()` sebelum `handleInitialLink()`.
     - `lib/data/services/deep_link_handler.dart` — konstruktor butuh `PasswordRecoverySession`; `configure()` harus dipanggil sebelum `handleInitialLink()`. Placeholder `_BootstrapOnlyRecovery` hanya untuk test/edge-case.
     - `lib/data/datasources/auth_remote_datasource.dart` — `recoverSessionFromUri()` tidak lagi menganggap `otp_expired` sebagai sukses. Hanya menganggap double-consume sukses jika recovery flag sudah aktif DAN Supabase session ada. `otp_expired` → clear flag, propagate failure.
     - `lib/data/services/deep_link_handler.dart` — failure pada `getSessionFromUrl` clear recovery flag.
     - `lib/core/router/app_router.dart` — satukan keputusan recovery: gunakan `authRepository.isPasswordRecovery` sebagai single source of truth. Jika aktif → paksa `/reset-password` (kecuali sudah di sana). Jika tidak aktif + user di `/reset-password` → redirect ke `/login?reason=reset_expired`. Guard diletakkan sebelum legal/onboarding/paywall gates.
     - `lib/presentation/auth/screens/reset_password_screen.dart` — hapus widget-level redirect yang memakai `AuthSnapshot.isPasswordRecovery` stale. Router adalah single authority.
   - **Fix (Round 2 — 2026-07-28 — review remediation)**:
     - `lib/core/router/app_router.dart` — hapus stale guard di baris 199-206 yang masih memakai `snap?.isPasswordRecovery` (sudah di-handle oleh guard baru baris 121-125). Guard lama ini adalah sumber redirect loop yang tersisa.
     - `test/core/router/recovery_redirect_test.dart` — fix import `package:bagistruk/lib/...` jadi `package:bagistruk/...`. Ganti test dengan 11 pure-function test mencakup matrix redirect + loop-safety regression.
   - **Verifikasi (rule 4)**:
     - `flutter pub get` — ok.
     - `dart run build_runner build --delete-conflicting-outputs` — ok.
     - `flutter analyze` — clean (pre-existing issues unchanged, no new issues).
     - `flutter test` — 403/403 pass (sebelumnya 392, +11 redirect regression tests).
     - `flutter build apk --split-per-abi` — sukses (3 ABI APK).
  - **Plan**: `plans/2026-07-27-fix-reset-password-redirect-loop-plan.md`.
- [ ] Manual QA release device: tap **Reset Password** di Settings → confirm → buka email → klik link → pastikan app membuka `Buat Password Baru`, bukan Scan/Login. Simpan password valid → masuk Settings. Tutup dan buka app → tidak dipaksa ke reset screen. Klik link yang sama lagi → expired flow tanpa loop. Uji warm-start: app background saat link dibuka.

### Internal Testing Readiness
- [ ] Ganti launcher icon placeholder dengan adaptive icon final dan safe-zone/transparan padding.
- [ ] Siapkan Play Store listing: nama, short/full description, phone screenshot, tablet screenshot bila ditargetkan, feature graphic.
- [ ] Buat checklist manual QA per release.
- [ ] Putuskan apakah workflow `.github/workflows/playstore.yml` perlu auto-upload ke internal track.

### Static Analysis
- [x] Fix `deno check` pre-existing SupabaseClient type error di Edge Function `process-receipt/index.ts`. Ganti `ReturnType<typeof createClient>` dengan type alias `ServiceRoleSupabaseClient` yang cocok instance service-role. (Selesai 2026-07-13)

## P2 — Testing dan Maintainability

### Test Stabilization
- [x] Perbaiki 4 failure existing di `test/presentation/ocr/providers/scan_draft_notifier_test.dart`.
  - Root cause: `_createContainer(List<XFile>)` disalahartikan sebagai initial state, namun hanya mengatur fake result `pickMultiImage`. Test `removeAt`/`clear` tidak memanggil `pickFromGallery()` dulu sehingga state awal tetap kosong.
  - Fix: tambah `await notifier.pickFromGallery()` sebelum `removeAt`/`clear`. Tambah `addTearDown(container.dispose)` untuk keepAlive provider lifecycle.
  - Verifikasi: `flutter test test/presentation/ocr/providers/scan_draft_notifier_test.dart` — 13/13 pass.
- [x] Fix assertion IDR locale di `currency_formatter_test.dart`. `'Rp 12.345'` mengandung `.` sebagai thousand separator `id_ID`, bukan decimal. Assert diubah cek `decimalDigits` property.
- [x] Full suite: 349/349 pass (sebelumnya 312/313 dengan 1 pre-existing currency locale failure).
- [x] Full suite: 392/392 pass (setelah History amount-sort remediation, +21 history tests).

### Layer 2: Notifier dan State Tests
- [x] `SplitState`, `BillDetailState`, `BillReviewState` pure-state tests — sudah ada sebelum Plan.
- [x] `scan_draft_notifier_test.dart` — 13 test, stabil (sebelumnya 4 failure).
- [x] `OcrNotifier` tests — 6 test: idle state, success transition, failure, image count, hint/currency forwarding, reset.
- [x] `BillReviewNotifier` normalization/mutation tests — 11 test: title seeding, merchant fallback, thousands bug detection, currency snapshot, setters, add/remove item, mismatch tolerance.
- [x] `HistoryFilterNotifier` tests — 10 test: defaults, sort, payment status, currency, reset, isAmountSort, apply atomik.
- [x] `HistoryListNotifier` tests — 7 test: amount sort single-currency, explicit currency, multi-currency fallback, empty currencies fallback, invariant amount sort never reaches repo with null currency, loadMore preserves sort+currency, filter change triggers new first-page.
- [x] `HistoryFilterState.normalizeHistoryFilter` tests — 8 unit test di `history_screen_test.dart`: satu-currency, multi-currency, empty, non-amount, explicit, currency removal, payment status preserved.
- [x] `ImagePicker` sudah diabstraksi via `IImagePicker` — constructor injection tidak diperlukan.
- [x] Total: ~60 test (state + notifier).

### Layer 3: Repository Integration Tests (Fake-based)
- [x] 21 contract tests di `test/data/repositories/repository_contract_test.dart`:
  - `BillRepositoryImpl` — auth-before-upsert, failure propagation, DTO mapping, list immutability, exception mapping.
  - `OcrRepositoryImpl` — request forwarding, exact failure preservation.
  - `ProfileRepositoryImpl` — DTO+auth combine, opt-in ordering, anonymous skip, subscriber failure rollback, rollback failure safety.
  - `AuthRepositoryImpl` — property delegation, stream delegation, args forwarding, auth/edge-function exception mapping.
  - `AppConfigRepositoryImpl` — cache, concurrent coalescing, retry on failure, invalidate.
- [ ] `replaceAssignments` ordering test — deferred. Ordering (select items → delete → insert) ada di `BillRemoteDataSource`, butuh Supabase HTTP mock atau real integration.

### Layer 4: Widget Tests
- [x] `test/helpers/widget_test_harness.dart` — `buildTestApp()` dengan ScreenUtil + AppTheme + AppL10n, `setTestViewport()`.
- [ ] Widget screen coverage — scaffolding siap, test bisa ditambah bertahap (auth/shared/settings/OCR).

### Layer 5: Integration Tests
- [x] `integration_test/navigation_localization_test.dart` — scaffold dari parallel agent.
- [ ] Deterministic harness — butuh bootstrap yang bisa skip real Supabase/Auth/AdMob startup.

### Layer 6: Maestro Smoke Tests
- [x] `.maestro/config.yaml` + 8 flow: launch, legal-gate, navigation, language, currency, theme, history-empty, legal-documents. (Dari parallel agent.)
- [ ] Validasi dengan emulator/APK — butuh Android SDK dan emulator setup.

### CI
- [x] `.github/workflows/ci.yml` — Flutter quality pada PR/push: pub get, build_runner, generated drift check, analyze, test. (Dari parallel agent.)
- [x] `.github/workflows/maestro.yml` — manual/nightly, debug APK, emulator, Maestro suite, non-blocking. (Dari parallel agent.)

## P2 — Localization dan Visual Assets ✅ (Selesai 2026-07-23)

### Localization
- [x] Migrasikan semua hardcoded user-facing string ke ARB (diperluas dari 6 file ke ~17 file: auth, failure, bill review, bill split, bill detail, split summary, history, export CSV/PDF, settlement, main.dart, OCR visual).
  - `lib/presentation/bills/screens/bill_review_screen.dart` — Qty/Subtotal/Total.
  - `lib/presentation/bills/screens/bill_detail_screen.dart` — sudah localized (tidak ada hardcoded) + CSV exporter l10n param.
  - `lib/presentation/ocr/utils/ocr_messages.dart` — sudah pakai `AppL10n` (tidak berubah).
  - `lib/main.dart` — `_StartupErrorApp` pakai `AppL10n` via `_resolveStartupL10n()`.
  - `lib/presentation/bills/widgets/split_summary_sheet.dart` — Plus badge.
  - Auth: `auth_validators.dart`, `auth_text_field.dart`, `google_sign_in_button.dart`, `login_screen.dart`, `register_screen.dart`.
  - Shared: `failure_view.dart`.
  - Export: `bill_csv_exporter.dart`, `bill_pdf_exporter.dart`.
  - Settlement: `settlement_message_builder.dart` (brand prefix).
  - History: `history_screen.dart` (Plus + filter badge badges).
- [x] Update `lib/l10n/app_id.arb` dan `lib/l10n/app_en.arb` (~80 key baru + hapus `exportDocumentTitle`).
- [x] Jalankan `flutter pub get` / `flutter gen-l10n` untuk regenerate localization.
- [x] `flutter analyze` — clean. `flutter test` — 301/305 pass (4 pre-existing).

### OCR Visuals
- [x] Ganti empty-state receipt placeholder dengan ilustrasi final (`assets/images/ocr_empty_state.png`).
  - File: `lib/presentation/ocr/widgets/receipt_preview_component.dart`.
- [x] Scanning animation: `assets/lottie/scanning.json` existing dipertahankan per P2 scope.
- [x] Komentar TODO di Lottie overlay dihapus (diganti penjelasan status).

## P3 — Product Backlog

### Plus Features
- [ ] Excel/XLSX export per bill.
- [ ] Pertimbangkan batch multi-receipt sebagai Plus benefit.
- [ ] Attach original receipt image.
- [ ] Smart expense categories/tags.
- [ ] Permanent cloud sync dan cross-device backup/restore.
- [ ] Priority OCR retry/failover.

### Notifikasi Scan Selesai di Background
- [ ] Deteksi lifecycle Android saat user menekan Home atau meminimalkan aplikasi ketika OCR berjalan.
- [ ] Jika OCR selesai saat aplikasi tidak `resumed`, kirim local notification: “Scan selesai. Ketuk untuk melihat hasil.”
- [ ] Saat notifikasi diketuk, buka hasil scan atau halaman review terkait.
- [ ] Tambahkan permission `POST_NOTIFICATIONS` untuk Android 13+ dan alur permintaan izin yang kontekstual.
- [ ] Persist hasil OCR sementara agar hasil tetap tersedia saat aplikasi dibuka dari notifikasi.
- [ ] Evaluasi FCM + async server job untuk kondisi process aplikasi dibunuh Android. Local notification saja hanya bekerja selama process masih hidup.

### Monetization Exploration
- [ ] Evaluate one-time credit pack positioning after telemetry tersedia.
- [ ] Evaluate lightweight Personal Plus subscription pricing/benefits.
- [ ] Evaluate B2B workspace setelah personal product-market fit.
- [ ] Jangan lock core split-bill flow secara agresif.

### iOS Release Deferred
- [ ] Tambah `NSUserTrackingUsageDescription`.
- [ ] Tambah `PrivacyInfo.xcprivacy`.
- [ ] Ganti iOS AdMob test App ID dengan production ID.
- [ ] Siapkan App Store Connect, signing, provisioning, dan release checklist.
- [ ] Test UMP consent flow di iOS Simulator.

## Verification
- `flutter analyze` (3 infos only — pre-existing)
- `flutter test` (349 pass)
- `flutter build apk --split-per-abi`
- `flutter build appbundle --release` sebelum Play upload