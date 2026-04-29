import '../../../core/error/failure.dart';

/// Maps repository [Failure] variants to user-facing Indonesian messages used
/// in SnackBars on the auth screens. Keep wording short and friendly.
String friendlyAuthMessage(Failure failure) {
  return switch (failure) {
    AuthFailure(:final message) => _humanizeAuth(message),
    NetworkFailure() =>
      'Tidak ada koneksi internet. Coba lagi setelah jaringan stabil.',
    ServerFailure(:final message) =>
      'Server bermasalah: $message. Coba lagi sebentar lagi.',
    ParsingFailure() =>
      'Respons server tidak terbaca. Coba lagi.',
    UnknownFailure() =>
      'Terjadi kesalahan tak terduga. Coba lagi.',
  };
}

String _humanizeAuth(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('invalid login') ||
      lower.contains('invalid credentials')) {
    return 'Email atau password salah.';
  }
  if (lower.contains('already registered') ||
      lower.contains('user already')) {
    return 'Email sudah terdaftar. Coba login.';
  }
  if (lower.contains('weak password') || lower.contains('password should')) {
    return 'Password terlalu lemah. Minimal 6 karakter.';
  }
  if (lower.contains('email not confirmed')) {
    return 'Email belum dikonfirmasi. Cek kotak masuk.';
  }
  if (lower.contains('coming soon')) {
    return 'Fitur ini akan segera hadir.';
  }
  return raw.isEmpty ? 'Autentikasi gagal. Coba lagi.' : raw;
}
