import 'package:flutter/widgets.dart';

class AppConstants {
  const AppConstants._();

  /// Design baseline: iPhone 12 logical resolution. ScreenUtil scales widgets
  /// from this baseline so the same code renders correctly on the S20 FE
  /// (412×915) and Infinix XPAD (tablet) without per-device branching.
  static const Size designSize = Size(390, 844);

  /// Edge Function name registered in Supabase.
  static const String ocrEdgeFunctionName = 'process-receipt';

  /// Long-edge target for OCR uploads. Anything larger only inflates token
  /// cost without improving extraction accuracy in our spike tests.
  static const int ocrMaxImageEdgePx = 1600;

  /// Default share weight when a participant claims one item alone.
  static const double defaultShareWeight = 1.0;

  /// Confidence di bawah ini → tampilkan chip peringatan ke user supaya
  /// double-check angka secara manual.
  static const double ocrLowConfidenceThreshold = 0.8;

  /// Selisih maksimum antara total hitungan client vs `detected_total` LLM
  /// sebelum menampilkan banner mismatch. 1.0 menyerap rounding kecil
  /// (LLM kadang bulatkan ke ratusan).
  static const double billTotalMismatchTolerance = 1.0;
}
