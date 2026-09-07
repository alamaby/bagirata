import '../../../l10n/generated/app_l10n.dart';

/// Localized display names for [BillCategory] presets. Kept next to the
/// pure [BillCategory] constants (which stay Flutter-free) so review,
/// history rows, and filter UI share one mapping.
String categoryLabel(String code, AppL10n l10n) => switch (code) {
  'makan' => l10n.categoryMakan,
  'transport' => l10n.categoryTransport,
  'groceries' => l10n.categoryGroceries,
  'belanja' => l10n.categoryBelanja,
  _ => l10n.categoryLain,
};
