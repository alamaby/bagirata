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

  /// No description provided for @guestAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun Tamu'**
  String get guestAccount;

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

  /// No description provided for @currencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Mata Uang Default'**
  String get currencyLabel;

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

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get errorGeneric;

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

  /// No description provided for @historyEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bill tersimpan.\nMulai scan struk dari tab Scan.'**
  String get historyEmptyMessage;

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

  /// No description provided for @splitSummaryShareWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ke WhatsApp'**
  String get splitSummaryShareWhatsapp;

  /// No description provided for @splitWhatsappFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa buka WhatsApp'**
  String get splitWhatsappFailed;
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
