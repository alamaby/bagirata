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
}
