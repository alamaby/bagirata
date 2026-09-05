// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get registerMarketingOptIn =>
      'Saya ingin menerima email promosi, berita fitur, dan tips dari BagiStruk.';

  @override
  String get postLoginWelcomeTitle => 'Selamat datang di BagiStruk!';

  @override
  String get postLoginWelcomeBody =>
      'Beri tahu kami apakah Anda ingin menerima email promosi, berita fitur, dan tips dari kami. Anda bisa mengubah preferensi ini kapan saja dari Settings.';

  @override
  String get postLoginWelcomeOptIn =>
      'Kirim saya email promosi, berita fitur, dan tips.';

  @override
  String get postLoginWelcomeContinue => 'Lanjutkan';

  @override
  String get postLoginWelcomeErrorSave => 'Gagal menyimpan. Coba lagi.';

  @override
  String get registerErrorSaveProfile =>
      'Akun Anda berhasil dibuat, tetapi kami tidak dapat menyimpan preferensi Anda. Coba lagi dari Settings setelah verifikasi email.';

  @override
  String get settingsMarketingOptIn => 'Email promosi';

  @override
  String get settingsMarketingOptInSubtitle =>
      'Tips, info fitur, dan penawaran dari BagiStruk.';

  @override
  String get settingsMarketingOptInWebHint =>
      'Anda juga bisa mengelola preferensi ini dari situs web BagiStruk.';

  @override
  String get settingsTitle => 'Profil & Pengaturan';

  @override
  String get settingsTab => 'Pengaturan';

  @override
  String get scanTab => 'Pindai';

  @override
  String get historyTab => 'Riwayat';

  @override
  String get scanScreenTitle => 'Pindai Struk';

  @override
  String get scanAddPhotos => 'Tambah Foto';

  @override
  String get scanAction => 'Pindai';

  @override
  String get scanInProgress => 'Memindai…';

  @override
  String get scanSourceSheetTitle => 'Tambah foto struk';

  @override
  String get scanSourceCamera => 'Kamera';

  @override
  String get scanSourceGallery => 'Galeri';

  @override
  String get scanCameraContinuePrompt => 'Foto lagi untuk struk panjang?';

  @override
  String get scanCameraTakeAnother => 'Foto Lagi';

  @override
  String get scanCameraDone => 'Selesai';

  @override
  String shareImagesAdded(int count) {
    return '$count foto dari bagikan ditambahkan. Memulai pindaian...';
  }

  @override
  String get scanNotReceiptTitle => 'Foto bukan struk';

  @override
  String get scanNotReceiptHint =>
      'Gambar yang dipilih sepertinya bukan struk. Coba foto struk yang jelas.';

  @override
  String scanPreparingSessionFailed(String message) {
    return 'Gagal siapkan sesi: $message';
  }

  @override
  String scanCreditCheckFailed(String message) {
    return 'Gagal cek credit scan: $message';
  }

  @override
  String scanCreditCostWithBalance(
    int imageCount,
    int creditCost,
    int balance,
  ) {
    return '$imageCount foto akan memakai $creditCost credit. Sisa: $balance.';
  }

  @override
  String scanCreditRequired(int requiredCredits, int balance) {
    return 'Scan ini butuh $requiredCredits credit. Sisa credit kamu: $balance.';
  }

  @override
  String get scanNoCreditAnonymousTitle => 'Batas scan gratis tercapai';

  @override
  String get scanNoCreditFreeTitle => 'Credit scan bulan ini habis';

  @override
  String get scanNoCreditAnonymousBody =>
      'Kamu sudah memakai 5 credit scan sebagai pengguna anonim. Daftar akun untuk mendapat 20 credit gratis setiap bulan.';

  @override
  String scanNoCreditPlusBody(int monthlyAllowance) {
    return 'Kamu sudah memakai $monthlyAllowance credit Plus bulan ini. Credit akan tersedia lagi pada periode berikutnya.';
  }

  @override
  String scanNoCreditFreeBody(int monthlyAllowance) {
    return 'Kamu sudah memakai $monthlyAllowance credit gratis bulan ini. Upgrade ke Plus untuk 60 credit/bulan, tanpa iklan, dan fitur khusus Plus.';
  }

  @override
  String get scanNoCreditLater => 'Nanti';

  @override
  String get scanNoCreditRegister => 'Daftar';

  @override
  String get scanNoCreditPlusSoon => 'Plus segera hadir';

  @override
  String get scanStatusPreparingImages => 'Memproses gambar…';

  @override
  String get scanStatusIdle => 'Tambah foto lalu tap Pindai';

  @override
  String scanStatusScanning(int imageCount) {
    return 'Memindai $imageCount gambar…';
  }

  @override
  String scanStatusSuccess(int itemCount, String provider) {
    return '$itemCount item terdeteksi via $provider';
  }

  @override
  String get ocrErrorNetworkTitle => 'Tidak ada koneksi';

  @override
  String get ocrErrorNetworkBody =>
      'Periksa koneksi internetmu, lalu coba scan ulang.';

  @override
  String get ocrErrorAuthTitle => 'Sesi berakhir';

  @override
  String get ocrErrorAuthBody =>
      'Sesi kamu sudah habis. Silakan masuk lagi untuk melanjutkan.';

  @override
  String get ocrErrorParsingTitle => 'Respons tidak terbaca';

  @override
  String get ocrErrorParsingBody =>
      'Hasil scan dari server tidak dapat diproses. Coba foto ulang dengan pencahayaan lebih baik.';

  @override
  String get ocrErrorUnknownTitle => 'Terjadi kesalahan';

  @override
  String get ocrErrorUnknownBody =>
      'Sesuatu tidak berjalan semestinya. Coba lagi sebentar.';

  @override
  String get ocrErrorNotReceiptTitle => 'Foto bukan struk';

  @override
  String get ocrErrorNotReceiptBody =>
      'Gambar yang dipilih sepertinya bukan struk belanja. Coba foto struk yang jelas dan tidak terpotong.';

  @override
  String get ocrErrorCreditTitle => 'Credit scan habis';

  @override
  String get ocrErrorCreditBody =>
      'Tambah credit atau tunggu periode berikutnya untuk scan lagi.';

  @override
  String get ocrErrorAiBusyTitle => 'Layanan AI sedang sibuk';

  @override
  String get ocrErrorAiBusyBody =>
      'Server AI sedang menerima banyak permintaan. Tunggu beberapa saat, lalu coba scan lagi.';

  @override
  String get ocrErrorRateLimitTitle => 'Terlalu banyak permintaan';

  @override
  String get ocrErrorRateLimitBody =>
      'Kamu mencapai batas scan untuk saat ini. Coba lagi dalam beberapa menit.';

  @override
  String get ocrErrorForbiddenTitle => 'Akses ditolak';

  @override
  String get ocrErrorForbiddenBody =>
      'Server menolak permintaan. Coba keluar dan masuk lagi.';

  @override
  String get ocrErrorTimeoutTitle => 'Permintaan kelamaan';

  @override
  String get ocrErrorTimeoutBody =>
      'Server butuh waktu terlalu lama merespons. Coba lagi.';

  @override
  String get ocrErrorServerTitle => 'Server bermasalah';

  @override
  String get ocrErrorServerBody =>
      'Server sedang tidak stabil. Tunggu sebentar lalu coba lagi.';

  @override
  String get ocrErrorGenericTitle => 'Scan gagal';

  @override
  String get ocrErrorGenericBody =>
      'Tidak bisa memproses struk ini. Coba foto ulang atau gunakan gambar lain.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get accountSection => 'Akun';

  @override
  String get preferencesSection => 'Preferensi';

  @override
  String get displayNameFallback => 'Pengguna BagiStruk';

  @override
  String get anonDisplayName => 'Saya';

  @override
  String get guestAccount => 'Akun Tamu';

  @override
  String get creditScanTitle => 'Credit scan';

  @override
  String get creditStatusLoading => 'Memuat status credit...';

  @override
  String creditStatusRemaining(
    int balance,
    int monthlyAllowance,
    String planCode,
  ) {
    return '$balance/$monthlyAllowance tersisa ($planCode)';
  }

  @override
  String get billingTitle => 'Plus dan paket credit';

  @override
  String get billingAnonSubtitle =>
      'Daftar akun dulu untuk membeli Plus atau top-up credit.';

  @override
  String creditPlusExpiresAt(String date) {
    return 'Plus berakhir: $date';
  }

  @override
  String creditTrialExpiresAt(String date) {
    return 'Masa percobaan Plus berakhir: $date';
  }

  @override
  String get billingPlusActive => 'Plus aktif';

  @override
  String get billingPlanFree => 'Free';

  @override
  String get billingPlusCardTitle => 'BagiStruk Plus';

  @override
  String get billingPlusBenefitCredits => '60 credit OCR per bulan';

  @override
  String get billingPlusBenefitNoAds => 'Tanpa iklan';

  @override
  String get billingPlusBenefitFeatures => 'Akses fitur Plus';

  @override
  String get billingTopUpCardTitle => 'Top up credit OCR';

  @override
  String get billingManageSubscription => 'Kelola langganan';

  @override
  String get billingManageOpenFailed =>
      'Tidak dapat membuka pengelolaan langganan.';

  @override
  String get billingUpgradePlus => 'Upgrade Plus';

  @override
  String billingUpgradePlusWithPrice(String price) {
    return 'Berlangganan bulanan • $price';
  }

  @override
  String billingCreditPackTitle(int credits) {
    return '$credits credit';
  }

  @override
  String get billingBuyAction => 'Beli';

  @override
  String get billingBuyCredits => 'Beli 50 credit';

  @override
  String get billingLoading => 'Memuat...';

  @override
  String get billingRestorePurchases => 'Pulihkan langganan';

  @override
  String get billingUnavailable =>
      'Google Play Billing belum tersedia di perangkat ini.';

  @override
  String get billingProductsNotActive =>
      'Beberapa produk belum aktif di Play Console.';

  @override
  String get billingProductsLoadFailed => 'Produk belum bisa dimuat.';

  @override
  String get billingOpeningPlay => 'Membuka Google Play...';

  @override
  String get billingPurchaseStartFailed => 'Pembelian belum bisa dimulai.';

  @override
  String get billingRestoringPurchases => 'Memulihkan pembelian...';

  @override
  String get billingRestoreFailed => 'Pembelian belum bisa dipulihkan.';

  @override
  String get billingPaymentPending => 'Menunggu pembayaran Google Play...';

  @override
  String get billingPurchaseFailed => 'Pembelian dibatalkan atau gagal.';

  @override
  String get billingPurchaseSuccess => 'Pembelian berhasil diproses.';

  @override
  String get billingPurchaseVerifyFailed =>
      'Pembelian belum bisa diverifikasi.';

  @override
  String get changeName => 'Ubah Nama';

  @override
  String get changeNameSheetTitle => 'Ubah Nama Tampilan';

  @override
  String get changeNameHint => 'Nama tampilan';

  @override
  String get saveAction => 'Simpan';

  @override
  String get cancelAction => 'Batal';

  @override
  String get plusOnlyShort => 'Khusus Plus.';

  @override
  String get transferBankSettingsTitle => 'Info bank transfer';

  @override
  String get transferBankSettingsSubtitle =>
      'Tambahkan rekening untuk pesan WhatsApp settlement.';

  @override
  String get transferBankSettingsLockedSubtitle =>
      'Khusus Plus. Info bank bisa ikut di pesan WhatsApp settlement.';

  @override
  String get transferBankScreenTitle => 'Bank Transfer';

  @override
  String get transferBankNameLabel => 'Nama bank';

  @override
  String get transferAccountNameLabel => 'Nama pemilik rekening';

  @override
  String get transferAccountNumberLabel => 'Nomor rekening';

  @override
  String get transferBankShareTitle => 'Transfer ke';

  @override
  String get transferBankShareHint =>
      'Kalau terisi, info ini ikut muncul di pesan yang dibagikan ke WhatsApp.';

  @override
  String get transferBankPlusOnly =>
      'Info bank transfer adalah fitur Plus. Upgrade untuk menyimpan rekening dan menambahkannya ke pesan settlement.';

  @override
  String get transferBankRequired =>
      'Lengkapi field ini atau kosongkan semuanya.';

  @override
  String get transferBankSaved => 'Info bank transfer tersimpan.';

  @override
  String get transferBankClear => 'Kosongkan info bank';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordConfirmTitle => 'Kirim email reset password?';

  @override
  String resetPasswordConfirmBody(String email) {
    return 'Kami akan mengirim tautan reset password ke $email.';
  }

  @override
  String get resetPasswordSent => 'Email reset password telah dikirim.';

  @override
  String get resetPasswordScreenTitle => 'Atur Ulang Password';

  @override
  String get resetPasswordScreenHeading => 'Buat Password Baru';

  @override
  String get resetPasswordScreenBody =>
      'Masukkan password baru untuk akun Anda. Setelah disimpan, Anda akan kembali ke Pengaturan.';

  @override
  String get resetPasswordNewLabel => 'Password Baru';

  @override
  String get resetPasswordConfirmLabel => 'Konfirmasi Password';

  @override
  String get resetPasswordSaveAction => 'Simpan Password';

  @override
  String get resetPasswordMinChars => 'Minimal 8 karakter';

  @override
  String get resetPasswordNeedsAlphaDigit => 'Harus mengandung huruf dan angka';

  @override
  String get resetPasswordMismatch => 'Password tidak cocok';

  @override
  String get resetPasswordSuccess => 'Password berhasil diubah';

  @override
  String get resetPasswordSessionExpired =>
      'Sesi reset sudah berakhir. Silakan minta link baru.';

  @override
  String get currencyLabel => 'Mata Uang Default';

  @override
  String get currencySearchHint => 'Cari mata uang';

  @override
  String get currencySearchEmpty => 'Mata uang tidak ditemukan.';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get themeLabel => 'Tema Tampilan';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Ikuti Sistem';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get logout => 'Logout';

  @override
  String get registerPermanent => 'Daftar Akun Permanen';

  @override
  String get confirmLogoutTitle => 'Keluar dari akun?';

  @override
  String get confirmLogoutBody =>
      'Anda akan keluar dan kembali sebagai pengguna tamu.';

  @override
  String get deleteAccount => 'Hapus Akun';

  @override
  String get deleteAccountSubtitle =>
      'Hapus permanen akun dan data bill tersimpan.';

  @override
  String get deleteAccountConfirmTitle => 'Hapus akun kamu?';

  @override
  String get deleteAccountConfirmBody =>
      'Tindakan ini akan menghapus permanen akun, profil, bill tersimpan, item bill, peserta, pembagian item, dan status pelunasan. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get deleteAccountConfirmPhrase => 'HAPUS';

  @override
  String get deleteAccountTypeTitle => 'Ketik HAPUS untuk konfirmasi';

  @override
  String deleteAccountTypeBody(String phrase) {
    return 'Ketik $phrase untuk menghapus akun secara permanen.';
  }

  @override
  String get deleteAccountInProgress => 'Menghapus akun...';

  @override
  String get deleteAccountSuccess => 'Akun dan data tersimpan sudah dihapus.';

  @override
  String get deletedBillsTitle => 'Bill terhapus';

  @override
  String get deletedBillsSettingsSubtitle =>
      'Pulihkan bill yang dihapus dalam 30 hari terakhir.';

  @override
  String get deletedBillsSettingsLockedSubtitle =>
      'Khusus Plus. Pulihkan bill yang tidak sengaja dihapus dalam 30 hari.';

  @override
  String get deletedBillsLockedTitle => 'Pulihkan bill terhapus dengan Plus';

  @override
  String get deletedBillsLockedSubtitle =>
      'Bill terhapus disimpan selama 30 hari agar pengguna Plus bisa memulihkan penghapusan tidak sengaja.';

  @override
  String get deletedBillsEmpty => 'Belum ada bill terhapus.';

  @override
  String deletedBillDeletedAt(String date) {
    return 'Dihapus $date';
  }

  @override
  String deletedBillExpiresAt(String date) {
    return 'Bisa dipulihkan sampai $date';
  }

  @override
  String get deletedBillRestoreAction => 'Pulihkan';

  @override
  String get deletedBillRestored => 'Bill dipulihkan.';

  @override
  String get deleteBillAction => 'Hapus';

  @override
  String get deleteBillConfirmTitle => 'Hapus bill ini?';

  @override
  String deleteBillConfirmBody(String title, String total) {
    return '$title ($total) akan dipindahkan ke Bill terhapus. Pengguna Plus bisa memulihkannya dalam 30 hari.';
  }

  @override
  String get deleteBillSuccess => 'Bill dipindahkan ke Bill terhapus.';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get authErrorNetwork =>
      'Tidak ada koneksi internet. Coba lagi setelah jaringan stabil.';

  @override
  String authErrorServer(String message) {
    return 'Server bermasalah: $message. Coba lagi sebentar lagi.';
  }

  @override
  String get authErrorParsing => 'Respons server tidak terbaca. Coba lagi.';

  @override
  String get authErrorUnknown => 'Terjadi kesalahan tak terduga. Coba lagi.';

  @override
  String get authErrorInvalidLogin => 'Email atau password salah.';

  @override
  String get authErrorAlreadyRegistered => 'Email sudah terdaftar. Coba login.';

  @override
  String get authErrorWeakPassword =>
      'Password terlalu lemah. Minimal 6 karakter.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Email belum dikonfirmasi. Cek kotak masuk.';

  @override
  String get authErrorDisposableEmail =>
      'Email sementara/disposable tidak bisa digunakan. Pakai email utama kamu.';

  @override
  String get authErrorEmailAliasUsed =>
      'Email ini terdeteksi sebagai alias dari email yang sudah pernah digunakan.';

  @override
  String get authErrorInvalidEmail => 'Format email belum valid.';

  @override
  String get authErrorGoogleSignIn =>
      'Google Sign-In gagal setelah memilih akun. Coba lagi; jika tetap terjadi, cek OAuth Android package name, SHA-1 debug/release, dan Google Web Client ID.';

  @override
  String get authErrorComingSoon => 'Fitur ini akan segera hadir.';

  @override
  String get authErrorFallback => 'Autentikasi gagal. Coba lagi.';

  @override
  String get loading => 'Memuat...';

  @override
  String get noSessionMessage =>
      'Daftar atau masuk untuk mengakses pengaturan.';

  @override
  String get registerOrLogin => 'Daftar / Masuk';

  @override
  String get loginWelcomeBack => 'Selamat datang kembali';

  @override
  String get loginSubtitle => 'Masuk untuk melanjutkan ke BagiStruk.';

  @override
  String get loginSaveBanner => 'Daftar untuk menyimpan riwayat tagihanmu';

  @override
  String get loginResetExpiredBanner =>
      'Sesi reset password sudah berakhir. Silakan minta tautan baru dari Pengaturan.';

  @override
  String get loginButton => 'Masuk';

  @override
  String get loginOr => 'atau';

  @override
  String get loginEmailHint => 'kamu@email.com';

  @override
  String get loginOtpButton => 'Kirim kode email';

  @override
  String get loginOtpSending => 'Mengirim kode…';

  @override
  String get loginNoAccount => 'Belum punya akun? ';

  @override
  String get loginRegisterLink => 'Daftar';

  @override
  String get registerTitle => 'Daftar';

  @override
  String get registerBackToScanTooltip => 'Kembali ke Scan';

  @override
  String get registerSkip => 'Lewati';

  @override
  String get registerHeading => 'Buat akun baru';

  @override
  String get registerSubtitle => 'Simpan riwayat tagihanmu di semua perangkat.';

  @override
  String get registerPasswordHint => 'Minimal 6 karakter';

  @override
  String get registerHaveAccount => 'Sudah punya akun? ';

  @override
  String get registerLoginLink => 'Login';

  @override
  String get legalAcceptanceAppBarTitle => 'Persetujuan Hukum';

  @override
  String get legalAcceptanceTitle => 'Sebelum mulai…';

  @override
  String get legalAcceptanceIntro =>
      'Untuk menggunakan BagiStruk, mohon baca dan setujui dua dokumen di bawah ini. Kami membutuhkan persetujuan terpisah untuk Syarat Layanan dan Kebijakan Privasi.';

  @override
  String get legalAcceptanceReadTerms => 'Baca Syarat Layanan';

  @override
  String get legalAcceptanceReadPrivacy => 'Baca Kebijakan Privasi';

  @override
  String get legalAcceptanceAgreeTerms =>
      'Saya telah membaca dan menyetujui Syarat Layanan.';

  @override
  String get legalAcceptanceAgreePrivacy =>
      'Saya telah membaca dan menyetujui Kebijakan Privasi.';

  @override
  String get legalAcceptanceAgreeAge =>
      'Saya berusia 18 tahun ke atas, atau lebih tua jika diwajibkan oleh hukum lokal saya.';

  @override
  String get legalAcceptanceContinue => 'Lanjutkan';

  @override
  String get legalAcceptanceErrorSave =>
      'Gagal menyimpan persetujuan. Coba lagi.';

  @override
  String get verifyEmailTitle => 'Verifikasi email';

  @override
  String get verifyEmailBackTooltip => 'Kembali';

  @override
  String get verifyEmailHeading => 'Cek email kamu';

  @override
  String get verifyEmailBodyPrefix => 'Kami sudah mengirim link konfirmasi ke ';

  @override
  String get verifyEmailBodySuffix =>
      '. Klik link itu untuk mengaktifkan akunmu — sampai itu kamu belum bisa login dari perangkat lain.';

  @override
  String get verifyEmailAutonav =>
      'Setelah konfirmasi, kamu otomatis dipindahkan ke Riwayat.';

  @override
  String get verifyEmailResend => 'Kirim ulang email';

  @override
  String get verifyEmailResending => 'Mengirim…';

  @override
  String get verifyEmailResent => 'Email verifikasi sudah dikirim ulang.';

  @override
  String get verifyEmailUseDifferent => 'Pakai email lain';

  @override
  String get verifyOtpTitle => 'Masukkan kode';

  @override
  String get verifyOtpHeading => 'Cek kode email';

  @override
  String get verifyOtpBodyPrefix => 'Kami sudah mengirim kode 8 digit ke ';

  @override
  String get verifyOtpBodySuffix =>
      '. Masukkan kode itu untuk masuk ke akunmu.';

  @override
  String get verifyOtpInvalid => 'Masukkan kode 8 digit.';

  @override
  String get verifyOtpButton => 'Verifikasi & masuk';

  @override
  String get verifyOtpResend => 'Kirim ulang kode';

  @override
  String get verifyOtpResending => 'Mengirim…';

  @override
  String get verifyOtpResent => 'Kode baru sudah dikirim.';

  @override
  String verifyOtpResendCountdown(int seconds) {
    return 'Kirim ulang dalam ${seconds}d';
  }

  @override
  String get verifyOtpUseDifferent => 'Pakai email lain';

  @override
  String get historySignOutTooltip => 'Keluar';

  @override
  String get historySignedOut => 'Kamu sudah keluar.';

  @override
  String get historyLoadingMessage => 'Memuat riwayat…';

  @override
  String get historyTotalBills => 'Total bill';

  @override
  String get historyOutstanding => 'Piutang outstanding';

  @override
  String historyOutstandingCarouselPage(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get historyEmptyMessage =>
      'Belum ada bill tersimpan.\nMulai scan struk dari tab Scan.';

  @override
  String get historyWindowFree => 'Riwayat Free';

  @override
  String get historyWindowPlus => 'Riwayat Plus';

  @override
  String get historyWindowAnonymous => 'Riwayat terkunci';

  @override
  String get historyWindowAnonymousSubtitle =>
      'Daftar untuk menyimpan dan melihat riwayat bill.';

  @override
  String historyWindowFreeSubtitle(int freeDays, int plusDays) {
    return 'Menampilkan bill dari $freeDays hari terakhir. Plus bisa melihat sampai $plusDays hari terakhir.';
  }

  @override
  String historyWindowSubtitle(int days) {
    return 'Menampilkan bill dari $days hari terakhir.';
  }

  @override
  String get historyUpgradeCta => 'Upgrade ke Plus';

  @override
  String get historyPlusBannerDismiss => 'Tutup';

  @override
  String historyFreePlusBannerLabel(int freeDays) {
    return 'Riwayat $freeDays hari · Insight bulanan';
  }

  @override
  String historyFreePlusBannerSemantics(int freeDays) {
    return 'Riwayat $freeDays hari dan Insight bulanan, fitur Plus. Ketuk untuk detail.';
  }

  @override
  String get historyFreePlusSheetTitle => 'Fitur History Plus';

  @override
  String get historyFreePlusHistoryTitle => 'Riwayat lebih panjang';

  @override
  String historyFreePlusHistoryBody(int freeDays, int plusDays) {
    return 'Free menampilkan $freeDays hari terakhir. Plus menampilkan hingga $plusDays hari.';
  }

  @override
  String get historyFreePlusDismissAction => 'Nanti';

  @override
  String get historyFilterTooltip => 'Urutkan & filter';

  @override
  String get historyFilterTitle => 'Urutkan & filter';

  @override
  String get historyFilterSort => 'Urutan';

  @override
  String get historyFilterStatus => 'Status pembayaran';

  @override
  String get historyFilterCurrency => 'Mata uang';

  @override
  String get historyFilterReset => 'Reset';

  @override
  String get historyFilterEmpty =>
      'Tidak ada bill yang cocok dengan filter ini.';

  @override
  String historyFilterCount(int filteredCount, int totalCount) {
    return '$filteredCount dari $totalCount bill';
  }

  @override
  String get historySortNewest => 'Terbaru';

  @override
  String get historySortOldest => 'Terlama';

  @override
  String get historySortTitle => 'Nama A-Z';

  @override
  String get historySortAmountDesc => 'Nominal tertinggi';

  @override
  String get historySortAmountAsc => 'Nominal terendah';

  @override
  String get historySortNominalDisabled =>
      'Pilih satu mata uang untuk mengurutkan nominal.';

  @override
  String get historyStatusAll => 'Semua';

  @override
  String get historyStatusUnassigned => 'Belum dibagi';

  @override
  String get historyStatusUnpaid => 'Belum dibayar';

  @override
  String get historyStatusPartial => 'Sebagian dibayar';

  @override
  String get historyStatusSettled => 'Lunas';

  @override
  String get applyAction => 'Terapkan';

  @override
  String get monthlyInsightTitle => 'Insight bulanan';

  @override
  String monthlyInsightMonth(String month, int year) {
    return 'Pengeluaran $month $year';
  }

  @override
  String get monthlyInsightLoading => 'Memuat insight bulanan...';

  @override
  String get monthlyInsightError => 'Insight bulanan belum bisa dimuat.';

  @override
  String get monthlyInsightLockedSubtitle =>
      'Lihat total bulanan, tren, piutang outstanding, dan merchant terbesar dengan Plus.';

  @override
  String get monthlyInsightPreviousMonth => 'Bulan sebelumnya';

  @override
  String get monthlyInsightNextMonth => 'Bulan berikutnya';

  @override
  String get monthlyInsightTotal => 'Total';

  @override
  String get monthlyInsightAverage => 'Rata-rata bill';

  @override
  String get monthlyInsightBills => 'Bill';

  @override
  String get monthlyInsightOutstanding => 'Outstanding';

  @override
  String get monthlyInsightTopMerchants => 'Merchant terbesar';

  @override
  String monthlyInsightIncrease(String percent) {
    return 'Naik $percent% dibanding bulan lalu';
  }

  @override
  String monthlyInsightDecrease(String percent) {
    return 'Turun $percent% dibanding bulan lalu';
  }

  @override
  String get monthlyInsightNoChange => 'Tidak berubah dibanding bulan lalu';

  @override
  String get splitSummaryTitle => 'Rincian per Orang';

  @override
  String get splitSummaryNoItems => 'Belum ambil item.';

  @override
  String get splitSummarySubtotal => 'Subtotal';

  @override
  String get splitSummaryTax => 'Pajak (proporsional)';

  @override
  String get splitSummaryService => 'Service (proporsional)';

  @override
  String get splitSummaryShare => 'Bagikan';

  @override
  String get participantShareAgain => 'Bagikan ulang';

  @override
  String get billReviewTitle => 'Review bill';

  @override
  String get billReviewAddItem => 'Tambah item';

  @override
  String get billReviewDeleteItemTitle => 'Hapus item?';

  @override
  String billReviewDeleteItemBody(String name) {
    return 'Item \"$name\" akan dihapus.';
  }

  @override
  String get billReviewMerchantHint => 'Nama merchant';

  @override
  String get billReviewItemNameHint => 'Nama item';

  @override
  String get billReviewUnnamedItem => 'tanpa nama';

  @override
  String get billReviewUnitPriceLabel => 'Harga / unit';

  @override
  String get billReviewTaxLabel => 'Pajak';

  @override
  String get billReviewServiceLabel => 'Service';

  @override
  String get billReviewSaveBill => 'Simpan Bill';

  @override
  String get billReviewCurrencyPlusTitle => 'Currency per bill';

  @override
  String get billReviewCurrencyPlusDetail =>
      'Mengubah currency per bill adalah fitur Plus. Pengguna Free tetap memakai mata uang default dari Pengaturan.';

  @override
  String billReviewAiLowConfidence(String percent) {
    return 'AI kurang yakin ($percent%) — periksa angka.';
  }

  @override
  String billReviewMismatch(String computed, String detected) {
    return 'Total $computed berbeda dari struk ($detected). Periksa lagi.';
  }

  @override
  String get billReviewTitleRequired => 'Judul tidak boleh kosong.';

  @override
  String get billReviewItemsRequired => 'Tambahkan minimal satu item.';

  @override
  String get billReviewInvalidItem =>
      'Periksa nama, harga, dan qty setiap item.';

  @override
  String billReviewSaveBillFailed(String message) {
    return 'Gagal simpan bill: $message';
  }

  @override
  String billReviewSaveItemsFailed(String message) {
    return 'Bill tersimpan tapi item gagal: $message';
  }

  @override
  String get billSplitTitle => 'Split bill';

  @override
  String get billSplitBackTooltip => 'Kembali';

  @override
  String get billSplitDone => 'Selesai';

  @override
  String get billSplitAddPersonTitle => 'Tambah orang';

  @override
  String get billSplitNameHint => 'Nama';

  @override
  String get billSplitAdd => 'Tambah';

  @override
  String get billSplitEmptyItems => 'Bill ini belum punya item.';

  @override
  String get billSplitTotalBill => 'Total tagihan';

  @override
  String get billSplitAllAssigned => 'Semua item sudah dibagi';

  @override
  String billSplitUnassigned(String amount) {
    return 'Belum dibagi: $amount';
  }

  @override
  String get billSplitViewSummary => 'Lihat Rincian';

  @override
  String get billSplitStateNotReady => 'State belum siap.';

  @override
  String get billSplitNameRequired => 'Nama tidak boleh kosong.';

  @override
  String billSplitAddPersonFailed(String message) {
    return 'Gagal tambah orang: $message';
  }

  @override
  String get billSplitSelectPersonFirst => 'Pilih dulu orang di bawah.';

  @override
  String billSplitSaveAssignmentFailed(String message) {
    return 'Gagal simpan assignment: $message';
  }

  @override
  String get billSplitRemoveParticipantTitle => 'Hapus partisipan?';

  @override
  String billSplitRemoveParticipantMessage(String name) {
    return 'Semua item yang ditugaskan ke $name juga akan dihapus.';
  }

  @override
  String get billSplitRemoveParticipantConfirm => 'Hapus';

  @override
  String billSplitRemoveParticipantFailed(String message) {
    return 'Gagal hapus partisipan: $message';
  }

  @override
  String get billSplitParticipantBarHint =>
      'Tekan lama peserta untuk menghapus';

  @override
  String get participantPhoneLabel => 'Nomor (opsional)';

  @override
  String get participantSuggestionTitle => 'Sering dipakai';

  @override
  String get participantImportFromContacts => 'Import dari kontak';

  @override
  String get participantImportFailed =>
      'Gagal membuka kontak. Coba lagi atau tambah manual.';

  @override
  String get participantImportNoPhone => '(kontak ini tidak punya nomor)';

  @override
  String get billDetailParticipantPhoneLabel => 'No HP';

  @override
  String get billDetailTitle => 'Detail Tagihan';

  @override
  String get billDetailHomeTooltip => 'Beranda';

  @override
  String get billDetailScanAnotherTooltip => 'Scan struk lain';

  @override
  String get billDetailLoading => 'Memuat detail…';

  @override
  String get billDetailParticipants => 'Partisipan';

  @override
  String get billDetailTotalBill => 'Total tagihan';

  @override
  String billDetailPaidProgress(int paidCount, int totalCount) {
    return '$paidCount/$totalCount partisipan sudah bayar';
  }

  @override
  String get billDetailSettled => 'Lunas';

  @override
  String get billDetailUnsettled => 'Belum lunas';

  @override
  String get billDetailEmptyParticipants =>
      'Belum ada partisipan untuk tagihan ini.';

  @override
  String get billDetailGoToSplit => 'Pergi ke Pembagian';

  @override
  String get billDetailParticipantNotFound => 'Partisipan tidak ditemukan.';

  @override
  String billDetailSaveStatusFailed(String message) {
    return 'Gagal simpan status: $message';
  }

  @override
  String get billDetailStateNotReady => 'Data belum siap, coba lagi sebentar.';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportPdfPlusLocked => 'Export PDF (Plus)';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvPlusLocked => 'Export CSV (Plus)';

  @override
  String get exportPlusDetail =>
      'Export PDF dan CSV adalah fitur Plus. Pengguna Free tetap bisa melihat dan membagikan rincian peserta versi basic.';

  @override
  String get exportFailed => 'Export belum bisa dibuat. Coba lagi.';

  @override
  String exportPdfSubject(String title) {
    return 'Export $title';
  }

  @override
  String exportPdfShareText(String title) {
    return 'Export PDF untuk $title';
  }

  @override
  String exportCsvSubject(String title) {
    return 'Export $title';
  }

  @override
  String exportCsvShareText(String title) {
    return 'Export CSV untuk $title';
  }

  @override
  String get splitSummaryCopy => 'Salin';

  @override
  String get splitSummaryCopied => 'Disalin ke clipboard';

  @override
  String get splitShareFailed => 'Tidak bisa membagikan';

  @override
  String get settlementTemplateBasic => 'Basic';

  @override
  String get settlementTemplateCompact => 'Pesan ringkas';

  @override
  String get settlementTemplateDetailed => 'Pesan rinci';

  @override
  String get settlementTemplateAll => 'Rekap semua peserta';

  @override
  String get settlementTemplatePlusLocked =>
      'Template WhatsApp yang lebih rapi tersedia dengan Plus.';

  @override
  String get settlementMessageBillPrefix => 'Rincian';

  @override
  String get settlementMessageRecapPrefix => 'Rekap BagiStruk -';

  @override
  String get settlementMessageFor => 'Untuk';

  @override
  String settlementMessageGreeting(String name) {
    return 'Halo $name, bagianmu:';
  }

  @override
  String get settlementMessageTransferNote =>
      'Mohon transfer jika sudah sesuai. Terima kasih.';

  @override
  String get settlementMessageItems => 'Item kamu';

  @override
  String get settlementMessageUnnamedItem => '(tanpa nama)';

  @override
  String settlementMessageSharedWith(int count) {
    return 'dibagi $count';
  }

  @override
  String get settlementMessageTotal => 'Total';

  @override
  String get settlementMessageStatus => 'Status';

  @override
  String get settlementMessagePaid => 'lunas';

  @override
  String get settlementMessageUnpaid => 'belum lunas';

  @override
  String get settlementMessageGrandTotal => 'Total bill';

  @override
  String get settlementMessageOutstanding => 'Belum lunas';

  @override
  String settlementMessageWhatsappLink(String url) {
    return 'Chat via WhatsApp: $url';
  }

  @override
  String settlementPromoFooter(String url) {
    return 'Dibuat dengan BagiStruk. Coba aplikasinya di Google Play: $url';
  }

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get aboutSettingsTile => 'Tentang Aplikasi';

  @override
  String get aboutVersionLabel => 'Versi';

  @override
  String get aboutSectionApp => 'Aplikasi';

  @override
  String get aboutSectionAuthor => 'Pembuat';

  @override
  String get aboutSectionSupport => 'Dukung';

  @override
  String get aboutAuthorName => 'Alam Aby Bashit';

  @override
  String get aboutWebsite => 'Situs Web';

  @override
  String get aboutGithub => 'GitHub';

  @override
  String get aboutLinkedin => 'LinkedIn';

  @override
  String get aboutBuyMeACoffee => 'Buy Me a Coffee';

  @override
  String get aboutSaweria => 'Saweria';

  @override
  String get aboutPatreon => 'Patreon';

  @override
  String get aboutPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get privacyPolicyTitle => 'Kebijakan Privasi';

  @override
  String get aboutTermsOfService => 'Syarat dan Ketentuan';

  @override
  String get termsOfServiceTitle => 'Syarat dan Ketentuan';

  @override
  String get linkUnavailable => 'Tautan belum tersedia';

  @override
  String get reviewSuspectThousandsBug =>
      'Harga tampak memakai pemisah ribuan sebagai desimal. Mohon periksa tiap angka sebelum menyimpan.';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authEmailRequired => 'Email wajib diisi';

  @override
  String get authInvalidEmailFormat => 'Format email tidak valid';

  @override
  String get authPasswordRequired => 'Password wajib diisi';

  @override
  String get authPasswordMinLength => 'Password minimal 6 karakter';

  @override
  String get authShowPassword => 'Tampilkan password';

  @override
  String get authHidePassword => 'Sembunyikan password';

  @override
  String get authSignInWithGoogle => 'Masuk dengan Google';

  @override
  String get authGoogleSigningIn => 'Sedang masuk...';

  @override
  String get failureRetry => 'Coba Lagi';

  @override
  String failurePrefixNetwork(String message) {
    return 'Jaringan: $message';
  }

  @override
  String failurePrefixServer(String code, String message) {
    return 'Server ($code): $message';
  }

  @override
  String failurePrefixServerNoCode(String message) {
    return 'Server: $message';
  }

  @override
  String failurePrefixParsing(String message) {
    return 'Respons tidak terbaca: $message';
  }

  @override
  String failurePrefixAuth(String message) {
    return 'Autentikasi: $message';
  }

  @override
  String failurePrefixUnexpected(String error) {
    return 'Tidak terduga: $error';
  }

  @override
  String get historyFilterActiveBadge => 'Aktif';

  @override
  String get commonPlus => 'Plus';

  @override
  String get billReviewQtyLabel => 'Qty';

  @override
  String get billReviewSubtotalLabel => 'Subtotal';

  @override
  String get billReviewTotalLabel => 'Total';

  @override
  String get exportLabelItems => 'Item';

  @override
  String get exportLabelParticipants => 'Peserta';

  @override
  String get exportLabelCurrency => 'Mata Uang';

  @override
  String get exportLabelName => 'Nama';

  @override
  String get exportLabelQty => 'Qty';

  @override
  String get exportLabelPrice => 'Harga';

  @override
  String get exportLabelSubtotal => 'Subtotal';

  @override
  String get exportLabelTax => 'Pajak';

  @override
  String get exportLabelService => 'Service';

  @override
  String get exportLabelTotal => 'Total';

  @override
  String get exportLabelStatus => 'Status';

  @override
  String get exportLabelAssignedParticipants => 'Partisipan yang ditugaskan';

  @override
  String get exportLabelBillTitle => 'Judul';

  @override
  String get exportLabelReceiptDate => 'Tanggal struk';

  @override
  String get exportLabelCreatedAt => 'Dibuat pada';

  @override
  String get exportLabelTotalAmount => 'Total tagihan';

  @override
  String get exportLabelSettledYes => 'ya';

  @override
  String get exportLabelSettledNo => 'tidak';

  @override
  String get exportLabelPaidStatus => 'lunas';

  @override
  String get exportLabelUnpaidStatus => 'belum lunas';

  @override
  String exportCsvTopTitle(String title) {
    return 'Detail Bill: $title';
  }

  @override
  String exportPdfSubjectFallback(String title) {
    return 'Export PDF $title';
  }

  @override
  String exportPdfShareTextFallback(String title) {
    return 'Export PDF untuk $title';
  }

  @override
  String exportCsvSubjectFallback(String title) {
    return 'Export CSV $title';
  }

  @override
  String exportCsvShareTextFallback(String title) {
    return 'Export CSV untuk $title';
  }

  @override
  String settlementMessageCompactTitle(String title) {
    return 'BagiStruk - $title';
  }

  @override
  String settlementMessageDetailedTitle(String title) {
    return 'BagiStruk - $title';
  }

  @override
  String settlementMessageBasicTitle(String title) {
    return '$title';
  }

  @override
  String get billDetailParticipantPhoneHint => 'Telepon (opsional)';

  @override
  String get appInitErrorTitle => 'BagiStruk gagal dimulai';

  @override
  String get appInitErrorRetryHint =>
      'Cek koneksi internet, lalu buka ulang aplikasi. Kalau masih bermasalah, periksa file .env dan setting Supabase.';

  @override
  String appInitErrorEnvLoad(String message) {
    return 'Gagal muat konfigurasi (.env): $message';
  }

  @override
  String appInitErrorSupabase(String message) {
    return 'Gagal inisialisasi Supabase: $message';
  }

  @override
  String get paywallTitle => 'Simpan riwayat & lacak piutang';

  @override
  String get paywallSubtitle =>
      'Daftar atau masuk untuk menyimpan riwayat dan melacak piutangmu.';

  @override
  String get paywallRegister => 'Daftar';

  @override
  String get paywallLogin => 'Masuk';

  @override
  String get scanEmptyHint =>
      'Ambil foto struk belanja atau makan bareng untuk mulai berbagi adil!';

  @override
  String get adPrivacyChoicesTitle => 'Pilihan privasi iklan';

  @override
  String get adPrivacyChoicesSubtitle =>
      'Tinjau atau ubah persetujuan iklan bila diwajibkan.';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingFinish => 'Mulai scan struk';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingPreferencesTitle => 'Atur preferensi';

  @override
  String get onboardingPreferencesBody =>
      'Pilih bahasa, mata uang default, dan tema untuk aplikasi.';

  @override
  String get onboardingPreferencesLanguage => 'Bahasa aplikasi';

  @override
  String get onboardingPreferencesCurrency => 'Mata uang default';

  @override
  String get onboardingPreferencesTheme => 'Tema aplikasi';

  @override
  String get onboardingPreferencesChangeLater =>
      'Semuanya bisa diubah nanti di Pengaturan.';

  @override
  String get onboardingPreferencesSaveError =>
      'Preferensi gagal disimpan. Coba lagi.';

  @override
  String get onboardingTitle1 => 'Scan struk';

  @override
  String get onboardingBody1 =>
      'Foto atau pilih struk. BagiStruk membaca item dan total secara otomatis.';

  @override
  String get onboardingTitle2 => 'Atur bagian';

  @override
  String get onboardingBody2 =>
      'Atur bagian tiap orang. Tambah teman, lalu pilih item yang mereka pesan.';

  @override
  String get onboardingTitle3 => 'Tagih sampai lunas';

  @override
  String get onboardingBody3 =>
      'Bagikan rincian ke WhatsApp dan tandai pembayaran saat sudah masuk.';

  @override
  String get onboardingReplayFinish => 'Selesai';

  @override
  String get onboardingSettingsTile => 'Lihat panduan aplikasi';

  @override
  String get onboardingSaveError => 'Gagal menyimpan. Coba lagi.';

  @override
  String get ocrAiDisclosure =>
      'Foto struk diproses oleh layanan AI pihak ketiga untuk ekstraksi item.';
}
