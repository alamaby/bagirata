# Google Play Store Release Guide

The Android release build is configured for `compileSdk = 36` / `targetSdk = 36` with R8 minification and resource shrinking enabled. Use this guide to produce a Play-Store-ready App Bundle.

## 1. Generate the upload keystore

Run once:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep `upload-keystore.jks` and its passwords backed up offline. Losing it can block future updates under the same Play Store listing. `.gitignore` excludes `*.jks` and `key.properties`.

## 2. Wire the signing credentials

```bash
cp android/key.properties.example android/key.properties
# Edit android/key.properties and fill in storePassword, keyPassword.
```

## 3. Generate adaptive launcher icons

```bash
dart run flutter_launcher_icons
```

The current `assets/images/icon_launcher.png` is reused as both the legacy and adaptive-icon foreground. For best results on Android 8+ devices, replace it with a 1024x1024 PNG that has transparent padding before the first Play Store upload.

## 4. Build the App Bundle

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Verify the bundle is signed with the upload key, not the debug key:

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## 5. Smoke test on Android 16

```bash
flutter build apk --release
flutter install
```

Test on an emulator running API 36 and, ideally, a physical device. Verify:

- Sign-in with Supabase works.
- Google Sign-In works with the release/upload key fingerprint.
- Ads stay hidden when `ADS_ENABLED=false`.
- If `ADS_ENABLED=true`, consent flow and banner ads load on History and Settings only.
- Receipt camera capture succeeds.
- Gallery multi-image picker succeeds without broad media-read permission.
- OCR pipeline succeeds for camera and gallery images.
- Save bill, edit item, assign participant, settlement, and share flows work.
- Privacy Policy and Terms of Service screens open.
- No screen has content hidden behind the status bar or navigation bar.
- Predictive back gesture navigates correctly.

## 6. Build the AAB via GitHub Actions

Trigger the **Build Play Store AAB** workflow manually from the Actions tab. It uses `workflow_dispatch`.
For tagged releases, the **Release Android Artifacts** workflow also builds and
uploads a signed `bagistruk-vX.Y.Z.aab` to the Play Console `internal` track,
then attaches it alongside the split APKs in the GitHub Release.

Required repository secrets and variables:

| Kind | Name | Value |
|------|------|-------|
| Secret | `KEYSTORE_BASE64` | `base64 -w0 android/upload-keystore.jks` |
| Variable | `KEY_ALIAS` | `upload` or the alias used with `keytool` |
| Secret | `KEY_PASSWORD` | Key password |
| Secret | `STORE_PASSWORD` | Keystore password |
| Secret | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Raw JSON key for the Play Console service account used by the tagged release workflow upload |
| Variable | `SUPABASE_URL` | Supabase project URL |
| Secret | `SUPABASE_ANON_KEY` | Supabase anon key |
| Variable | `GOOGLE_WEB_CLIENT_ID` | Required. Google OAuth web client ID used as Android `serverClientId` and by Supabase auth |
| Variable | `GOOGLE_IOS_CLIENT_ID` | Google OAuth iOS client ID, required for iOS builds |
| Variable | `AUTH_EMAIL_REDIRECT_TO` | Optional; defaults to `bagistruk://auth/callback` for Supabase email verification/password reset links |
| Variable | `ADS_ENABLED` | `false` by default; set `true` only after AdMob production IDs and Play disclosures are ready |
| Variable | `ADMOB_ANDROID_BANNER_SCAN_ID` | Android AdMob banner unit ID for Scan screen, `ca-app-pub-4082765898994990/4091625538` |
| Variable | `ADMOB_ANDROID_BANNER_HISTORY_ID` | Android AdMob banner unit ID for History screen, `ca-app-pub-4082765898994990/2778543869` |
| Variable | `ADMOB_ANDROID_BANNER_SETTINGS_ID` | Android AdMob banner unit ID for Settings screen, `ca-app-pub-4082765898994990/1436552353` |
| Variable | `ADMOB_ANDROID_BANNER_ID` | Android AdMob banner unit ID (fallback if per-placement IDs not set), currently `ca-app-pub-4082765898994990/8733289141` |
| Variable | `ADMOB_IOS_BANNER_ID` | iOS AdMob banner unit ID (same fallback pattern if per-placement IDs are added later) |

