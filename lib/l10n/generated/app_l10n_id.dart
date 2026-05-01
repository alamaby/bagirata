// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

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
  String get retry => 'Coba Lagi';

  @override
  String get accountSection => 'Akun';

  @override
  String get preferencesSection => 'Preferensi';

  @override
  String get displayNameFallback => 'Pengguna BagiStruk';

  @override
  String get guestAccount => 'Akun Tamu';

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
  String get currencyLabel => 'Mata Uang Default';

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
  String get errorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get loading => 'Memuat...';

  @override
  String get noSessionMessage =>
      'Daftar atau masuk untuk mengakses pengaturan.';

  @override
  String get registerOrLogin => 'Daftar / Masuk';
}
