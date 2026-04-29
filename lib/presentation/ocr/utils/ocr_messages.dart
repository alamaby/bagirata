import '../../../core/error/failure.dart';

/// Maps OCR pipeline [Failure]s to short, friendly Indonesian messages.
/// The raw failure payload (provider JSON, stack traces, attempts log) is
/// useful for debugging but unreadable in the UI — we surface a clean message
/// and keep the technical details for logs only.
class OcrMessage {
  const OcrMessage({required this.title, required this.body, this.canRetry = true});

  final String title;
  final String body;
  final bool canRetry;
}

OcrMessage friendlyOcrMessage(Failure failure) {
  return switch (failure) {
    NetworkFailure() => const OcrMessage(
        title: 'Tidak ada koneksi',
        body:
            'Periksa koneksi internetmu, lalu coba scan ulang.',
      ),
    AuthFailure() => const OcrMessage(
        title: 'Sesi berakhir',
        body: 'Sesi kamu sudah habis. Silakan masuk lagi untuk melanjutkan.',
        canRetry: false,
      ),
    ParsingFailure() => const OcrMessage(
        title: 'Respons tidak terbaca',
        body:
            'Hasil scan dari server tidak dapat diproses. Coba foto ulang dengan pencahayaan lebih baik.',
      ),
    ServerFailure(:final code, :final message) => _serverMessage(code, message),
    UnknownFailure() => const OcrMessage(
        title: 'Terjadi kesalahan',
        body: 'Sesuatu tidak berjalan semestinya. Coba lagi sebentar.',
      ),
  };
}

OcrMessage _serverMessage(int? code, String raw) {
  final lower = raw.toLowerCase();

  if (lower.contains('all_providers_failed') ||
      lower.contains('unavailable') ||
      lower.contains('high demand') ||
      code == 503) {
    return const OcrMessage(
      title: 'Layanan AI sedang sibuk',
      body:
          'Server AI sedang menerima banyak permintaan. Tunggu beberapa saat, lalu coba scan lagi.',
    );
  }
  if (code == 429 || lower.contains('rate limit') || lower.contains('quota')) {
    return const OcrMessage(
      title: 'Terlalu banyak permintaan',
      body: 'Kamu mencapai batas scan untuk saat ini. Coba lagi dalam beberapa menit.',
    );
  }
  if (code == 401 || code == 403) {
    return const OcrMessage(
      title: 'Akses ditolak',
      body: 'Server menolak permintaan. Coba keluar dan masuk lagi.',
      canRetry: false,
    );
  }
  if (code == 408 || lower.contains('timeout')) {
    return const OcrMessage(
      title: 'Permintaan kelamaan',
      body: 'Server butuh waktu terlalu lama merespons. Coba lagi.',
    );
  }
  if (code != null && code >= 500) {
    return const OcrMessage(
      title: 'Server bermasalah',
      body: 'Server sedang tidak stabil. Tunggu sebentar lalu coba lagi.',
    );
  }
  return const OcrMessage(
    title: 'Scan gagal',
    body: 'Tidak bisa memproses struk ini. Coba foto ulang atau gunakan gambar lain.',
  );
}
