import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_en.dart';
import 'app_l10n_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @registerMarketingOptIn.
  ///
  /// In id, this message translates to:
  /// **'Saya ingin menerima email promosi, berita fitur, dan tips dari BagiStruk.'**
  String get registerMarketingOptIn;

  /// No description provided for @postLoginWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di BagiStruk!'**
  String get postLoginWelcomeTitle;

  /// No description provided for @postLoginWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Beri tahu kami apakah Anda ingin menerima email promosi, berita fitur, dan tips dari kami. Anda bisa mengubah preferensi ini kapan saja dari Settings.'**
  String get postLoginWelcomeBody;

  /// No description provided for @postLoginWelcomeOptIn.
  ///
  /// In id, this message translates to:
  /// **'Kirim saya email promosi, berita fitur, dan tips.'**
  String get postLoginWelcomeOptIn;

  /// No description provided for @postLoginWelcomeContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get postLoginWelcomeContinue;

  /// No description provided for @postLoginWelcomeErrorSave.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get postLoginWelcomeErrorSave;

  /// No description provided for @registerErrorSaveProfile.
  ///
  /// In id, this message translates to:
  /// **'Akun Anda berhasil dibuat, tetapi kami tidak dapat menyimpan preferensi Anda. Coba lagi dari Settings setelah verifikasi email.'**
  String get registerErrorSaveProfile;

  /// No description provided for @settingsMarketingOptIn.
  ///
  /// In id, this message translates to:
  /// **'Email promosi'**
  String get settingsMarketingOptIn;

  /// No description provided for @settingsMarketingOptInSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tips, info fitur, dan penawaran dari BagiStruk.'**
  String get settingsMarketingOptInSubtitle;

  /// No description provided for @settingsMarketingOptInWebHint.
  ///
  /// In id, this message translates to:
  /// **'Anda juga bisa mengelola preferensi ini dari situs web BagiStruk.'**
  String get settingsMarketingOptInWebHint;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil & Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsTab.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTab;

  /// No description provided for @scanTab.
  ///
  /// In id, this message translates to:
  /// **'Pindai'**
  String get scanTab;

  /// No description provided for @historyTab.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get historyTab;

  /// No description provided for @scanScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindai Struk'**
  String get scanScreenTitle;

  /// No description provided for @scanAddPhotos.
  ///
  /// In id, this message translates to:
  /// **'Tambah Foto'**
  String get scanAddPhotos;

  /// No description provided for @scanAction.
  ///
  /// In id, this message translates to:
  /// **'Pindai'**
  String get scanAction;

  /// No description provided for @scanInProgress.
  ///
  /// In id, this message translates to:
  /// **'Memindai…'**
  String get scanInProgress;

  /// No description provided for @scanSourceSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto struk'**
  String get scanSourceSheetTitle;

  /// No description provided for @scanSourceCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get scanSourceCamera;

  /// No description provided for @scanSourceGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get scanSourceGallery;

  /// No description provided for @scanCameraContinuePrompt.
  ///
  /// In id, this message translates to:
  /// **'Foto lagi untuk struk panjang?'**
  String get scanCameraContinuePrompt;

  /// No description provided for @scanCameraTakeAnother.
  ///
  /// In id, this message translates to:
  /// **'Foto Lagi'**
  String get scanCameraTakeAnother;

  /// No description provided for @scanCameraDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get scanCameraDone;

  /// No description provided for @shareImagesAdded.
  ///
  /// In id, this message translates to:
  /// **'{count} foto dari bagikan ditambahkan. Memulai pindaian...'**
  String shareImagesAdded(int count);

  /// No description provided for @scanNotReceiptTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto bukan struk'**
  String get scanNotReceiptTitle;

  /// No description provided for @scanNotReceiptHint.
  ///
  /// In id, this message translates to:
  /// **'Gambar yang dipilih sepertinya bukan struk. Coba foto struk yang jelas.'**
  String get scanNotReceiptHint;

  /// No description provided for @scanPreparingSessionFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal siapkan sesi: {message}'**
  String scanPreparingSessionFailed(String message);

  /// No description provided for @scanCreditCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal cek credit scan: {message}'**
  String scanCreditCheckFailed(String message);

  /// No description provided for @scanCreditCostWithBalance.
  ///
  /// In id, this message translates to:
  /// **'{imageCount} foto akan memakai {creditCost} credit. Sisa: {balance}.'**
  String scanCreditCostWithBalance(int imageCount, int creditCost, int balance);

  /// No description provided for @scanCreditRequired.
  ///
  /// In id, this message translates to:
  /// **'Scan ini butuh {requiredCredits} credit. Sisa credit kamu: {balance}.'**
  String scanCreditRequired(int requiredCredits, int balance);

  /// No description provided for @scanNoCreditAnonymousTitle.
  ///
  /// In id, this message translates to:
  /// **'Batas scan gratis tercapai'**
  String get scanNoCreditAnonymousTitle;

  /// No description provided for @scanNoCreditFreeTitle.
  ///
  /// In id, this message translates to:
  /// **'Credit scan bulan ini habis'**
  String get scanNoCreditFreeTitle;

  /// No description provided for @scanNoCreditAnonymousBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu sudah memakai 5 credit scan sebagai pengguna anonim. Daftar akun untuk mendapat 20 credit gratis setiap bulan.'**
  String get scanNoCreditAnonymousBody;

  /// No description provided for @scanNoCreditPlusBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu sudah memakai {monthlyAllowance} credit Plus bulan ini. Credit akan tersedia lagi pada periode berikutnya.'**
  String scanNoCreditPlusBody(int monthlyAllowance);

  /// No description provided for @scanNoCreditFreeBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu sudah memakai {monthlyAllowance} credit gratis bulan ini. Upgrade ke Plus untuk 60 credit/bulan, tanpa iklan, dan fitur khusus Plus.'**
  String scanNoCreditFreeBody(int monthlyAllowance);

  /// No description provided for @scanNoCreditLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get scanNoCreditLater;

  /// No description provided for @scanNoCreditRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get scanNoCreditRegister;

  /// No description provided for @scanNoCreditPlusSoon.
  ///
  /// In id, this message translates to:
  /// **'Plus segera hadir'**
  String get scanNoCreditPlusSoon;

  /// No description provided for @scanStatusPreparingImages.
  ///
  /// In id, this message translates to:
  /// **'Memproses gambar…'**
  String get scanStatusPreparingImages;

  /// No description provided for @scanStatusIdle.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto lalu tap Pindai'**
  String get scanStatusIdle;

  /// No description provided for @scanStatusScanning.
  ///
  /// In id, this message translates to:
  /// **'Memindai {imageCount} gambar…'**
  String scanStatusScanning(int imageCount);

  /// No description provided for @scanStatusSuccess.
  ///
  /// In id, this message translates to:
  /// **'{itemCount} item terdeteksi via {provider}'**
  String scanStatusSuccess(int itemCount, String provider);

  /// No description provided for @ocrErrorNetworkTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi'**
  String get ocrErrorNetworkTitle;

  /// No description provided for @ocrErrorNetworkBody.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi internetmu, lalu coba scan ulang.'**
  String get ocrErrorNetworkBody;

  /// No description provided for @ocrErrorAuthTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesi berakhir'**
  String get ocrErrorAuthTitle;

  /// No description provided for @ocrErrorAuthBody.
  ///
  /// In id, this message translates to:
  /// **'Sesi kamu sudah habis. Silakan masuk lagi untuk melanjutkan.'**
  String get ocrErrorAuthBody;

  /// No description provided for @ocrErrorParsingTitle.
  ///
  /// In id, this message translates to:
  /// **'Respons tidak terbaca'**
  String get ocrErrorParsingTitle;

  /// No description provided for @ocrErrorParsingBody.
  ///
  /// In id, this message translates to:
  /// **'Hasil scan dari server tidak dapat diproses. Coba foto ulang dengan pencahayaan lebih baik.'**
  String get ocrErrorParsingBody;

  /// No description provided for @ocrErrorUnknownTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get ocrErrorUnknownTitle;

  /// No description provided for @ocrErrorUnknownBody.
  ///
  /// In id, this message translates to:
  /// **'Sesuatu tidak berjalan semestinya. Coba lagi sebentar.'**
  String get ocrErrorUnknownBody;

  /// No description provided for @ocrErrorNotReceiptTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto bukan struk'**
  String get ocrErrorNotReceiptTitle;

  /// No description provided for @ocrErrorNotReceiptBody.
  ///
  /// In id, this message translates to:
  /// **'Gambar yang dipilih sepertinya bukan struk belanja. Coba foto struk yang jelas dan tidak terpotong.'**
  String get ocrErrorNotReceiptBody;

  /// No description provided for @ocrErrorCreditTitle.
  ///
  /// In id, this message translates to:
  /// **'Credit scan habis'**
  String get ocrErrorCreditTitle;

  /// No description provided for @ocrErrorCreditBody.
  ///
  /// In id, this message translates to:
  /// **'Tambah credit atau tunggu periode berikutnya untuk scan lagi.'**
  String get ocrErrorCreditBody;

  /// No description provided for @ocrErrorAiBusyTitle.
  ///
  /// In id, this message translates to:
  /// **'Layanan AI sedang sibuk'**
  String get ocrErrorAiBusyTitle;

  /// No description provided for @ocrErrorAiBusyBody.
  ///
  /// In id, this message translates to:
  /// **'Server AI sedang menerima banyak permintaan. Tunggu beberapa saat, lalu coba scan lagi.'**
  String get ocrErrorAiBusyBody;

  /// No description provided for @ocrErrorRateLimitTitle.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak permintaan'**
  String get ocrErrorRateLimitTitle;

  /// No description provided for @ocrErrorRateLimitBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu mencapai batas scan untuk saat ini. Coba lagi dalam beberapa menit.'**
  String get ocrErrorRateLimitBody;

  /// No description provided for @ocrErrorForbiddenTitle.
  ///
  /// In id, this message translates to:
  /// **'Akses ditolak'**
  String get ocrErrorForbiddenTitle;

  /// No description provided for @ocrErrorForbiddenBody.
  ///
  /// In id, this message translates to:
  /// **'Server menolak permintaan. Coba keluar dan masuk lagi.'**
  String get ocrErrorForbiddenBody;

  /// No description provided for @ocrErrorTimeoutTitle.
  ///
  /// In id, this message translates to:
  /// **'Permintaan kelamaan'**
  String get ocrErrorTimeoutTitle;

  /// No description provided for @ocrErrorTimeoutBody.
  ///
  /// In id, this message translates to:
  /// **'Server butuh waktu terlalu lama merespons. Coba lagi.'**
  String get ocrErrorTimeoutBody;

  /// No description provided for @ocrErrorServerTitle.
  ///
  /// In id, this message translates to:
  /// **'Server bermasalah'**
  String get ocrErrorServerTitle;

  /// No description provided for @ocrErrorServerBody.
  ///
  /// In id, this message translates to:
  /// **'Server sedang tidak stabil. Tunggu sebentar lalu coba lagi.'**
  String get ocrErrorServerBody;

  /// No description provided for @ocrErrorGenericTitle.
  ///
  /// In id, this message translates to:
  /// **'Scan gagal'**
  String get ocrErrorGenericTitle;

  /// No description provided for @ocrErrorGenericBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa memproses struk ini. Coba foto ulang atau gunakan gambar lain.'**
  String get ocrErrorGenericBody;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @accountSection.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get accountSection;

  /// No description provided for @preferencesSection.
  ///
  /// In id, this message translates to:
  /// **'Preferensi'**
  String get preferencesSection;

  /// No description provided for @displayNameFallback.
  ///
  /// In id, this message translates to:
  /// **'Pengguna BagiStruk'**
  String get displayNameFallback;

  /// No description provided for @anonDisplayName.
  ///
  /// In id, this message translates to:
  /// **'Saya'**
  String get anonDisplayName;

  /// No description provided for @guestAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun Tamu'**
  String get guestAccount;

  /// No description provided for @creditScanTitle.
  ///
  /// In id, this message translates to:
  /// **'Credit scan'**
  String get creditScanTitle;

  /// No description provided for @creditStatusLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat status credit...'**
  String get creditStatusLoading;

  /// No description provided for @creditStatusRemaining.
  ///
  /// In id, this message translates to:
  /// **'{balance}/{monthlyAllowance} tersisa ({planCode})'**
  String creditStatusRemaining(
    int balance,
    int monthlyAllowance,
    String planCode,
  );

  /// No description provided for @billingTitle.
  ///
  /// In id, this message translates to:
  /// **'Plus dan paket credit'**
  String get billingTitle;

  /// No description provided for @billingAnonSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar akun dulu untuk membeli Plus atau top-up credit.'**
  String get billingAnonSubtitle;

  /// No description provided for @creditPlusExpiresAt.
  ///
  /// In id, this message translates to:
  /// **'Plus berakhir: {date}'**
  String creditPlusExpiresAt(String date);

  /// No description provided for @creditTrialExpiresAt.
  ///
  /// In id, this message translates to:
  /// **'Masa percobaan Plus berakhir: {date}'**
  String creditTrialExpiresAt(String date);

  /// No description provided for @billingPlusActive.
  ///
  /// In id, this message translates to:
  /// **'Plus aktif'**
  String get billingPlusActive;

  /// No description provided for @billingPlanFree.
  ///
  /// In id, this message translates to:
  /// **'Free'**
  String get billingPlanFree;

  /// No description provided for @billingPlusCardTitle.
  ///
  /// In id, this message translates to:
  /// **'BagiStruk Plus'**
  String get billingPlusCardTitle;

  /// No description provided for @billingPlusBenefitCredits.
  ///
  /// In id, this message translates to:
  /// **'60 credit OCR per bulan'**
  String get billingPlusBenefitCredits;

  /// No description provided for @billingPlusBenefitNoAds.
  ///
  /// In id, this message translates to:
  /// **'Tanpa iklan'**
  String get billingPlusBenefitNoAds;

  /// No description provided for @billingPlusBenefitFeatures.
  ///
  /// In id, this message translates to:
  /// **'Akses fitur Plus'**
  String get billingPlusBenefitFeatures;

  /// No description provided for @billingTopUpCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Top up credit OCR'**
  String get billingTopUpCardTitle;

  /// No description provided for @billingManageSubscription.
  ///
  /// In id, this message translates to:
  /// **'Kelola langganan'**
  String get billingManageSubscription;

  /// No description provided for @billingManageOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka pengelolaan langganan.'**
  String get billingManageOpenFailed;

  /// No description provided for @billingUpgradePlus.
  ///
  /// In id, this message translates to:
  /// **'Upgrade Plus'**
  String get billingUpgradePlus;

  /// No description provided for @billingUpgradePlusWithPrice.
  ///
  /// In id, this message translates to:
  /// **'Berlangganan bulanan • {price}'**
  String billingUpgradePlusWithPrice(String price);

  /// No description provided for @billingCreditPackTitle.
  ///
  /// In id, this message translates to:
  /// **'{credits} credit'**
  String billingCreditPackTitle(int credits);

  /// No description provided for @billingBuyAction.
  ///
  /// In id, this message translates to:
  /// **'Beli'**
  String get billingBuyAction;

  /// No description provided for @billingBuyCredits.
  ///
  /// In id, this message translates to:
  /// **'Beli 50 credit'**
  String get billingBuyCredits;

  /// No description provided for @billingLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get billingLoading;

  /// No description provided for @billingRestorePurchases.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan langganan'**
  String get billingRestorePurchases;

  /// No description provided for @billingUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Google Play Billing belum tersedia di perangkat ini.'**
  String get billingUnavailable;

  /// No description provided for @billingProductsNotActive.
  ///
  /// In id, this message translates to:
  /// **'Beberapa produk belum aktif di Play Console.'**
  String get billingProductsNotActive;

  /// No description provided for @billingProductsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Produk belum bisa dimuat.'**
  String get billingProductsLoadFailed;

  /// No description provided for @billingOpeningPlay.
  ///
  /// In id, this message translates to:
  /// **'Membuka Google Play...'**
  String get billingOpeningPlay;

  /// No description provided for @billingPurchaseStartFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembelian belum bisa dimulai.'**
  String get billingPurchaseStartFailed;

  /// No description provided for @billingRestoringPurchases.
  ///
  /// In id, this message translates to:
  /// **'Memulihkan pembelian...'**
  String get billingRestoringPurchases;

  /// No description provided for @billingRestoreFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembelian belum bisa dipulihkan.'**
  String get billingRestoreFailed;

  /// No description provided for @billingPaymentPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pembayaran Google Play...'**
  String get billingPaymentPending;

  /// No description provided for @billingPurchaseFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembelian dibatalkan atau gagal.'**
  String get billingPurchaseFailed;

  /// No description provided for @billingPurchaseSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pembelian berhasil diproses.'**
  String get billingPurchaseSuccess;

  /// No description provided for @billingPurchaseVerifyFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembelian belum bisa diverifikasi.'**
  String get billingPurchaseVerifyFailed;

  /// No description provided for @changeName.
  ///
  /// In id, this message translates to:
  /// **'Ubah Nama'**
  String get changeName;

  /// No description provided for @changeNameSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Nama Tampilan'**
  String get changeNameSheetTitle;

  /// No description provided for @changeNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan'**
  String get changeNameHint;

  /// No description provided for @saveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get saveAction;

  /// No description provided for @cancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancelAction;

  /// No description provided for @plusOnlyShort.
  ///
  /// In id, this message translates to:
  /// **'Khusus Plus.'**
  String get plusOnlyShort;

  /// No description provided for @transferBankSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Info bank transfer'**
  String get transferBankSettingsTitle;

  /// No description provided for @transferBankSettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan rekening untuk pesan WhatsApp settlement.'**
  String get transferBankSettingsSubtitle;

  /// No description provided for @transferBankSettingsLockedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Khusus Plus. Info bank bisa ikut di pesan WhatsApp settlement.'**
  String get transferBankSettingsLockedSubtitle;

  /// No description provided for @transferBankScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Bank Transfer'**
  String get transferBankScreenTitle;

  /// No description provided for @transferBankNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama bank'**
  String get transferBankNameLabel;

  /// No description provided for @transferAccountNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama pemilik rekening'**
  String get transferAccountNameLabel;

  /// No description provided for @transferAccountNumberLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor rekening'**
  String get transferAccountNumberLabel;

  /// No description provided for @transferBankShareTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer ke'**
  String get transferBankShareTitle;

  /// No description provided for @transferBankShareHint.
  ///
  /// In id, this message translates to:
  /// **'Kalau terisi, info ini ikut muncul di pesan yang dibagikan ke WhatsApp.'**
  String get transferBankShareHint;

  /// No description provided for @transferBankPlusOnly.
  ///
  /// In id, this message translates to:
  /// **'Info bank transfer adalah fitur Plus. Upgrade untuk menyimpan rekening dan menambahkannya ke pesan settlement.'**
  String get transferBankPlusOnly;

  /// No description provided for @transferBankRequired.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi field ini atau kosongkan semuanya.'**
  String get transferBankRequired;

  /// No description provided for @transferBankSaved.
  ///
  /// In id, this message translates to:
  /// **'Info bank transfer tersimpan.'**
  String get transferBankSaved;

  /// No description provided for @transferBankClear.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan info bank'**
  String get transferBankClear;

  /// No description provided for @resetPassword.
  ///
  /// In id, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim email reset password?'**
  String get resetPasswordConfirmTitle;

  /// No description provided for @resetPasswordConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Kami akan mengirim tautan reset password ke {email}.'**
  String resetPasswordConfirmBody(String email);

  /// No description provided for @resetPasswordSent.
  ///
  /// In id, this message translates to:
  /// **'Email reset password telah dikirim.'**
  String get resetPasswordSent;

  /// No description provided for @resetPasswordScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Ulang Password'**
  String get resetPasswordScreenTitle;

  /// No description provided for @resetPasswordScreenHeading.
  ///
  /// In id, this message translates to:
  /// **'Buat Password Baru'**
  String get resetPasswordScreenHeading;

  /// No description provided for @resetPasswordScreenBody.
  ///
  /// In id, this message translates to:
  /// **'Masukkan password baru untuk akun Anda. Setelah disimpan, Anda akan kembali ke Pengaturan.'**
  String get resetPasswordScreenBody;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan Password'**
  String get resetPasswordSaveAction;

  /// No description provided for @resetPasswordMinChars.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get resetPasswordMinChars;

  /// No description provided for @resetPasswordNeedsAlphaDigit.
  ///
  /// In id, this message translates to:
  /// **'Harus mengandung huruf dan angka'**
  String get resetPasswordNeedsAlphaDigit;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok'**
  String get resetPasswordMismatch;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diubah'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordSessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi reset sudah berakhir. Silakan minta link baru.'**
  String get resetPasswordSessionExpired;

  /// No description provided for @currencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Mata Uang Default'**
  String get currencyLabel;

  /// No description provided for @currencySearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari mata uang'**
  String get currencySearchHint;

  /// No description provided for @currencySearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Mata uang tidak ditemukan.'**
  String get currencySearchEmpty;

  /// No description provided for @languageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageLabel;

  /// No description provided for @themeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tema Tampilan'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti Sistem'**
  String get themeSystem;

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @registerPermanent.
  ///
  /// In id, this message translates to:
  /// **'Daftar Akun Permanen'**
  String get registerPermanent;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari akun?'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutBody.
  ///
  /// In id, this message translates to:
  /// **'Anda akan keluar dan kembali sebagai pengguna tamu.'**
  String get confirmLogoutBody;

  /// No description provided for @deleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Hapus Akun'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus permanen akun dan data bill tersimpan.'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun kamu?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Tindakan ini akan menghapus permanen akun, profil, bill tersimpan, item bill, peserta, pembagian item, dan status pelunasan. Tindakan ini tidak bisa dibatalkan.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountConfirmPhrase.
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get deleteAccountConfirmPhrase;

  /// No description provided for @deleteAccountTypeTitle.
  ///
  /// In id, this message translates to:
  /// **'Ketik HAPUS untuk konfirmasi'**
  String get deleteAccountTypeTitle;

  /// No description provided for @deleteAccountTypeBody.
  ///
  /// In id, this message translates to:
  /// **'Ketik {phrase} untuk menghapus akun secara permanen.'**
  String deleteAccountTypeBody(String phrase);

  /// No description provided for @deleteAccountInProgress.
  ///
  /// In id, this message translates to:
  /// **'Menghapus akun...'**
  String get deleteAccountInProgress;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In id, this message translates to:
  /// **'Akun dan data tersimpan sudah dihapus.'**
  String get deleteAccountSuccess;

  /// No description provided for @deletedBillsTitle.
  ///
  /// In id, this message translates to:
  /// **'Bill terhapus'**
  String get deletedBillsTitle;

  /// No description provided for @deletedBillsSettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan bill yang dihapus dalam 30 hari terakhir.'**
  String get deletedBillsSettingsSubtitle;

  /// No description provided for @deletedBillsSettingsLockedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Khusus Plus. Pulihkan bill yang tidak sengaja dihapus dalam 30 hari.'**
  String get deletedBillsSettingsLockedSubtitle;

  /// No description provided for @deletedBillsLockedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan bill terhapus dengan Plus'**
  String get deletedBillsLockedTitle;

  /// No description provided for @deletedBillsLockedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bill terhapus disimpan selama 30 hari agar pengguna Plus bisa memulihkan penghapusan tidak sengaja.'**
  String get deletedBillsLockedSubtitle;

  /// No description provided for @deletedBillsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bill terhapus.'**
  String get deletedBillsEmpty;

  /// No description provided for @deletedBillDeletedAt.
  ///
  /// In id, this message translates to:
  /// **'Dihapus {date}'**
  String deletedBillDeletedAt(String date);

  /// No description provided for @deletedBillExpiresAt.
  ///
  /// In id, this message translates to:
  /// **'Bisa dipulihkan sampai {date}'**
  String deletedBillExpiresAt(String date);

  /// No description provided for @deletedBillRestoreAction.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get deletedBillRestoreAction;

  /// No description provided for @deletedBillRestored.
  ///
  /// In id, this message translates to:
  /// **'Bill dipulihkan.'**
  String get deletedBillRestored;

  /// No description provided for @deleteBillAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get deleteBillAction;

  /// No description provided for @deleteBillConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus bill ini?'**
  String get deleteBillConfirmTitle;

  /// No description provided for @deleteBillConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{title} ({total}) akan dipindahkan ke Bill terhapus. Pengguna Plus bisa memulihkannya dalam 30 hari.'**
  String deleteBillConfirmBody(String title, String total);

  /// No description provided for @deleteBillSuccess.
  ///
  /// In id, this message translates to:
  /// **'Bill dipindahkan ke Bill terhapus.'**
  String get deleteBillSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get errorGeneric;

  /// No description provided for @authErrorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet. Coba lagi setelah jaringan stabil.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorServer.
  ///
  /// In id, this message translates to:
  /// **'Server bermasalah: {message}. Coba lagi sebentar lagi.'**
  String authErrorServer(String message);

  /// No description provided for @authErrorParsing.
  ///
  /// In id, this message translates to:
  /// **'Respons server tidak terbaca. Coba lagi.'**
  String get authErrorParsing;

  /// No description provided for @authErrorUnknown.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan tak terduga. Coba lagi.'**
  String get authErrorUnknown;

  /// No description provided for @authErrorInvalidLogin.
  ///
  /// In id, this message translates to:
  /// **'Email atau password salah.'**
  String get authErrorInvalidLogin;

  /// No description provided for @authErrorAlreadyRegistered.
  ///
  /// In id, this message translates to:
  /// **'Email sudah terdaftar. Coba login.'**
  String get authErrorAlreadyRegistered;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In id, this message translates to:
  /// **'Password terlalu lemah. Minimal 6 karakter.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Email belum dikonfirmasi. Cek kotak masuk.'**
  String get authErrorEmailNotConfirmed;

  /// No description provided for @authErrorDisposableEmail.
  ///
  /// In id, this message translates to:
  /// **'Email sementara/disposable tidak bisa digunakan. Pakai email utama kamu.'**
  String get authErrorDisposableEmail;

  /// No description provided for @authErrorEmailAliasUsed.
  ///
  /// In id, this message translates to:
  /// **'Email ini terdeteksi sebagai alias dari email yang sudah pernah digunakan.'**
  String get authErrorEmailAliasUsed;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Format email belum valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorGoogleSignIn.
  ///
  /// In id, this message translates to:
  /// **'Google Sign-In gagal setelah memilih akun. Coba lagi; jika tetap terjadi, cek OAuth Android package name, SHA-1 debug/release, dan Google Web Client ID.'**
  String get authErrorGoogleSignIn;

  /// No description provided for @authErrorComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini akan segera hadir.'**
  String get authErrorComingSoon;

  /// No description provided for @authErrorFallback.
  ///
  /// In id, this message translates to:
  /// **'Autentikasi gagal. Coba lagi.'**
  String get authErrorFallback;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @noSessionMessage.
  ///
  /// In id, this message translates to:
  /// **'Daftar atau masuk untuk mengakses pengaturan.'**
  String get noSessionMessage;

  /// No description provided for @registerOrLogin.
  ///
  /// In id, this message translates to:
  /// **'Daftar / Masuk'**
  String get registerOrLogin;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan ke BagiStruk.'**
  String get loginSubtitle;

  /// No description provided for @loginSaveBanner.
  ///
  /// In id, this message translates to:
  /// **'Daftar untuk menyimpan riwayat tagihanmu'**
  String get loginSaveBanner;

  /// No description provided for @loginResetExpiredBanner.
  ///
  /// In id, this message translates to:
  /// **'Sesi reset password sudah berakhir. Silakan minta tautan baru dari Pengaturan.'**
  String get loginResetExpiredBanner;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @loginOr.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get loginOr;

  /// No description provided for @loginEmailHint.
  ///
  /// In id, this message translates to:
  /// **'kamu@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginOtpButton.
  ///
  /// In id, this message translates to:
  /// **'Kirim kode email'**
  String get loginOtpButton;

  /// No description provided for @loginOtpSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim kode…'**
  String get loginOtpSending;

  /// No description provided for @loginNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get loginRegisterLink;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerTitle;

  /// No description provided for @registerBackToScanTooltip.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Scan'**
  String get registerBackToScanTooltip;

  /// No description provided for @registerSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get registerSkip;

  /// No description provided for @registerHeading.
  ///
  /// In id, this message translates to:
  /// **'Buat akun baru'**
  String get registerHeading;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan riwayat tagihanmu di semua perangkat.'**
  String get registerSubtitle;

  /// No description provided for @registerPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 6 karakter'**
  String get registerPasswordHint;

  /// No description provided for @registerHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? '**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In id, this message translates to:
  /// **'Login'**
  String get registerLoginLink;

  /// No description provided for @legalAcceptanceAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan Hukum'**
  String get legalAcceptanceAppBarTitle;

  /// No description provided for @legalAcceptanceTitle.
  ///
  /// In id, this message translates to:
  /// **'Sebelum mulai…'**
  String get legalAcceptanceTitle;

  /// No description provided for @legalAcceptanceIntro.
  ///
  /// In id, this message translates to:
  /// **'Untuk menggunakan BagiStruk, mohon baca dan setujui dua dokumen di bawah ini. Kami membutuhkan persetujuan terpisah untuk Syarat Layanan dan Kebijakan Privasi.'**
  String get legalAcceptanceIntro;

  /// No description provided for @legalAcceptanceReadTerms.
  ///
  /// In id, this message translates to:
  /// **'Baca Syarat Layanan'**
  String get legalAcceptanceReadTerms;

  /// No description provided for @legalAcceptanceReadPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Baca Kebijakan Privasi'**
  String get legalAcceptanceReadPrivacy;

  /// No description provided for @legalAcceptanceAgreeTerms.
  ///
  /// In id, this message translates to:
  /// **'Saya telah membaca dan menyetujui Syarat Layanan.'**
  String get legalAcceptanceAgreeTerms;

  /// No description provided for @legalAcceptanceAgreePrivacy.
  ///
  /// In id, this message translates to:
  /// **'Saya telah membaca dan menyetujui Kebijakan Privasi.'**
  String get legalAcceptanceAgreePrivacy;

  /// No description provided for @legalAcceptanceAgreeAge.
  ///
  /// In id, this message translates to:
  /// **'Saya berusia 18 tahun ke atas, atau lebih tua jika diwajibkan oleh hukum lokal saya.'**
  String get legalAcceptanceAgreeAge;

  /// No description provided for @legalAcceptanceContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get legalAcceptanceContinue;

  /// No description provided for @legalAcceptanceErrorSave.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan persetujuan. Coba lagi.'**
  String get legalAcceptanceErrorSave;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBackTooltip.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get verifyEmailBackTooltip;

  /// No description provided for @verifyEmailHeading.
  ///
  /// In id, this message translates to:
  /// **'Cek email kamu'**
  String get verifyEmailHeading;

  /// No description provided for @verifyEmailBodyPrefix.
  ///
  /// In id, this message translates to:
  /// **'Kami sudah mengirim link konfirmasi ke '**
  String get verifyEmailBodyPrefix;

  /// No description provided for @verifyEmailBodySuffix.
  ///
  /// In id, this message translates to:
  /// **'. Klik link itu untuk mengaktifkan akunmu — sampai itu kamu belum bisa login dari perangkat lain.'**
  String get verifyEmailBodySuffix;

  /// No description provided for @verifyEmailAutonav.
  ///
  /// In id, this message translates to:
  /// **'Setelah konfirmasi, kamu otomatis dipindahkan ke Riwayat.'**
  String get verifyEmailAutonav;

  /// No description provided for @verifyEmailResend.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang email'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim…'**
  String get verifyEmailResending;

  /// No description provided for @verifyEmailResent.
  ///
  /// In id, this message translates to:
  /// **'Email verifikasi sudah dikirim ulang.'**
  String get verifyEmailResent;

  /// No description provided for @verifyEmailUseDifferent.
  ///
  /// In id, this message translates to:
  /// **'Pakai email lain'**
  String get verifyEmailUseDifferent;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode'**
  String get verifyOtpTitle;

  /// No description provided for @verifyOtpHeading.
  ///
  /// In id, this message translates to:
  /// **'Cek kode email'**
  String get verifyOtpHeading;

  /// No description provided for @verifyOtpBodyPrefix.
  ///
  /// In id, this message translates to:
  /// **'Kami sudah mengirim kode 8 digit ke '**
  String get verifyOtpBodyPrefix;

  /// No description provided for @verifyOtpBodySuffix.
  ///
  /// In id, this message translates to:
  /// **'. Masukkan kode itu untuk masuk ke akunmu.'**
  String get verifyOtpBodySuffix;

  /// No description provided for @verifyOtpInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode 8 digit.'**
  String get verifyOtpInvalid;

  /// No description provided for @verifyOtpButton.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi & masuk'**
  String get verifyOtpButton;

  /// No description provided for @verifyOtpResend.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode'**
  String get verifyOtpResend;

  /// No description provided for @verifyOtpResending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim…'**
  String get verifyOtpResending;

  /// No description provided for @verifyOtpResent.
  ///
  /// In id, this message translates to:
  /// **'Kode baru sudah dikirim.'**
  String get verifyOtpResent;

  /// No description provided for @verifyOtpResendCountdown.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang dalam {seconds}d'**
  String verifyOtpResendCountdown(int seconds);

  /// No description provided for @verifyOtpUseDifferent.
  ///
  /// In id, this message translates to:
  /// **'Pakai email lain'**
  String get verifyOtpUseDifferent;

  /// No description provided for @historySignOutTooltip.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get historySignOutTooltip;

  /// No description provided for @historySignedOut.
  ///
  /// In id, this message translates to:
  /// **'Kamu sudah keluar.'**
  String get historySignedOut;

  /// No description provided for @historyLoadingMessage.
  ///
  /// In id, this message translates to:
  /// **'Memuat riwayat…'**
  String get historyLoadingMessage;

  /// No description provided for @historyTotalBills.
  ///
  /// In id, this message translates to:
  /// **'Total bill'**
  String get historyTotalBills;

  /// No description provided for @historyOutstanding.
  ///
  /// In id, this message translates to:
  /// **'Piutang outstanding'**
  String get historyOutstanding;

  /// No description provided for @historyOutstandingCarouselPage.
  ///
  /// In id, this message translates to:
  /// **'{current} dari {total}'**
  String historyOutstandingCarouselPage(int current, int total);

  /// No description provided for @historyEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bill tersimpan.\nMulai scan struk dari tab Scan.'**
  String get historyEmptyMessage;

  /// No description provided for @historyWindowFree.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Free'**
  String get historyWindowFree;

  /// No description provided for @historyWindowPlus.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Plus'**
  String get historyWindowPlus;

  /// No description provided for @historyWindowAnonymous.
  ///
  /// In id, this message translates to:
  /// **'Riwayat terkunci'**
  String get historyWindowAnonymous;

  /// No description provided for @historyWindowAnonymousSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar untuk menyimpan dan melihat riwayat bill.'**
  String get historyWindowAnonymousSubtitle;

  /// No description provided for @historyWindowFreeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan bill dari {freeDays} hari terakhir. Plus bisa melihat sampai {plusDays} hari terakhir.'**
  String historyWindowFreeSubtitle(int freeDays, int plusDays);

  /// No description provided for @historyWindowSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan bill dari {days} hari terakhir.'**
  String historyWindowSubtitle(int days);

  /// No description provided for @historyUpgradeCta.
  ///
  /// In id, this message translates to:
  /// **'Upgrade ke Plus'**
  String get historyUpgradeCta;

  /// No description provided for @historyPlusBannerDismiss.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get historyPlusBannerDismiss;

  /// No description provided for @historyFreePlusBannerLabel.
  ///
  /// In id, this message translates to:
  /// **'Riwayat {freeDays} hari · Insight bulanan'**
  String historyFreePlusBannerLabel(int freeDays);

  /// No description provided for @historyFreePlusBannerSemantics.
  ///
  /// In id, this message translates to:
  /// **'Riwayat {freeDays} hari dan Insight bulanan, fitur Plus. Ketuk untuk detail.'**
  String historyFreePlusBannerSemantics(int freeDays);

  /// No description provided for @historyFreePlusSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur History Plus'**
  String get historyFreePlusSheetTitle;

  /// No description provided for @historyFreePlusHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat lebih panjang'**
  String get historyFreePlusHistoryTitle;

  /// No description provided for @historyFreePlusHistoryBody.
  ///
  /// In id, this message translates to:
  /// **'Free menampilkan {freeDays} hari terakhir. Plus menampilkan hingga {plusDays} hari.'**
  String historyFreePlusHistoryBody(int freeDays, int plusDays);

  /// No description provided for @historyFreePlusDismissAction.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get historyFreePlusDismissAction;

  /// No description provided for @historyFilterTooltip.
  ///
  /// In id, this message translates to:
  /// **'Urutkan & filter'**
  String get historyFilterTooltip;

  /// No description provided for @historyFilterTitle.
  ///
  /// In id, this message translates to:
  /// **'Urutkan & filter'**
  String get historyFilterTitle;

  /// No description provided for @historyFilterSort.
  ///
  /// In id, this message translates to:
  /// **'Urutan'**
  String get historyFilterSort;

  /// No description provided for @historyFilterStatus.
  ///
  /// In id, this message translates to:
  /// **'Status pembayaran'**
  String get historyFilterStatus;

  /// No description provided for @historyFilterCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang'**
  String get historyFilterCurrency;

  /// No description provided for @historyFilterReset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get historyFilterReset;

  /// No description provided for @historyFilterEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada bill yang cocok dengan filter ini.'**
  String get historyFilterEmpty;

  /// No description provided for @historyFilterCount.
  ///
  /// In id, this message translates to:
  /// **'{filteredCount} dari {totalCount} bill'**
  String historyFilterCount(int filteredCount, int totalCount);

  /// No description provided for @historySortNewest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get historySortNewest;

  /// No description provided for @historySortOldest.
  ///
  /// In id, this message translates to:
  /// **'Terlama'**
  String get historySortOldest;

  /// No description provided for @historySortTitle.
  ///
  /// In id, this message translates to:
  /// **'Nama A-Z'**
  String get historySortTitle;

  /// No description provided for @historySortAmountDesc.
  ///
  /// In id, this message translates to:
  /// **'Nominal tertinggi'**
  String get historySortAmountDesc;

  /// No description provided for @historySortAmountAsc.
  ///
  /// In id, this message translates to:
  /// **'Nominal terendah'**
  String get historySortAmountAsc;

  /// No description provided for @historySortNominalDisabled.
  ///
  /// In id, this message translates to:
  /// **'Pilih satu mata uang untuk mengurutkan nominal.'**
  String get historySortNominalDisabled;

  /// No description provided for @historyStatusAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get historyStatusAll;

  /// No description provided for @historyStatusUnassigned.
  ///
  /// In id, this message translates to:
  /// **'Belum dibagi'**
  String get historyStatusUnassigned;

  /// No description provided for @historyStatusUnpaid.
  ///
  /// In id, this message translates to:
  /// **'Belum dibayar'**
  String get historyStatusUnpaid;

  /// No description provided for @historyStatusPartial.
  ///
  /// In id, this message translates to:
  /// **'Sebagian dibayar'**
  String get historyStatusPartial;

  /// No description provided for @historyStatusSettled.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get historyStatusSettled;

  /// No description provided for @applyAction.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get applyAction;

  /// No description provided for @monthlyInsightTitle.
  ///
  /// In id, this message translates to:
  /// **'Insight bulanan'**
  String get monthlyInsightTitle;

  /// No description provided for @monthlyInsightMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran {month} {year}'**
  String monthlyInsightMonth(String month, int year);

  /// No description provided for @monthlyInsightLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat insight bulanan...'**
  String get monthlyInsightLoading;

  /// No description provided for @monthlyInsightError.
  ///
  /// In id, this message translates to:
  /// **'Insight bulanan belum bisa dimuat.'**
  String get monthlyInsightError;

  /// No description provided for @monthlyInsightLockedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lihat total bulanan, tren, piutang outstanding, dan merchant terbesar dengan Plus.'**
  String get monthlyInsightLockedSubtitle;

  /// No description provided for @monthlyInsightPreviousMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan sebelumnya'**
  String get monthlyInsightPreviousMonth;

  /// No description provided for @monthlyInsightNextMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan berikutnya'**
  String get monthlyInsightNextMonth;

  /// No description provided for @monthlyInsightTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get monthlyInsightTotal;

  /// No description provided for @monthlyInsightAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata bill'**
  String get monthlyInsightAverage;

  /// No description provided for @monthlyInsightBills.
  ///
  /// In id, this message translates to:
  /// **'Bill'**
  String get monthlyInsightBills;

  /// No description provided for @monthlyInsightOutstanding.
  ///
  /// In id, this message translates to:
  /// **'Outstanding'**
  String get monthlyInsightOutstanding;

  /// No description provided for @monthlyInsightTopMerchants.
  ///
  /// In id, this message translates to:
  /// **'Merchant terbesar'**
  String get monthlyInsightTopMerchants;

  /// No description provided for @monthlyInsightIncrease.
  ///
  /// In id, this message translates to:
  /// **'Naik {percent}% dibanding bulan lalu'**
  String monthlyInsightIncrease(String percent);

  /// No description provided for @monthlyInsightDecrease.
  ///
  /// In id, this message translates to:
  /// **'Turun {percent}% dibanding bulan lalu'**
  String monthlyInsightDecrease(String percent);

  /// No description provided for @monthlyInsightNoChange.
  ///
  /// In id, this message translates to:
  /// **'Tidak berubah dibanding bulan lalu'**
  String get monthlyInsightNoChange;

  /// No description provided for @splitSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian per Orang'**
  String get splitSummaryTitle;

  /// No description provided for @splitSummaryNoItems.
  ///
  /// In id, this message translates to:
  /// **'Belum ambil item.'**
  String get splitSummaryNoItems;

  /// No description provided for @splitSummarySubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get splitSummarySubtotal;

  /// No description provided for @splitSummaryTax.
  ///
  /// In id, this message translates to:
  /// **'Pajak (proporsional)'**
  String get splitSummaryTax;

  /// No description provided for @splitSummaryService.
  ///
  /// In id, this message translates to:
  /// **'Service (proporsional)'**
  String get splitSummaryService;

  /// No description provided for @splitSummaryShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get splitSummaryShare;

  /// No description provided for @participantShareAgain.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ulang'**
  String get participantShareAgain;

  /// No description provided for @billReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Review bill'**
  String get billReviewTitle;

  /// No description provided for @billReviewAddItem.
  ///
  /// In id, this message translates to:
  /// **'Tambah item'**
  String get billReviewAddItem;

  /// No description provided for @billReviewDeleteItemTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus item?'**
  String get billReviewDeleteItemTitle;

  /// No description provided for @billReviewDeleteItemBody.
  ///
  /// In id, this message translates to:
  /// **'Item \"{name}\" akan dihapus.'**
  String billReviewDeleteItemBody(String name);

  /// No description provided for @billReviewMerchantHint.
  ///
  /// In id, this message translates to:
  /// **'Nama merchant'**
  String get billReviewMerchantHint;

  /// No description provided for @billReviewItemNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama item'**
  String get billReviewItemNameHint;

  /// No description provided for @billReviewUnnamedItem.
  ///
  /// In id, this message translates to:
  /// **'tanpa nama'**
  String get billReviewUnnamedItem;

  /// No description provided for @billReviewUnitPriceLabel.
  ///
  /// In id, this message translates to:
  /// **'Harga / unit'**
  String get billReviewUnitPriceLabel;

  /// No description provided for @billReviewTaxLabel.
  ///
  /// In id, this message translates to:
  /// **'Pajak'**
  String get billReviewTaxLabel;

  /// No description provided for @billReviewServiceLabel.
  ///
  /// In id, this message translates to:
  /// **'Service'**
  String get billReviewServiceLabel;

  /// No description provided for @billReviewSaveBill.
  ///
  /// In id, this message translates to:
  /// **'Simpan Bill'**
  String get billReviewSaveBill;

  /// No description provided for @billReviewCurrencyPlusTitle.
  ///
  /// In id, this message translates to:
  /// **'Currency per bill'**
  String get billReviewCurrencyPlusTitle;

  /// No description provided for @billReviewCurrencyPlusDetail.
  ///
  /// In id, this message translates to:
  /// **'Mengubah currency per bill adalah fitur Plus. Pengguna Free tetap memakai mata uang default dari Pengaturan.'**
  String get billReviewCurrencyPlusDetail;

  /// No description provided for @billReviewAiLowConfidence.
  ///
  /// In id, this message translates to:
  /// **'AI kurang yakin ({percent}%) — periksa angka.'**
  String billReviewAiLowConfidence(String percent);

  /// No description provided for @billReviewMismatch.
  ///
  /// In id, this message translates to:
  /// **'Total {computed} berbeda dari struk ({detected}). Periksa lagi.'**
  String billReviewMismatch(String computed, String detected);

  /// No description provided for @billReviewTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Judul tidak boleh kosong.'**
  String get billReviewTitleRequired;

  /// No description provided for @billReviewItemsRequired.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan minimal satu item.'**
  String get billReviewItemsRequired;

  /// No description provided for @billReviewInvalidItem.
  ///
  /// In id, this message translates to:
  /// **'Periksa nama, harga, dan qty setiap item.'**
  String get billReviewInvalidItem;

  /// No description provided for @billReviewSaveBillFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal simpan bill: {message}'**
  String billReviewSaveBillFailed(String message);

  /// No description provided for @billReviewSaveItemsFailed.
  ///
  /// In id, this message translates to:
  /// **'Bill tersimpan tapi item gagal: {message}'**
  String billReviewSaveItemsFailed(String message);

  /// No description provided for @billSplitTitle.
  ///
  /// In id, this message translates to:
  /// **'Split bill'**
  String get billSplitTitle;

  /// No description provided for @billSplitBackTooltip.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get billSplitBackTooltip;

  /// No description provided for @billSplitDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get billSplitDone;

  /// No description provided for @billSplitAddPersonTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah orang'**
  String get billSplitAddPersonTitle;

  /// No description provided for @billSplitNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get billSplitNameHint;

  /// No description provided for @billSplitAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get billSplitAdd;

  /// No description provided for @billSplitEmptyItems.
  ///
  /// In id, this message translates to:
  /// **'Bill ini belum punya item.'**
  String get billSplitEmptyItems;

  /// No description provided for @billSplitTotalBill.
  ///
  /// In id, this message translates to:
  /// **'Total tagihan'**
  String get billSplitTotalBill;

  /// No description provided for @billSplitAllAssigned.
  ///
  /// In id, this message translates to:
  /// **'Semua item sudah dibagi'**
  String get billSplitAllAssigned;

  /// No description provided for @billSplitUnassigned.
  ///
  /// In id, this message translates to:
  /// **'Belum dibagi: {amount}'**
  String billSplitUnassigned(String amount);

  /// No description provided for @billSplitViewSummary.
  ///
  /// In id, this message translates to:
  /// **'Lihat Rincian'**
  String get billSplitViewSummary;

  /// No description provided for @billSplitStateNotReady.
  ///
  /// In id, this message translates to:
  /// **'State belum siap.'**
  String get billSplitStateNotReady;

  /// No description provided for @billSplitNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong.'**
  String get billSplitNameRequired;

  /// No description provided for @billSplitAddPersonFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal tambah orang: {message}'**
  String billSplitAddPersonFailed(String message);

  /// No description provided for @billSplitSelectPersonFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih dulu orang di bawah.'**
  String get billSplitSelectPersonFirst;

  /// No description provided for @billSplitSaveAssignmentFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal simpan assignment: {message}'**
  String billSplitSaveAssignmentFailed(String message);

  /// No description provided for @billSplitRemoveParticipantTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus partisipan?'**
  String get billSplitRemoveParticipantTitle;

  /// No description provided for @billSplitRemoveParticipantMessage.
  ///
  /// In id, this message translates to:
  /// **'Semua item yang ditugaskan ke {name} juga akan dihapus.'**
  String billSplitRemoveParticipantMessage(String name);

  /// No description provided for @billSplitRemoveParticipantConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get billSplitRemoveParticipantConfirm;

  /// No description provided for @billSplitRemoveParticipantFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal hapus partisipan: {message}'**
  String billSplitRemoveParticipantFailed(String message);

  /// No description provided for @billSplitParticipantBarHint.
  ///
  /// In id, this message translates to:
  /// **'Tekan lama peserta untuk menghapus'**
  String get billSplitParticipantBarHint;

  /// No description provided for @participantPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor (opsional)'**
  String get participantPhoneLabel;

  /// No description provided for @participantSuggestionTitle.
  ///
  /// In id, this message translates to:
  /// **'Sering dipakai'**
  String get participantSuggestionTitle;

  /// No description provided for @participantImportFromContacts.
  ///
  /// In id, this message translates to:
  /// **'Import dari kontak'**
  String get participantImportFromContacts;

  /// No description provided for @participantImportFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka kontak. Coba lagi atau tambah manual.'**
  String get participantImportFailed;

  /// No description provided for @participantImportNoPhone.
  ///
  /// In id, this message translates to:
  /// **'(kontak ini tidak punya nomor)'**
  String get participantImportNoPhone;

  /// No description provided for @billDetailParticipantPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'No HP'**
  String get billDetailParticipantPhoneLabel;

  /// No description provided for @billDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Tagihan'**
  String get billDetailTitle;

  /// No description provided for @billDetailHomeTooltip.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get billDetailHomeTooltip;

  /// No description provided for @billDetailScanAnotherTooltip.
  ///
  /// In id, this message translates to:
  /// **'Scan struk lain'**
  String get billDetailScanAnotherTooltip;

  /// No description provided for @billDetailLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat detail…'**
  String get billDetailLoading;

  /// No description provided for @billDetailParticipants.
  ///
  /// In id, this message translates to:
  /// **'Partisipan'**
  String get billDetailParticipants;

  /// No description provided for @billDetailTotalBill.
  ///
  /// In id, this message translates to:
  /// **'Total tagihan'**
  String get billDetailTotalBill;

  /// No description provided for @billDetailPaidProgress.
  ///
  /// In id, this message translates to:
  /// **'{paidCount}/{totalCount} partisipan sudah bayar'**
  String billDetailPaidProgress(int paidCount, int totalCount);

  /// No description provided for @billDetailSettled.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get billDetailSettled;

  /// No description provided for @billDetailUnsettled.
  ///
  /// In id, this message translates to:
  /// **'Belum lunas'**
  String get billDetailUnsettled;

  /// No description provided for @billDetailEmptyParticipants.
  ///
  /// In id, this message translates to:
  /// **'Belum ada partisipan untuk tagihan ini.'**
  String get billDetailEmptyParticipants;

  /// No description provided for @billDetailGoToSplit.
  ///
  /// In id, this message translates to:
  /// **'Pergi ke Pembagian'**
  String get billDetailGoToSplit;

  /// No description provided for @billDetailParticipantNotFound.
  ///
  /// In id, this message translates to:
  /// **'Partisipan tidak ditemukan.'**
  String get billDetailParticipantNotFound;

  /// No description provided for @billDetailSaveStatusFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal simpan status: {message}'**
  String billDetailSaveStatusFailed(String message);

  /// No description provided for @billDetailStateNotReady.
  ///
  /// In id, this message translates to:
  /// **'Data belum siap, coba lagi sebentar.'**
  String get billDetailStateNotReady;

  /// No description provided for @exportPdf.
  ///
  /// In id, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportPdfPlusLocked.
  ///
  /// In id, this message translates to:
  /// **'Export PDF (Plus)'**
  String get exportPdfPlusLocked;

  /// No description provided for @exportCsv.
  ///
  /// In id, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvPlusLocked.
  ///
  /// In id, this message translates to:
  /// **'Export CSV (Plus)'**
  String get exportCsvPlusLocked;

  /// No description provided for @exportPlusDetail.
  ///
  /// In id, this message translates to:
  /// **'Export PDF dan CSV adalah fitur Plus. Pengguna Free tetap bisa melihat dan membagikan rincian peserta versi basic.'**
  String get exportPlusDetail;

  /// No description provided for @exportFailed.
  ///
  /// In id, this message translates to:
  /// **'Export belum bisa dibuat. Coba lagi.'**
  String get exportFailed;

  /// No description provided for @exportPdfSubject.
  ///
  /// In id, this message translates to:
  /// **'Export {title}'**
  String exportPdfSubject(String title);

  /// No description provided for @exportPdfShareText.
  ///
  /// In id, this message translates to:
  /// **'Export PDF untuk {title}'**
  String exportPdfShareText(String title);

  /// No description provided for @exportCsvSubject.
  ///
  /// In id, this message translates to:
  /// **'Export {title}'**
  String exportCsvSubject(String title);

  /// No description provided for @exportCsvShareText.
  ///
  /// In id, this message translates to:
  /// **'Export CSV untuk {title}'**
  String exportCsvShareText(String title);

  /// No description provided for @splitSummaryCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get splitSummaryCopy;

  /// No description provided for @splitSummaryCopied.
  ///
  /// In id, this message translates to:
  /// **'Disalin ke clipboard'**
  String get splitSummaryCopied;

  /// No description provided for @splitShareFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa membagikan'**
  String get splitShareFailed;

  /// No description provided for @settlementTemplateBasic.
  ///
  /// In id, this message translates to:
  /// **'Basic'**
  String get settlementTemplateBasic;

  /// No description provided for @settlementTemplateCompact.
  ///
  /// In id, this message translates to:
  /// **'Pesan ringkas'**
  String get settlementTemplateCompact;

  /// No description provided for @settlementTemplateDetailed.
  ///
  /// In id, this message translates to:
  /// **'Pesan rinci'**
  String get settlementTemplateDetailed;

  /// No description provided for @settlementTemplateAll.
  ///
  /// In id, this message translates to:
  /// **'Rekap semua peserta'**
  String get settlementTemplateAll;

  /// No description provided for @settlementTemplatePlusLocked.
  ///
  /// In id, this message translates to:
  /// **'Template WhatsApp yang lebih rapi tersedia dengan Plus.'**
  String get settlementTemplatePlusLocked;

  /// No description provided for @settlementMessageBillPrefix.
  ///
  /// In id, this message translates to:
  /// **'Rincian'**
  String get settlementMessageBillPrefix;

  /// No description provided for @settlementMessageRecapPrefix.
  ///
  /// In id, this message translates to:
  /// **'Rekap BagiStruk -'**
  String get settlementMessageRecapPrefix;

  /// No description provided for @settlementMessageFor.
  ///
  /// In id, this message translates to:
  /// **'Untuk'**
  String get settlementMessageFor;

  /// No description provided for @settlementMessageGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo {name}, bagianmu:'**
  String settlementMessageGreeting(String name);

  /// No description provided for @settlementMessageTransferNote.
  ///
  /// In id, this message translates to:
  /// **'Mohon transfer jika sudah sesuai. Terima kasih.'**
  String get settlementMessageTransferNote;

  /// No description provided for @settlementMessageItems.
  ///
  /// In id, this message translates to:
  /// **'Item kamu'**
  String get settlementMessageItems;

  /// No description provided for @settlementMessageUnnamedItem.
  ///
  /// In id, this message translates to:
  /// **'(tanpa nama)'**
  String get settlementMessageUnnamedItem;

  /// No description provided for @settlementMessageSharedWith.
  ///
  /// In id, this message translates to:
  /// **'dibagi {count}'**
  String settlementMessageSharedWith(int count);

  /// No description provided for @settlementMessageTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get settlementMessageTotal;

  /// No description provided for @settlementMessageStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get settlementMessageStatus;

  /// No description provided for @settlementMessagePaid.
  ///
  /// In id, this message translates to:
  /// **'lunas'**
  String get settlementMessagePaid;

  /// No description provided for @settlementMessageUnpaid.
  ///
  /// In id, this message translates to:
  /// **'belum lunas'**
  String get settlementMessageUnpaid;

  /// No description provided for @settlementMessageGrandTotal.
  ///
  /// In id, this message translates to:
  /// **'Total bill'**
  String get settlementMessageGrandTotal;

  /// No description provided for @settlementMessageOutstanding.
  ///
  /// In id, this message translates to:
  /// **'Belum lunas'**
  String get settlementMessageOutstanding;

  /// No description provided for @settlementMessageWhatsappLink.
  ///
  /// In id, this message translates to:
  /// **'Chat via WhatsApp: {url}'**
  String settlementMessageWhatsappLink(String url);

  /// No description provided for @settlementPromoFooter.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dengan BagiStruk. Coba aplikasinya di Google Play: {url}'**
  String settlementPromoFooter(String url);

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get aboutTitle;

  /// No description provided for @aboutSettingsTile.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutSettingsTile;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get aboutVersionLabel;

  /// No description provided for @aboutSectionApp.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi'**
  String get aboutSectionApp;

  /// No description provided for @aboutSectionAuthor.
  ///
  /// In id, this message translates to:
  /// **'Pembuat'**
  String get aboutSectionAuthor;

  /// No description provided for @aboutSectionSupport.
  ///
  /// In id, this message translates to:
  /// **'Dukung'**
  String get aboutSectionSupport;

  /// No description provided for @aboutAuthorName.
  ///
  /// In id, this message translates to:
  /// **'Alam Aby Bashit'**
  String get aboutAuthorName;

  /// No description provided for @aboutWebsite.
  ///
  /// In id, this message translates to:
  /// **'Situs Web'**
  String get aboutWebsite;

  /// No description provided for @aboutGithub.
  ///
  /// In id, this message translates to:
  /// **'GitHub'**
  String get aboutGithub;

  /// No description provided for @aboutLinkedin.
  ///
  /// In id, this message translates to:
  /// **'LinkedIn'**
  String get aboutLinkedin;

  /// No description provided for @aboutBuyMeACoffee.
  ///
  /// In id, this message translates to:
  /// **'Buy Me a Coffee'**
  String get aboutBuyMeACoffee;

  /// No description provided for @aboutSaweria.
  ///
  /// In id, this message translates to:
  /// **'Saweria'**
  String get aboutSaweria;

  /// No description provided for @aboutPatreon.
  ///
  /// In id, this message translates to:
  /// **'Patreon'**
  String get aboutPatreon;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get aboutPrivacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get privacyPolicyTitle;

  /// No description provided for @aboutTermsOfService.
  ///
  /// In id, this message translates to:
  /// **'Syarat dan Ketentuan'**
  String get aboutTermsOfService;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In id, this message translates to:
  /// **'Syarat dan Ketentuan'**
  String get termsOfServiceTitle;

  /// No description provided for @linkUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Tautan belum tersedia'**
  String get linkUnavailable;

  /// No description provided for @reviewSuspectThousandsBug.
  ///
  /// In id, this message translates to:
  /// **'Harga tampak memakai pemisah ribuan sebagai desimal. Mohon periksa tiap angka sebelum menyimpan.'**
  String get reviewSuspectThousandsBug;

  /// No description provided for @authFieldEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get authFieldPassword;

  /// No description provided for @authEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get authEmailRequired;

  /// No description provided for @authInvalidEmailFormat.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get authInvalidEmailFormat;

  /// No description provided for @authPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password wajib diisi'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get authPasswordMinLength;

  /// No description provided for @authShowPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan password'**
  String get authHidePassword;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authGoogleSigningIn.
  ///
  /// In id, this message translates to:
  /// **'Sedang masuk...'**
  String get authGoogleSigningIn;

  /// No description provided for @failureRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get failureRetry;

  /// No description provided for @failurePrefixNetwork.
  ///
  /// In id, this message translates to:
  /// **'Jaringan: {message}'**
  String failurePrefixNetwork(String message);

  /// No description provided for @failurePrefixServer.
  ///
  /// In id, this message translates to:
  /// **'Server ({code}): {message}'**
  String failurePrefixServer(String code, String message);

  /// No description provided for @failurePrefixServerNoCode.
  ///
  /// In id, this message translates to:
  /// **'Server: {message}'**
  String failurePrefixServerNoCode(String message);

  /// No description provided for @failurePrefixParsing.
  ///
  /// In id, this message translates to:
  /// **'Respons tidak terbaca: {message}'**
  String failurePrefixParsing(String message);

  /// No description provided for @failurePrefixAuth.
  ///
  /// In id, this message translates to:
  /// **'Autentikasi: {message}'**
  String failurePrefixAuth(String message);

  /// No description provided for @failurePrefixUnexpected.
  ///
  /// In id, this message translates to:
  /// **'Tidak terduga: {error}'**
  String failurePrefixUnexpected(String error);

  /// No description provided for @historyFilterActiveBadge.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get historyFilterActiveBadge;

  /// No description provided for @commonPlus.
  ///
  /// In id, this message translates to:
  /// **'Plus'**
  String get commonPlus;

  /// No description provided for @billReviewQtyLabel.
  ///
  /// In id, this message translates to:
  /// **'Qty'**
  String get billReviewQtyLabel;

  /// No description provided for @billReviewSubtotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get billReviewSubtotalLabel;

  /// No description provided for @billReviewTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get billReviewTotalLabel;

  /// No description provided for @exportLabelItems.
  ///
  /// In id, this message translates to:
  /// **'Item'**
  String get exportLabelItems;

  /// No description provided for @exportLabelParticipants.
  ///
  /// In id, this message translates to:
  /// **'Peserta'**
  String get exportLabelParticipants;

  /// No description provided for @exportLabelCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata Uang'**
  String get exportLabelCurrency;

  /// No description provided for @exportLabelName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get exportLabelName;

  /// No description provided for @exportLabelQty.
  ///
  /// In id, this message translates to:
  /// **'Qty'**
  String get exportLabelQty;

  /// No description provided for @exportLabelPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get exportLabelPrice;

  /// No description provided for @exportLabelSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get exportLabelSubtotal;

  /// No description provided for @exportLabelTax.
  ///
  /// In id, this message translates to:
  /// **'Pajak'**
  String get exportLabelTax;

  /// No description provided for @exportLabelService.
  ///
  /// In id, this message translates to:
  /// **'Service'**
  String get exportLabelService;

  /// No description provided for @exportLabelTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get exportLabelTotal;

  /// No description provided for @exportLabelStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get exportLabelStatus;

  /// No description provided for @exportLabelAssignedParticipants.
  ///
  /// In id, this message translates to:
  /// **'Partisipan yang ditugaskan'**
  String get exportLabelAssignedParticipants;

  /// No description provided for @exportLabelBillTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul'**
  String get exportLabelBillTitle;

  /// No description provided for @exportLabelReceiptDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal struk'**
  String get exportLabelReceiptDate;

  /// No description provided for @exportLabelCreatedAt.
  ///
  /// In id, this message translates to:
  /// **'Dibuat pada'**
  String get exportLabelCreatedAt;

  /// No description provided for @exportLabelTotalAmount.
  ///
  /// In id, this message translates to:
  /// **'Total tagihan'**
  String get exportLabelTotalAmount;

  /// No description provided for @exportLabelSettledYes.
  ///
  /// In id, this message translates to:
  /// **'ya'**
  String get exportLabelSettledYes;

  /// No description provided for @exportLabelSettledNo.
  ///
  /// In id, this message translates to:
  /// **'tidak'**
  String get exportLabelSettledNo;

  /// No description provided for @exportLabelPaidStatus.
  ///
  /// In id, this message translates to:
  /// **'lunas'**
  String get exportLabelPaidStatus;

  /// No description provided for @exportLabelUnpaidStatus.
  ///
  /// In id, this message translates to:
  /// **'belum lunas'**
  String get exportLabelUnpaidStatus;

  /// No description provided for @exportCsvTopTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Bill: {title}'**
  String exportCsvTopTitle(String title);

  /// No description provided for @exportPdfSubjectFallback.
  ///
  /// In id, this message translates to:
  /// **'Export PDF {title}'**
  String exportPdfSubjectFallback(String title);

  /// No description provided for @exportPdfShareTextFallback.
  ///
  /// In id, this message translates to:
  /// **'Export PDF untuk {title}'**
  String exportPdfShareTextFallback(String title);

  /// No description provided for @exportCsvSubjectFallback.
  ///
  /// In id, this message translates to:
  /// **'Export CSV {title}'**
  String exportCsvSubjectFallback(String title);

  /// No description provided for @exportCsvShareTextFallback.
  ///
  /// In id, this message translates to:
  /// **'Export CSV untuk {title}'**
  String exportCsvShareTextFallback(String title);

  /// No description provided for @settlementMessageCompactTitle.
  ///
  /// In id, this message translates to:
  /// **'BagiStruk - {title}'**
  String settlementMessageCompactTitle(String title);

  /// No description provided for @settlementMessageDetailedTitle.
  ///
  /// In id, this message translates to:
  /// **'BagiStruk - {title}'**
  String settlementMessageDetailedTitle(String title);

  /// No description provided for @settlementMessageBasicTitle.
  ///
  /// In id, this message translates to:
  /// **'{title}'**
  String settlementMessageBasicTitle(String title);

  /// No description provided for @billDetailParticipantPhoneHint.
  ///
  /// In id, this message translates to:
  /// **'Telepon (opsional)'**
  String get billDetailParticipantPhoneHint;

  /// No description provided for @appInitErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'BagiStruk gagal dimulai'**
  String get appInitErrorTitle;

  /// No description provided for @appInitErrorRetryHint.
  ///
  /// In id, this message translates to:
  /// **'Cek koneksi internet, lalu buka ulang aplikasi. Kalau masih bermasalah, periksa file .env dan setting Supabase.'**
  String get appInitErrorRetryHint;

  /// No description provided for @appInitErrorEnvLoad.
  ///
  /// In id, this message translates to:
  /// **'Gagal muat konfigurasi (.env): {message}'**
  String appInitErrorEnvLoad(String message);

  /// No description provided for @appInitErrorSupabase.
  ///
  /// In id, this message translates to:
  /// **'Gagal inisialisasi Supabase: {message}'**
  String appInitErrorSupabase(String message);

  /// No description provided for @paywallTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan riwayat & lacak piutang'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar atau masuk untuk menyimpan riwayat dan melacak piutangmu.'**
  String get paywallSubtitle;

  /// No description provided for @paywallRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get paywallRegister;

  /// No description provided for @paywallLogin.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get paywallLogin;

  /// No description provided for @scanEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto struk belanja atau makan bareng untuk mulai berbagi adil!'**
  String get scanEmptyHint;

  /// No description provided for @adPrivacyChoicesTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilihan privasi iklan'**
  String get adPrivacyChoicesTitle;

  /// No description provided for @adPrivacyChoicesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau atau ubah persetujuan iklan bila diwajibkan.'**
  String get adPrivacyChoicesSubtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In id, this message translates to:
  /// **'Mulai scan struk'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onboardingSkip;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur preferensi'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesBody.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa, mata uang default, dan tema untuk aplikasi.'**
  String get onboardingPreferencesBody;

  /// No description provided for @onboardingPreferencesLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa aplikasi'**
  String get onboardingPreferencesLanguage;

  /// No description provided for @onboardingPreferencesCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang default'**
  String get onboardingPreferencesCurrency;

  /// No description provided for @onboardingPreferencesTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema aplikasi'**
  String get onboardingPreferencesTheme;

  /// No description provided for @onboardingPreferencesChangeLater.
  ///
  /// In id, this message translates to:
  /// **'Semuanya bisa diubah nanti di Pengaturan.'**
  String get onboardingPreferencesChangeLater;

  /// No description provided for @onboardingPreferencesSaveError.
  ///
  /// In id, this message translates to:
  /// **'Preferensi gagal disimpan. Coba lagi.'**
  String get onboardingPreferencesSaveError;

  /// No description provided for @onboardingTitle1.
  ///
  /// In id, this message translates to:
  /// **'Scan struk'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In id, this message translates to:
  /// **'Foto atau pilih struk. BagiStruk membaca item dan total secara otomatis.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In id, this message translates to:
  /// **'Atur bagian'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In id, this message translates to:
  /// **'Atur bagian tiap orang. Tambah teman, lalu pilih item yang mereka pesan.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In id, this message translates to:
  /// **'Tagih sampai lunas'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In id, this message translates to:
  /// **'Bagikan rincian ke WhatsApp dan tandai pembayaran saat sudah masuk.'**
  String get onboardingBody3;

  /// No description provided for @onboardingReplayFinish.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get onboardingReplayFinish;

  /// No description provided for @onboardingSettingsTile.
  ///
  /// In id, this message translates to:
  /// **'Lihat panduan aplikasi'**
  String get onboardingSettingsTile;

  /// No description provided for @onboardingSaveError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get onboardingSaveError;

  /// No description provided for @ocrAiDisclosure.
  ///
  /// In id, this message translates to:
  /// **'Foto struk diproses oleh layanan AI pihak ketiga untuk ekstraksi item.'**
  String get ocrAiDisclosure;

  /// No description provided for @manualBillAction.
  ///
  /// In id, this message translates to:
  /// **'Buat manual'**
  String get manualBillAction;

  /// No description provided for @manualBillEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Tanpa foto struk — tambah item manual, gratis tanpa credit.'**
  String get manualBillEmptyHint;

  /// No description provided for @billSplitAssignAll.
  ///
  /// In id, this message translates to:
  /// **'Bagi rata'**
  String get billSplitAssignAll;

  /// No description provided for @billSplitDuplicateName.
  ///
  /// In id, this message translates to:
  /// **'Nama sudah ada di bill ini.'**
  String get billSplitDuplicateName;

  /// No description provided for @billSplitOverwriteContactTitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti dengan kontak?'**
  String get billSplitOverwriteContactTitle;

  /// No description provided for @billSplitOverwriteContactBody.
  ///
  /// In id, this message translates to:
  /// **'Field sudah terisi. Ganti dengan data kontak yang dipilih?'**
  String get billSplitOverwriteContactBody;

  /// No description provided for @billSplitOverwriteContactConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ganti'**
  String get billSplitOverwriteContactConfirm;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan belum lunas'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In id, this message translates to:
  /// **'{title} ({total}) masih ada yang belum bayar. Ketuk untuk menagih.'**
  String reminderNotificationBody(String title, String total);

  /// No description provided for @reminderScheduled.
  ///
  /// In id, this message translates to:
  /// **'Pengingat ditagih dalam {days} hari.'**
  String reminderScheduled(int days);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'id':
      return AppL10nId();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