Before smoke testing email sign-up or password reset, configure Supabase
Dashboard **Authentication -> URL Configuration**:

- **Site URL**: set a public URL such as `https://bagistruk.vercel.app`, not `localhost`.
- **Redirect URLs**: add `bagistruk://auth/callback`.
- If `AUTH_EMAIL_REDIRECT_TO` is overridden in GitHub/environment config, add that exact URL too.

Also configure Supabase Auth custom SMTP with Resend and copy the branded Auth
email templates from `supabase/templates/`. Follow
[`docs/supabase-auth-email.md`](supabase-auth-email.md) before running release
email sign-up QA.

Before smoke testing Google Sign-In on Android, confirm Google Cloud Console has
an Android OAuth client for package `com.alamaby.bagistruk` with the SHA-1 of
the exact installed build: debug keystore for `flutter run`, upload/release
keystore for locally signed release APKs, and Play app-signing certificate for
builds installed from Play testing tracks. A missing SHA can appear in-app as a
canceled sign-in immediately after account selection.

The manual Play Store workflow uploads the signed AAB as a workflow artifact with 30-day retention. Download it and upload manually to Play Console when you need an on-demand build outside tagged releases.

The Android workflows fail early when `SUPABASE_URL`, `SUPABASE_ANON_KEY`, or
`GOOGLE_WEB_CLIENT_ID` is missing from the generated `.env`. If Google Sign-In
shows `Missing required env var: GOOGLE_WEB_CLIENT_ID`, add
`GOOGLE_WEB_CLIENT_ID` under repository **Variables**, rebuild the AAB, and
upload the new artifact to Play Console.

The tagged release workflow also fails early when
`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is missing. Create this service account from
Play Console API access, grant it permission to manage releases for the app, and
store the raw JSON key as a repository secret.

## 7. Deploy Edge Functions

Deploy the server functions used by release builds:

```bash
supabase functions deploy process-receipt
supabase functions deploy delete-account
supabase functions deploy inactive-user-cleanup --no-verify-jwt
```

`delete-account` must keep JWT verification enabled because it deletes the currently authenticated user's data and Auth account. `inactive-user-cleanup` is intended for Supabase Cron and can be protected with `INACTIVE_CLEANUP_SECRET`.

## 8. Upload to Play Console

1. Go to **Play Console -> Internal testing** and upload `app-release.aab`.
2. Use package name `com.alamaby.bagistruk`.
3. Under **App content**:
   - Submit the public Privacy Policy URL: `https://bagistruk.vercel.app/privacy`.
   - Complete Data deletion questions and disclose the in-app path: **Profile & Settings -> Delete Account**.
   - If `ADS_ENABLED=true`, declare that the app contains ads. Declare Advertising ID while the build includes Google Mobile Ads/AdMob and the `AD_ID` permission. Android AdMob App ID is configured as `ca-app-pub-4082765898994990~1671692391`.
    - Complete the Data safety form for email, receipt photos, bill data, Supabase, Google Sign-In, OCR providers, Google Mobile Ads/AdMob if ads are enabled, and reminder email provider if enabled.
    - Declare the bill share-link flow: read-only snapshots (bill title, items, per-person totals, payment status) viewable without login via a 7-day expiring link; only the SHA-256 token hash is stored server-side; bank info and phone numbers are excluded; links are revocable from the bill detail screen. Reference `docs/privacy-policy.md` "Bill share-links" section.
   - Complete content rating, target audience, and app access declarations.
4. Promote to **Closed testing -> Production** once internal testing passes.

## 9. Store listing assets

Place final source assets under `docs/assets/play-store/` or another tracked docs folder:

- Feature graphic: 1024x500.
- Phone screenshots for scan, review, split, and settlement flows.
- Tablet screenshots if tablet support is part of the release target.
- Public Privacy Policy URL: `https://bagistruk.vercel.app/privacy`.
