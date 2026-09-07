# Privacy Policy — BagiStruk

**Effective date:** 2026-09-04

This policy explains how BagiStruk collects, uses, stores, and deletes data. This document is provided for product transparency and should be reviewed for legal compliance before publication.

## Summary

BagiStruk is a split-bill app that helps users scan receipts, extract bill items with OCR, and divide payments among participants. We collect only the data needed to provide these features. We do not sell personal data. If ads are enabled, we use Google Mobile Ads / AdMob to show ads and measure ad performance.

For users in the European Economic Area, the United Kingdom, and Switzerland, we use Google's User Messaging Platform (UMP) and AdMob's European regulations message — a Google-certified Consent Management Platform (CMP) integrated with the IAB Transparency and Consent Framework (TCF) v2.3. This message may ask for consent for cookies, SDK local storage, advertising identifiers, and the collection and use of personal data for personalized ads, in line with Google's EU User Consent Policy, the ePrivacy Directive, and the GDPR.

## Who We Are

The data controller for BagiStruk is:

**Alam Aby Bashit**
Komplek Kamarasan Residence A3/2 Kelurahan Buahbatu Kecamatan Bojongsoang
Bandung, 40287
Indonesia
**Email:** alam.aby.b@gmail.com

If you are in the European Economic Area, the address above also serves as our contact for the purposes of GDPR Art. 27 when you cannot reach us by email. You can always contact us at the email above regardless of your location.

For Indonesian users, you may lodge a complaint with the Ministry of Communication and Information Technology (KOMINFO) or with the Personal Data Protection Authority (Otoritas Pelindungan Data Pribadi, OPDP) once it becomes operational. The list of EEA supervisory authorities is available at https://edpb.europa.eu/about-edpb/about-edpb/members_en.

## Data We Collect

- Account data: email address, authentication identifiers, and sign-in provider information when you create or use an account.
- Anonymous session data: an anonymous Supabase user ID may be created when you use features that require saving data.
- Google Sign-In data: when you sign in with Google, we receive authentication tokens from Google through Supabase Auth. We do not receive your Google password.
- Profile preferences: display name, default currency, language preference, and theme preference.
- App activity metadata: `last_active_at`, used to understand when an account was last active and to support inactivity cleanup.
- Receipt photos: images you choose, capture, or share from other apps via the Android share sheet (Share → Scan receipt) for OCR processing.
- Bill data: merchant names, receipt dates, items, quantities, prices, taxes, service charges, participants, split assignments, settlement status, deleted-bill recovery metadata, exports generated on device, and optional transfer bank information used in settlement messages.
- **Participant contact info**: when you import a participant using the Android system Contact Picker, only the name and phone number of the single contact you explicitly select are stored on our server as part of the bill. We do not access, read, or upload your full address book. No contacts permission is required.
- **Bill share-links**: when you create a share-link for a bill, we store only a SHA-256 hash of an opaque token plus its expiry (7 days) — never the raw link. Anyone opening the link sees a read-only snapshot (bill title, items, per-person totals, payment status) without logging in. The snapshot excludes bank transfer info and phone numbers. You can disable a link at any time from the bill detail screen, which immediately invalidates it.
- OCR credit data: plan/entitlement status, Plus trial start/end/consumption metadata, monthly credit grants, credit usage, and audit records needed to enforce scan limits and feature access.
- Google Play Billing data when purchases are available: product IDs, purchase tokens, order IDs, subscription status/expiry, and verification responses needed to grant Plus access or OCR credit packs.
- Support and reminder data: email address and inactivity reminder timestamps when reminders are sent.
- Operational alert data: limited diagnostic details such as request ID, user ID, OCR provider, model, currency, hint, error status, and error message may be sent to the operator by email when OCR provider configuration, quota, or service issues need attention.
- Basic technical data sent by app/framework/network services, such as device and request metadata needed for diagnostics and security. For anonymous anti-abuse, we compute a server-side HMAC hash from coarse, non-PII request signals — Android release version, SDK level, brand, model, hardware, screen size in logical pixels, device pixel ratio, and time-zone name (falling back to IP address, user agent, client info, and accept-language when those signals are unavailable). We store only the hash; we do not store the raw IP address or raw device signals for this purpose.
- Advertising data when ads are enabled: advertising identifiers such as the Android Advertising ID, device/ad interaction data, approximate location inferred by ad services, and consent status used by Google Mobile Ads / AdMob for ad delivery, frequency capping, fraud prevention, and measurement.

## Permissions Used

