/// Bill category presets shared by review picker, history filter, and
/// insight breakdown. Pure Dart (no Flutter) so it stays unit-testable.
///
/// Server CHECK-enforced (`bills_category_check`); unknown codes never
/// persist. `'lain'` is the default for old bills and uncategorized input.
class BillCategory {
  const BillCategory._();

  static const String makan = 'makan';
  static const String transport = 'transport';
  static const String groceries = 'groceries';
  static const String belanja = 'belanja';
  static const String lain = 'lain';

  static const List<String> presets = [
    makan,
    transport,
    groceries,
    belanja,
    lain,
  ];

  static bool isPreset(String? code) => presets.contains(code);

  /// Coerce arbitrary input to a persistable preset. Unknown/empty values
  /// become `'lain'` — never crash, never persist garbage.
  static String coerce(String? code) {
    final normalized = code?.trim().toLowerCase() ?? '';
    return isPreset(normalized) ? normalized : lain;
  }

  /// Normalize a raw tag list for persistence: trim, drop empties, dedupe
  /// case-insensitively (keep first casing), cap at [maxTags].
  /// Custom tags may contain free-form PII — callers must never log them.
  static List<String> normalizeTags(List<String>? tags, {int maxTags = 5}) {
    if (tags == null || tags.isEmpty) return const [];
    final seen = <String>{};
    final out = <String>[];
    for (final raw in tags) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      out.add(trimmed);
      if (out.length >= maxTags) break;
    }
    return out;
  }

  /// Split a comma-separated tag field into a normalized list.
  static List<String> parseTagsField(String? raw, {int maxTags = 5}) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return normalizeTags(raw.split(','), maxTags: maxTags);
  }
}
