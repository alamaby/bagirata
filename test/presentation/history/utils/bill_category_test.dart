import 'package:bagistruk/l10n/generated/app_l10n_en.dart';
import 'package:bagistruk/l10n/generated/app_l10n_id.dart';
import 'package:bagistruk/presentation/history/utils/bill_category.dart';
import 'package:bagistruk/presentation/history/utils/bill_category_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillCategory.coerce', () {
    test('accepts all presets case-insensitively', () {
      for (final preset in BillCategory.presets) {
        expect(BillCategory.coerce(preset), preset);
        expect(BillCategory.coerce(preset.toUpperCase()), preset);
        expect(BillCategory.coerce('  $preset  '), preset);
      }
    });

    test('unknown, empty, and null input become lain', () {
      expect(BillCategory.coerce('FOOD'), 'lain');
      expect(BillCategory.coerce(''), 'lain');
      expect(BillCategory.coerce('   '), isNot('   '));
      expect(BillCategory.coerce(null), 'lain');
      expect(BillCategory.coerce('makanan'), 'lain');
    });
  });

  group('BillCategory.normalizeTags', () {
    test('trims, drops empties, dedupes case-insensitively, caps at 5', () {
      expect(
        BillCategory.normalizeTags([
          '  Kopi  ',
          '',
          '   ',
          'KOPI',
          'kantor',
          'a',
          'b',
          'c',
          'd',
        ]),
        ['Kopi', 'kantor', 'a', 'b', 'c'],
      );
    });

    test('null and empty become empty list', () {
      expect(BillCategory.normalizeTags(null), isEmpty);
      expect(BillCategory.normalizeTags([]), isEmpty);
      expect(BillCategory.normalizeTags(['', '  ']), isEmpty);
    });

    test('parseTagsField splits on commas', () {
      expect(
        BillCategory.parseTagsField('kopi, kantor ,kopi'),
        ['kopi', 'kantor'],
      );
      expect(BillCategory.parseTagsField(null), isEmpty);
      expect(BillCategory.parseTagsField('   '), isEmpty);
    });
  });

  group('categoryLabel', () {
    test('maps every preset in both locales, falls back for unknown', () {
      final en = AppL10nEn();
      final id = AppL10nId();
      expect(categoryLabel('makan', en), 'Food');
      expect(categoryLabel('makan', id), 'Makan');
      expect(categoryLabel('transport', en), 'Transport');
      expect(categoryLabel('groceries', en), 'Groceries');
      expect(categoryLabel('belanja', en), 'Shopping');
      expect(categoryLabel('belanja', id), 'Belanja');
      expect(categoryLabel('lain', en), 'Other');
      expect(categoryLabel('lain', id), 'Lainnya');
      expect(categoryLabel('FOOD', en), 'Other');
    });
  });
}