- **Camera**: to capture receipt photos.
- **Photos / media access**: to pick receipt photos from the gallery.
- **Shared images (no permission required)**: when you share images to BagiStruk from another app (Share → Scan receipt), Android delivers those images to the app via the `SEND` / `SEND_MULTIPLE` share intent. Only the images you explicitly share are received; no broad media-read permission is needed for this flow.
- **Contacts** (no permission required): when you tap "Import from contacts" while adding a participant, the Android system Contact Picker opens. We receive only the name and phone number of the single contact you explicitly select. We do not access, read, or store your full address book. No `READ_CONTACTS` permission is requested.
- **Notifications** (`POST_NOTIFICATIONS`, Android 13+): to deliver local settlement reminders for bills that are still unsettled (3 and 7 days after a bill is saved). The notification shows only the bill title and total, is created on-device, and is never sent to our servers. Permission is requested contextually when the first bill is saved — never at app startup — and you can revoke it any time in Android system settings.
- **Internet / network state**: to communicate with Supabase and OCR services.

## How We Use Data

- To authenticate users and keep sessions active.
- To process receipt photos and extract bill information, including images you share from other apps via the Android share sheet.
- To save, display, edit, split, settle, share, export, delete, and restore bills when the feature is available.
- To let bill owners share a time-limited read-only link so participants without an account can view their share; resolving a link stamps an anonymous view timestamp used only for link lifecycle display.
- To preserve anonymous data when a user upgrades to a registered account.
- To enforce OCR credit limits and feature access, including anonymous, Free, Plus, history windows, export access, deleted-bill recovery, per-bill currency override, transfer bank information, and monthly insights.
- To grant and enforce one-time Plus trials for eligible registered users, including recording when a trial starts, ends, and has been consumed.
- To verify Google Play purchases server-side and grant Plus subscriptions or one-time OCR credit packs.
- To store user preferences and personalize the app.
- To track last activity for account retention and cleanup.
- To send inactivity reminders to registered users before account cleanup.
- To schedule on-device settlement reminders for unsettled bills; reminders are cancelled automatically when the bill is settled or deleted.
- To show ads, measure ad performance, prevent ad fraud, and respect consent choices when ads are enabled. If you do not consent to personalized ads where required, Google Mobile Ads / AdMob may serve non-personalized or limited ads where supported.
- To fill in a participant's name and phone number from the single contact you choose via the optional "Import from contacts" feature, and to generate WhatsApp deep-links in settlement messages when the bill owner shares them.
- To diagnose errors, prevent abuse, and enforce database rate limits.

## Legal Basis For Processing

We process your personal data on the following legal bases, in line with Article 6 of the EU General Data Protection Regulation (GDPR) and equivalent provisions of the Indonesian Personal Data Protection Law (UU No. 27/2022, "UU PDP"):

- **Account data, authentication, and bill data** — to perform the contract you entered with us by creating an account (Art. 6(1)(b) GDPR / Pasal 23 UU PDP).
- **Receipt photos and OCR processing** — with your explicit consent each time you submit a scan (Art. 6(1)(a) GDPR). Scans submitted before withdrawal of consent will have been processed.
- **Marketing emails and promotional communications** — with your prior opt-in consent only (Art. 6(1)(a) GDPR / Pasal 23 UU PDP). The opt-in and welcome marker are recorded only after you confirm your email address. You can withdraw this consent at any time from Profile & Settings, or via the unsubscribe link in any marketing email we send.
- **Personalized advertising** — with your consent given through Google's User Messaging Platform (UMP) when required by applicable law (Art. 6(1)(a) GDPR / ePrivacy Directive). We do not personalize ads for users who do not give consent.
- **Basic technical, security, and anti-abuse data** — on the basis of our legitimate interest in keeping the service secure and preventing abuse (Art. 6(1)(f) GDPR).
- **Inactivity reminders and account cleanup notifications** — on the basis of our legitimate interest in keeping account records accurate (Art. 6(1)(f) GDPR).
- **Operational alerts about OCR provider issues** — on the basis of our legitimate interest in operating a reliable service (Art. 6(1)(f) GDPR).

## Storage And Processing

App data is stored in Supabase, including authentication data and PostgreSQL database records. Receipt images are processed by Supabase Edge Functions. OCR processing may call third-party AI/OCR providers such as Google Gemini, OpenRouter, Nvidia NIM, and Ollama. **Receipt photos are sent to these providers for text extraction; images are processed transiently and are not stored by these providers.** API keys for those providers are stored server-side and are not bundled into the mobile app.

## Third-Party Services

BagiStruk may use:

- Supabase: authentication, database, row-level security, Edge Functions, and scheduled cleanup.
- Google Sign-In: optional account login.
- Google Gemini, OpenRouter, Nvidia NIM, and/or Ollama: OCR and receipt parsing.
- Resend or another email provider: inactivity reminder emails and operational OCR provider alerts, if configured.
- Google User Messaging Platform (UMP) / AdMob: Google-certified CMP, optional ad delivery, ad measurement, fraud prevention, and consent/privacy messaging via the European regulations message, integrated with IAB TCF v2.3.
- Google Play Billing / Google Play Developer API: purchase processing and server-side purchase verification for subscriptions and one-time OCR credit packs.

