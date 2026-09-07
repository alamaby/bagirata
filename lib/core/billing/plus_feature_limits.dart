class PlusFeatureLimits {
  const PlusFeatureLimits._();

  static const anonymousHistoryDays = 0;
  static const freeHistoryDays = 30;
  static const plusHistoryDays = 365;

  static int historyDays({required String? planCode}) => switch (planCode) {
    'plus' => plusHistoryDays,
    'free' => freeHistoryDays,
    _ => anonymousHistoryDays,
  };

  static DateTime? historyCutoff({required String? planCode, DateTime? now}) {
    final days = historyDays(planCode: planCode);
    if (days <= 0) return null;
    final base = (now ?? DateTime.now()).toUtc();
    return base.subtract(Duration(days: days));
  }

  /// Soft-deleted bill retention written by `soft_delete_bill`
  /// (Free 30 / Plus 90 days). Downgrade-safe by construction: the expiry is
  /// computed once at delete time and never shortened afterwards.
  static const trashRetentionDaysFree = 30;
  static const trashRetentionDaysPlus = 90;

  static int trashRetentionDays({required bool isPlus}) =>
      isPlus ? trashRetentionDaysPlus : trashRetentionDaysFree;

  /// Whole days left before [expiresAt]; clamps past dates to 0.
  static int trashDaysRemaining(DateTime expiresAt, {DateTime? now}) {
    final base = (now ?? DateTime.now()).toUtc();
    final diff = expiresAt.toUtc().difference(base).inHours / 24;
    if (diff <= 0) return 0;
    return diff.ceil();
  }
}
