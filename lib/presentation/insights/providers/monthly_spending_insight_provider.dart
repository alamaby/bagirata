import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/monthly_spending_insight.dart';
import '../../auth/providers/auth_providers.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';

/// Query identity for the monthly insight family. [month] is used as-is but
/// normalized to its first day before hitting the repository; [currencyCode]
/// is the ISO code the insight is scoped to.
typedef MonthlyInsightQuery = ({DateTime month, String currencyCode});

final monthlySpendingInsightProvider = FutureProvider.family<
  MonthlySpendingInsight?,
  MonthlyInsightQuery
>((ref, query) async {
  ref.watch(authStateProvider);
  final creditStatus = await ref.watch(ocrCreditStatusProvider.future);
  if (creditStatus?.isPlus != true) return null;
  final monthStart = DateTime(query.month.year, query.month.month);

  final result = await ref
      .read(profileRepositoryProvider)
      .getMonthlySpendingInsight(
        month: monthStart,
        currencyCode: query.currencyCode,
      );
  return switch (result) {
    Success(:final data) => data,
    ResultFailure(:final failure) => throw Exception(failure.toString()),
  };
});