## International Data Transfers

Your data may be transferred to and processed in countries other than your country of residence. The main destinations are:

- **United States** — for Google services (Sign-In, Play Billing, Mobile Ads, Gemini), OpenRouter, Nvidia NIM, and Ollama OCR processing.
- **European Economic Area or other Supabase regions** — for authentication, database, and Edge Functions, depending on your Supabase project's configured region.

When we transfer personal data outside the European Economic Area, we rely on safeguards such as the European Commission's Standard Contractual Clauses (SCCs), the EU-U.S. Data Privacy Framework (where applicable), or equivalent contractual protections. A copy of the relevant safeguards can be requested by contacting us.

Under Indonesian law (UU PDP Pasal 56), cross-border transfers are subject to requirements of adequate protection in the destination country or explicit consent from the data subject. Where required, we obtain such consent at the time of account creation.

## Account Retention And Deletion

- Anonymous users may be deleted after 30 days of inactivity.
- Registered Free users may receive an inactivity reminder after 6 months of inactivity.
- If a registered Free user remains inactive for 30 days after the reminder, the account may be deleted.
- Registered users with an active Plus entitlement are excluded from inactivity cleanup while the entitlement remains active.
- When Plus entitlement ends, the inactivity window for cleanup is counted from the later of the user's last app activity and the latest Plus entitlement end time.
- When an inactive user is deleted, bills owned by that user are deleted first, then the authentication user is deleted.
- If a user opens the app after receiving a reminder, the pending deletion state is reset.
- You can delete your account and associated app data from **Profile & Settings > Delete Account** in the app.

You may also request account and data deletion by contacting us at the email below or through the public privacy page: https://bagistruk.vercel.app/privacy

## Security

We rely on Supabase authentication, row-level security, server-side API keys, and database policies to protect user data. No system is perfectly secure, but we take reasonable steps to limit access and reduce exposure.

## Data Breach Notification

In the event of a personal data breach that is likely to result in a high risk to your rights and freedoms, we will:

- Notify the relevant supervisory authority (the data protection authority in your jurisdiction) within 72 hours of becoming aware of the breach, as required by GDPR Art. 33.
- Notify affected users without undue delay, as required by GDPR Art. 34, when the breach poses a high risk to their rights.
- For users in Indonesia, notify the Personal Data Protection Authority (Otoritas Pelindungan Data Pribadi) and affected users within 3 x 24 hours of becoming aware, as required by UU PDP Pasal 46.

The notification will describe the nature of the breach, the categories and approximate number of affected users, the likely consequences, and the measures taken or proposed to address it.

## Your Rights

Subject to applicable law, you have the following rights regarding your personal data:

