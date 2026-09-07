import 'package:bagistruk/core/billing/plus_feature_limits.dart';
import 'package:bagistruk/domain/entities/monthly_spending_insight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonthlySpendingInsight.fromJson by_category', () {
    Map<String, dynamic> row({Object? byCategory}) => {
      'plan_code': 'plus',
      'is_plus': true,
      'month_start': '2026-09-01',
      'total_amount': 300,
      'bill_count': 3,
      'average_bill_amount': 100,
      'previous_month_total': 200,
      'month_over_month_percent': 50.0,
      'outstanding_amount': 0,
      'top_merchants': [],
      'monthly_trend': [],
      if (byCategory != null) 'by_category': byCategory,
    };

    test('parses breakdown rows', () {
      final insight = MonthlySpendingInsight.fromJson(row(byCategory: [
        {'category': 'makan', 'total_amount': 200, 'bill_count': 2},
        {'category': 'transport', 'total_amount': 100, 'bill_count': 1},
      ]));
      expect(insight.byCategory, hasLength(2));
      expect(insight.byCategory.first.category, 'makan');
      expect(insight.byCategory.first.totalAmount, 200);
      expect(insight.byCategory.first.billCount, 2);
    });

    test('missing key (old server) reads as empty, not crash', () {
      final insight = MonthlySpendingInsight.fromJson(row());
      expect(insight.byCategory, isEmpty);
      expect(insight.totalAmount, 300);
    });

    test('empty month stays zero-safe', () {
      final insight = MonthlySpendingInsight.fromJson(
        row(byCategory: const []),
      );
      expect(insight.billCount, 3);
      expect(insight.averageBillAmount, 100);
      expect(insight.monthOverMonthPercent, 50.0);
    });
  });

  group('PlusFeatureLimits trash retention', () {
    test('retention is 30 free / 90 plus', () {
      expect(
        PlusFeatureLimits.trashRetentionDays(isPlus: false),
        PlusFeatureLimits.trashRetentionDaysFree,
      );
      expect(PlusFeatureLimits.trashRetentionDaysFree, 30);
      expect(
        PlusFeatureLimits.trashRetentionDays(isPlus: true),
        PlusFeatureLimits.trashRetentionDaysPlus,
      );
      expect(PlusFeatureLimits.trashRetentionDaysPlus, 90);
    });

    test('days remaining clamps past dates to zero', () {
      final now = DateTime.utc(2026, 9, 7, 12);
      expect(
        PlusFeatureLimits.trashDaysRemaining(
          DateTime.utc(2026, 9, 10, 12),
          now: now,
        ),
        3,
      );
      expect(
        PlusFeatureLimits.trashDaysRemaining(
          DateTime.utc(2026, 9, 7, 13),
          now: now,
        ),
        1,
      );
      expect(
        PlusFeatureLimits.trashDaysRemaining(
          DateTime.utc(2026, 9, 1),
          now: now,
        ),
        0,
      );
    });
  });
}
