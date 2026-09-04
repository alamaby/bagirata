# Legal & Compliance Release Checklist

## AdMob / Ad Privacy

- [x] European regulations message published in AdMob Privacy & messaging.
- [x] UMP SDK integrated: `requestConsentInfoUpdate()` called at app start.
- [x] UMP SDK integrated: `loadAndShowConsentFormIfRequired()` shown when required.
- [x] CMP disclosure added to Privacy Policy (Google UMP + IAB TCF v2.3).
- [x] Banner ads gated by `canRequestAds()` before loading.
- [x] Settings entry point for ad privacy choices available when UMP requires it.
- [ ] Manual QA: EEA debug geography test with fresh install — CMP message appears.
- [ ] Manual QA: Accept consent — banners load.
- [ ] Manual QA: Reject consent — non-personalized/limited ads served.
- [ ] Manual QA: Ad privacy choices tile visible in Settings for EEA test device.
- [ ] Manual QA: Tap tile opens Google privacy options form.
- [ ] Manual QA: Plus user sees no banners (existing behavior unchanged).
- [ ] Manual QA: Non-EEA user not blocked — no CMP form, no privacy tile.

## Privacy Policy

- [x] Effective date: 2026-09-04.
- [x] Google UMP / CMP disclosure added (EN + ID).
- [x] European regulations message mentioned.
- [x] IAB TCF v2.3 integration mentioned.
- [x] Non-personalized/limited ads fallback if consent denied.
- [x] Ad Privacy Choices section added (EN + ID).
- [x] Third-party services: UMP/AdMob entry updated.

## Terms of Service

- [x] Effective date: 2026-09-04.
- [x] Advertising and consent section added (EN + ID).
- [x] References Privacy Policy and UMP/CMP where applicable.
- [x] English Contact fixed from placeholder to real address.

## Landing Page

- [ ] `src/legalContent.ts` synced with app docs (effective date, CMP disclosure, ad privacy choices).
- [ ] `npm run build` passes in `bagistruk-landing-page`.

## Pre-Release

- [ ] `flutter pub get` passes.
- [ ] `flutter analyze` shows 0 errors.
- [ ] `flutter test` passes (excluding pre-existing SDK env issues).
- [ ] `flutter build apk --release --split-per-abi` passes.