- **Right of access (GDPR Art. 15 / UU PDP Pasal 7)** — to request a copy of the personal data we hold about you.
- **Right to rectification (GDPR Art. 16 / UU PDP Pasal 8)** — to correct inaccurate or incomplete data. Most profile fields can be updated from Profile & Settings; bill fields can be edited in the app.
- **Right to erasure / right to be forgotten (GDPR Art. 17 / UU PDP Pasal 9)** — to request deletion of your account and associated data from Profile & Settings, or by contacting us.
- **Right to restriction of processing (GDPR Art. 18)** — to request that we limit how we use your data in certain circumstances.
- **Right to data portability (GDPR Art. 20 / UU PDP Pasal 11)** — to receive your data in a structured, commonly used, machine-readable format. Bills and their data can be exported as PDF and CSV from the app.
- **Right to object (GDPR Art. 21)** — to object to processing based on legitimate interest, including profiling related to direct marketing.
- **Right to withdraw consent (GDPR Art. 7(3) / UU PDP Pasal 25)** — to withdraw any consent you have given, at any time, without affecting the lawfulness of processing before withdrawal. Marketing opt-in can be withdrawn from Profile & Settings.
- **Right to lodge a complaint** — with your local data protection authority (for EEA residents; see https://edpb.europa.eu/about-edpb/about-edpb/members_en), or with KOMINFO / the Personal Data Protection Authority (for Indonesian residents).
- **Right not to be subject to automated decision-making (GDPR Art. 22)** — BagiStruk does not make decisions based solely on automated processing that produce legal or similarly significant effects on you.

To exercise any of these rights, contact us at **alam.aby.b@gmail.com**. We will respond within 30 days, or earlier if required by local law. We may need to verify your identity before acting on the request.

## Children

BagiStruk is not intended for children under **13 years of age** (the threshold under the US Children's Online Privacy Protection Act, COPPA), or under the age required by your local law to consent to digital services (16 in most of the European Economic Area by default, 18 in Indonesia under the Civil Code, or younger if your country's law allows consent at a lower age with parental approval).

We do not knowingly collect personal data from children below the applicable age threshold. If you believe a child has provided personal data to us, contact us at **alam.aby.b@gmail.com** so we can review, delete the data, and close the account. Where required by law, we will obtain verifiable parental consent before processing the child's data.

## Changes

We may update this policy from time to time. The latest version should be made available in the app and on the public page hosting this document. Where consent is required for processing changes, we will ask for fresh consent through our CMP.

## Ad Privacy Choices

If you are in a region that requires consent for personalized ads, the app will show a Google consent message the first time you launch it. You can also review or change your ad privacy choices at any time from **Profile & Settings** in the app. Outside these regions, the ad privacy entry point is hidden.

## Contact

For privacy questions, deletion requests, or to exercise your data protection rights, contact us:

**Email:** alam.aby.b@gmail.com

**Postal address (also our EEA Art. 27 contact):**
Alam Aby Bashit
Komplek Kamarasan Residence A3/2 Kelurahan Buahbatu Kecamatan Bojongsoang
Bandung, 40287
Indonesia

---

# Kebijakan Privasi — BagiStruk

**Tanggal berlaku:** 2026-09-04

Kebijakan ini menjelaskan bagaimana BagiStruk mengumpulkan, menggunakan, menyimpan, dan menghapus data. Dokumen ini disediakan untuk transparansi produk dan sebaiknya ditinjau kembali untuk kepatuhan hukum sebelum dipublikasikan.

## Ringkasan

BagiStruk adalah aplikasi pembagi tagihan yang membantu pengguna memindai struk, mengekstrak item tagihan dengan OCR, dan membagi pembayaran antar peserta. Kami hanya mengumpulkan data yang diperlukan agar fitur aplikasi berjalan. Kami tidak menjual data pribadi. Jika iklan diaktifkan, kami memakai Google Mobile Ads / AdMob untuk menampilkan iklan dan mengukur performa iklan.

Untuk pengguna di Wilayah Ekonomi Eropa, Inggris Raya, dan Swiss, kami menggunakan Google User Messaging Platform (UMP) dan pesan European regulations AdMob — sebuah Consent Management Platform (CMP) tersertifikasi Google yang terintegrasi dengan IAB Transparency and Consent Framework (TCF) v2.3. Pesan ini dapat meminta persetujuan untuk cookie, penyimpanan lokal SDK, identifier iklan, serta pengumpulan dan penggunaan data pribadi untuk iklan yang dipersonalisasi, sesuai Google EU User Consent Policy, ePrivacy Directive, dan GDPR.

## Siapa Kami

Pengontrol data untuk BagiStruk adalah:

**Alam Aby Bashit**
Komplek Kamarasan Residence A3/2 Kelurahan Buahbatu Kecamatan Bojongsoang
Bandung, 40287
Indonesia
**Email:** alam.aby.b@gmail.com

Jika Anda berada di Wilayah Ekonomi Eropa, alamat di atas juga berfungsi sebagai kontak kami untuk keperluan Pasal 27 GDPR saat Anda tidak dapat menghubungi kami melalui email. Anda selalu dapat menghubungi kami di email di atas dari mana pun.

Untuk pengguna di Indonesia, Anda dapat mengajukan keluhan ke Kementerian Komunikasi dan Informatika (KOMINFO) atau Otoritas Pelindungan Data Pribadi (OPDP) setelah badan tersebut beroperasi. Daftar otoritas pengawas EEA tersedia di https://edpb.europa.eu/about-edpb/about-edpb/members_en.

## Data Yang Kami Kumpulkan

- Data akun: alamat email, identifier autentikasi, dan informasi penyedia login saat Anda membuat atau menggunakan akun.
- Data sesi anonim: ID pengguna anonim Supabase dapat dibuat saat Anda memakai fitur yang perlu menyimpan data.
- Data Google Sign-In: saat Anda login dengan Google, kami menerima token autentikasi melalui Supabase Auth. Kami tidak menerima password Google Anda.
- Preferensi profil: nama tampilan, mata uang default, bahasa, dan tema.
- Metadata aktivitas aplikasi: `last_active_at`, digunakan untuk mengetahui kapan akun terakhir aktif dan mendukung pembersihan akun tidak aktif.
- Foto struk: gambar yang Anda pilih, ambil, atau bagikan dari aplikasi lain melalui share sheet Android (Share → Scan receipt) untuk pemrosesan OCR.
- Data tagihan: nama merchant, tanggal struk, item, jumlah, harga, pajak, service, peserta, pembagian item, status pembayaran, metadata pemulihan bill terhapus, export yang dibuat di perangkat, dan info bank transfer opsional untuk pesan settlement.
- **Info kontak peserta**: ketika Anda mengimpor peserta menggunakan Android system Contact Picker, hanya nama dan nomor telepon dari satu kontak yang Anda pilih secara eksplisit yang disimpan di server kami sebagai bagian dari tagihan. Kami tidak mengakses, membaca, atau mengunggah buku alamat lengkap Anda. Tidak diperlukan izin kontak.
- **Link berbagi tagihan**: saat Anda membuat link berbagi untuk sebuah tagihan, kami hanya menyimpan hash SHA-256 dari token acak beserta masa berlakunya (7 hari) — bukan link mentahnya. Siapa pun yang membuka link melihat ringkasan read-only (judul tagihan, item, total per orang, status bayar) tanpa perlu login. Ringkasan tidak memuat info bank transfer maupun nomor telepon. Anda dapat mematikan link kapan saja dari layar detail tagihan dan link langsung tidak berlaku.
- Data credit OCR: status plan/entitlement, metadata mulai/akhir/pemakaian trial Plus, grant credit bulanan, penggunaan credit, dan audit yang dibutuhkan untuk menerapkan batas scan dan akses fitur.
- Data Google Play Billing saat pembelian tersedia: product ID, purchase token, order ID, status/expiry subscription, dan respons verifikasi yang dibutuhkan untuk memberi akses Plus atau paket credit OCR.
- Data dukungan dan reminder: alamat email dan timestamp reminder tidak aktif saat reminder dikirim.
- Data alert operasional: detail diagnostik terbatas seperti request ID, user ID, penyedia OCR, model, currency, hint, status error, dan pesan error dapat dikirim ke operator melalui email saat masalah konfigurasi, quota, atau layanan penyedia OCR perlu ditangani.
- Data teknis dasar dari app/framework/network service, seperti metadata perangkat dan request yang dibutuhkan untuk diagnostik dan keamanan. Untuk anti-abuse pengguna anonim, kami menghitung hash HMAC sisi server dari sinyal request terbatas yang non-PII — versi rilis Android, level SDK, brand, model, hardware, ukuran layar dalam logical pixel, device pixel ratio, dan nama zona waktu (dengan fallback ke alamat IP, user agent, info klien, dan accept-language bila sinyal tersebut tidak tersedia). Kami hanya menyimpan hash-nya; kami tidak menyimpan alamat IP mentah atau sinyal perangkat mentah untuk tujuan ini.
- Data iklan saat iklan diaktifkan: identifier iklan seperti Android Advertising ID, data perangkat/interaksi iklan, perkiraan lokasi yang disimpulkan layanan iklan, dan status consent yang digunakan Google Mobile Ads / AdMob untuk penayangan iklan, pembatasan frekuensi, pencegahan fraud, dan pengukuran.

## Izin Yang Digunakan

- **Kamera**: untuk mengambil foto struk.
- **Akses foto / media**: untuk memilih foto struk dari galeri.
- **Gambar yang dibagikan (tidak perlu izin)**: ketika Anda membagikan gambar ke BagiStruk dari aplikasi lain (Share → Scan receipt), Android mengirimkan gambar tersebut ke aplikasi melalui share intent `SEND` / `SEND_MULTIPLE`. Hanya gambar yang Anda bagikan secara eksplisit yang diterima; tidak diperlukan izin baca media yang luas untuk alur ini.
- **Kontak** (tidak perlu izin): ketika Anda memilih "Import dari kontak" saat menambahkan peserta, Android system Contact Picker akan terbuka. Kami hanya menerima nama dan nomor telepon dari satu kontak yang Anda pilih secara eksplisit. Kami tidak mengakses, membaca, atau menyimpan buku alamat lengkap Anda. Izin `READ_CONTACTS` tidak diminta.
- **Notifikasi** (`POST_NOTIFICATIONS`, Android 13+): untuk menampilkan pengingat settlement lokal atas tagihan yang belum lunas (3 dan 7 hari setelah tagihan disimpan). Notifikasi hanya menampilkan judul dan total tagihan, dibuat di perangkat, dan tidak pernah dikirim ke server kami. Izin diminta secara kontekstual saat tagihan pertama disimpan — tidak pernah saat aplikasi dibuka — dan dapat dicabut kapan saja di pengaturan sistem Android.
- **Internet / status jaringan**: untuk berkomunikasi dengan Supabase dan layanan OCR.

## Cara Kami Menggunakan Data

- Mengautentikasi pengguna dan menjaga sesi tetap aktif.
- Memproses foto struk dan mengekstrak informasi tagihan, termasuk gambar yang Anda bagikan dari aplikasi lain melalui share sheet Android.
- Menyimpan, menampilkan, mengedit, membagi, menyelesaikan, membagikan, mengekspor, menghapus, dan memulihkan tagihan saat fitur tersedia.
- Memungkinkan pemilik tagihan membagikan link read-only berbatas waktu agar peserta tanpa akun bisa melihat bagiannya; pembukaan link mencatat timestamp kunjungan anonim yang hanya dipakai untuk siklus hidup link.
- Mempertahankan data anonim saat pengguna upgrade ke akun terdaftar.
- Menerapkan batas credit OCR dan akses fitur, termasuk batas pengguna anonim, Free, Plus, jendela History, akses export, pemulihan bill terhapus, penggantian currency per bill, info bank transfer, dan insight bulanan.
- Memberikan dan menerapkan trial Plus satu kali untuk pengguna terdaftar yang memenuhi syarat, termasuk mencatat kapan trial mulai, berakhir, dan sudah digunakan.
- Memverifikasi pembelian Google Play dari sisi server dan memberi subscription Plus atau paket credit OCR sekali beli.
- Menyimpan preferensi pengguna dan menyesuaikan pengalaman aplikasi.
- Melacak aktivitas terakhir untuk retensi dan pembersihan akun.
- Mengirim reminder tidak aktif kepada pengguna terdaftar sebelum pembersihan akun.
- Menjadwalkan pengingat settlement di perangkat untuk tagihan yang belum lunas; pengingat dibatalkan otomatis saat tagihan lunas atau dihapus.
- Menampilkan iklan, mengukur performa iklan, mencegah fraud iklan, dan menghormati pilihan consent saat iklan diaktifkan. Jika Anda tidak menyetujui iklan yang dipersonalisasi di wilayah yang mewajibkan, Google Mobile Ads / AdMob dapat menayangkan iklan non-personalized atau limited ads jika didukung.
- Mengisi nama dan nomor peserta dari satu kontak yang Anda pilih lewat fitur opsional "Import dari kontak", dan membuat deep-link WhatsApp di pesan settlement ketika pemilik tagihan membagikannya.
- Mendiagnosis error, mencegah penyalahgunaan, dan menerapkan rate limit database.

## Dasar Hukum Pemrosesan

Kami memproses data pribadi Anda berdasarkan dasar hukum berikut, sesuai Pasal 6 GDPR (Uni Eropa) dan ketentuan setara UU No. 27/2022 tentang Pelindungan Data Pribadi ("UU PDP"):

- **Data akun, autentikasi, dan data tagihan** — untuk pelaksanaan kontrak yang Anda sepakati saat membuat akun (Pasal 6(1)(b) GDPR / Pasal 23 UU PDP).
- **Foto struk dan pemrosesan OCR** — dengan persetujuan eksplisit Anda setiap kali Anda mengirim pindaian (Pasal 6(1)(a) GDPR). Pindaian yang dikirim sebelum penarikan persetujuan tetap akan diproses.
- **Email promosi dan komunikasi pemasaran** — hanya dengan persetujuan opt-in Anda (Pasal 6(1)(a) GDPR / Pasal 23 UU PDP). Opt-in dan penanda welcome dicatat hanya setelah Anda mengonfirmasi alamat email. Anda dapat menarik persetujuan ini kapan saja dari Profil & Pengaturan, atau melalui link unsubscribe di email pemasaran apa pun.
- **Iklan yang dipersonalisasi** — dengan persetujuan Anda melalui Google User Messaging Platform (UMP) bila diwajibkan hukum yang berlaku (Pasal 6(1)(a) GDPR / ePrivacy Directive). Kami tidak mempersonalisasi iklan untuk pengguna yang tidak memberikan persetujuan.
- **Data teknis, keamanan, dan anti-penyalahgunaan** — berdasarkan kepentingan sah kami untuk menjaga layanan tetap aman dan mencegah fraud (Pasal 6(1)(f) GDPR).
- **Reminder tidak aktif dan notifikasi pembersihan akun** — berdasarkan kepentingan sah kami dalam memelihara catatan akun yang akurat (Pasal 6(1)(f) GDPR).
- **Alert operasional tentang masalah penyedia OCR** — berdasarkan kepentingan sah kami dalam mengoperasikan layanan yang andal (Pasal 6(1)(f) GDPR).

## Penyimpanan Dan Pemrosesan

Data aplikasi disimpan di Supabase, termasuk data autentikasi dan record database PostgreSQL. Foto struk diproses oleh Supabase Edge Functions. Pemrosesan OCR dapat memanggil penyedia AI/OCR pihak ketiga seperti Google Gemini, OpenRouter, Nvidia NIM, dan Ollama. **Foto struk dikirim ke penyedia tersebut untuk ekstraksi teks; gambar diproses secara sementara dan tidak disimpan oleh penyedia tersebut.** API key untuk layanan tersebut disimpan di sisi server dan tidak dibundel ke aplikasi mobile.

## Layanan Pihak Ketiga

BagiStruk dapat menggunakan:

- Supabase: autentikasi, database, row-level security, Edge Functions, dan scheduled cleanup.
- Google Sign-In: login akun opsional.
- Google Gemini, OpenRouter, Nvidia NIM, dan/atau Ollama: OCR dan parsing struk.
- Resend atau penyedia email lain: email reminder tidak aktif dan alert operasional penyedia OCR, jika dikonfigurasi.
- Google User Messaging Platform (UMP) / AdMob: CMP tersertifikasi Google, penayangan iklan opsional, pengukuran iklan, pencegahan fraud, dan pesan consent/privasi melalui European regulations message, terintegrasi dengan IAB TCF v2.3.
- Google Play Billing / Google Play Developer API: pemrosesan pembelian dan verifikasi pembelian sisi server untuk subscription dan paket credit OCR sekali beli.

## Transfer Data Lintas Negara

Data Anda dapat ditransfer dan diproses di negara selain negara tempat tinggal Anda. Tujuan utama:

- **Amerika Serikat** — untuk layanan Google (Sign-In, Play Billing, Mobile Ads, Gemini), OpenRouter, Nvidia NIM, dan pemrosesan OCR Ollama.
- **Wilayah Ekonomi Eropa atau region Supabase lain** — untuk autentikasi, database, dan Edge Functions, tergantung region project Supabase Anda.

Ketika kami mentransfer data pribadi keluar dari Wilayah Ekonomi Eropa, kami mengandalkan perlindungan seperti Standard Contractual Clauses (SCC) dari European Commission, EU-U.S. Data Privacy Framework (bila berlaku), atau perlindungan kontraktual setara. Salinan perlindungan relevan dapat diminta dengan menghubungi kami.

Berdasarkan UU PDP Pasal 56, transfer lintas negara tunduk pada persyaratan tingkat perlindungan yang memadai di negara tujuan atau persetujuan eksplisit dari subjek data. Bila diperlukan, kami memperoleh persetujuan tersebut pada saat pembuatan akun.

## Retensi Dan Penghapusan Akun

- Pengguna anonim dapat dihapus setelah 30 hari tidak aktif.
- Pengguna terdaftar Free dapat menerima reminder setelah 6 bulan tidak aktif.
- Jika pengguna terdaftar Free tetap tidak aktif selama 30 hari setelah reminder, akun dapat dihapus.
- Pengguna terdaftar dengan entitlement Plus aktif dikecualikan dari pembersihan akun tidak aktif selama entitlement tersebut masih aktif.
- Setelah entitlement Plus berakhir, jendela tidak aktif untuk cleanup dihitung dari waktu yang lebih baru antara aktivitas terakhir pengguna dan waktu entitlement Plus terakhir berakhir.
- Saat pengguna tidak aktif dihapus, bill milik pengguna dihapus terlebih dahulu, lalu user autentikasi dihapus.
- Jika pengguna membuka aplikasi setelah menerima reminder, jadwal penghapusan akan direset.
- Anda dapat menghapus akun dan data aplikasi terkait dari **Profil & Pengaturan > Hapus Akun** di dalam aplikasi.

Anda juga dapat meminta penghapusan akun dan data dengan menghubungi email di bawah atau melalui halaman privacy publik: https://bagistruk.vercel.app/privacy

## Keamanan

Kami menggunakan autentikasi Supabase, row-level security, API key sisi server, dan policy database untuk melindungi data pengguna. Tidak ada sistem yang sepenuhnya aman, tetapi kami mengambil langkah wajar untuk membatasi akses dan mengurangi risiko.

## Notifikasi Pelanggaran Data

Apabila terjadi pelanggaran data pribadi yang kemungkinan besar berisiko tinggi terhadap hak dan kebebasan Anda, kami akan:

- Memberi tahu otoritas pengawas terkait (otoritas perlindungan data di yurisdiksi Anda) dalam 72 jam setelah menyadari pelanggaran, sesuai Pasal 33 GDPR.
- Memberi tahu pengguna terdampak tanpa penundaan yang tidak semestinya, sesuai Pasal 34 GDPR, ketika pelanggaran menimbulkan risiko tinggi terhadap hak mereka.
- Untuk pengguna di Indonesia, memberi tahu Otoritas Pelindungan Data Pribadi (OPDP) dan pengguna terdampak dalam 3 x 24 jam setelah menyadari, sesuai Pasal 46 UU PDP.

Notifikasi akan menjelaskan sifat pelanggaran, kategori dan perkiraan jumlah pengguna terdampak, kemungkinan konsekuensi, serta langkah-langkah yang diambil atau diusulkan untuk mengatasinya.

## Hak Anda

Sesuai hukum yang berlaku, Anda memiliki hak-hak berikut terkait data pribadi Anda:

- **Hak akses (Pasal 15 GDPR / Pasal 7 UU PDP)** — meminta salinan data pribadi yang kami simpan tentang Anda.
- **Hak koreksi (Pasal 16 GDPR / Pasal 8 UU PDP)** — mengoreksi data yang tidak akurat atau tidak lengkap. Sebagian besar field profil dapat diubah dari Profil & Pengaturan; field tagihan dapat diedit di aplikasi.
- **Hak penghapusan / hak untuk dilupakan (Pasal 17 GDPR / Pasal 9 UU PDP)** — meminta penghapusan akun dan data terkait dari Profil & Pengaturan, atau dengan menghubungi kami.
- **Hak pembatasan pemrosesan (Pasal 18 GDPR)** — meminta kami membatasi penggunaan data Anda dalam keadaan tertentu.
- **Hak portabilitas data (Pasal 20 GDPR / Pasal 11 UU PDP)** — menerima data Anda dalam format terstruktur, umum digunakan, dan dapat dibaca mesin. Tagihan dan datanya dapat diekspor sebagai PDF dan CSV dari aplikasi.
- **Hak keberatan (Pasal 21 GDPR)** — menolak pemrosesan berdasarkan kepentingan sah, termasuk profiling terkait pemasaran langsung.
- **Hak penarikan persetujuan (Pasal 7(3) GDPR / Pasal 25 UU PDP)** — menarik persetujuan yang telah Anda berikan, kapan saja, tanpa memengaruhi keabsahan pemrosesan sebelum penarikan. Opt-in pemasaran dapat ditarik dari Profil & Pengaturan.
- **Hak mengajukan keluhan** — ke otoritas perlindungan data lokal (untuk warga EEA; lihat https://edpb.europa.eu/about-edpb/about-edpb/members_en), atau ke KOMINFO / Otoritas Pelindungan Data Pribadi (untuk warga Indonesia).
- **Hak untuk tidak menjadi subjek pengambilan keputusan otomatis (Pasal 22 GDPR)** — BagiStruk tidak membuat keputusan berdasarkan pemrosesan otomatis semata yang menghasilkan efek hukum atau efek signifikan serupa terhadap Anda.

Untuk menggunakan hak-hak ini, hubungi kami di **alam.aby.b@gmail.com**. Kami akan merespons dalam 30 hari, atau lebih cepat bila diwajibkan hukum lokal. Kami mungkin perlu memverifikasi identitas Anda sebelum menindaklanjuti permintaan.

## Anak-Anak

BagiStruk tidak ditujukan untuk anak di bawah **13 tahun** (batas minimum US Children's Online Privacy Protection Act, COPPA), atau di bawah usia yang diwajibkan hukum lokal Anda untuk menyetujui layanan digital (16 tahun di sebagian besar Wilayah Ekonomi Eropa secara default, 18 tahun di Indonesia menurut Kitab Undang-Undang Hukum Perdata, atau lebih muda bila hukum negara Anda mengizinkan persetujuan pada usia lebih muda dengan persetujuan orang tua).

Kami tidak dengan sengaja mengumpulkan data pribadi dari anak di bawah batas usia yang berlaku. Jika Anda yakin seorang anak telah memberikan data pribadi kepada kami, hubungi kami di **alam.aby.b@gmail.com** agar kami dapat meninjau, menghapus data, dan menutup akun. Bila diwajibkan hukum, kami akan memperoleh persetujuan orang tua yang dapat diverifikasi sebelum memproses data anak.

## Perubahan

Kami dapat memperbarui kebijakan ini dari waktu ke waktu. Versi terbaru sebaiknya tersedia di aplikasi dan halaman publik yang menghosting dokumen ini. Bila persetujuan diperlukan untuk perubahan pemrosesan, kami akan meminta persetujuan baru melalui CMP kami.

## Pilihan Privasi Iklan

Jika Anda berada di wilayah yang mewajibkan persetujuan untuk iklan yang dipersonalisasi, aplikasi akan menampilkan pesan persetujuan Google saat pertama kali Anda meluncurkannya. Anda juga dapat meninjau atau mengubah pilihan privasi iklan kapan saja dari **Profil & Pengaturan** di aplikasi. Di luar wilayah tersebut, pintu masuk pilihan privasi iklan tidak ditampilkan.

## Kontak

Untuk pertanyaan privasi, permintaan penghapusan, atau penggunaan hak perlindungan data Anda, hubungi kami:

**Email:** alam.aby.b@gmail.com

**Alamat pos (juga kontak Pasal 27 GDPR kami):**
Alam Aby Bashit
Komplek Kamarasan Residence A3/2 Kelurahan Buahbatu Kecamatan Bojongsoang
Bandung, 40287
Indonesia
