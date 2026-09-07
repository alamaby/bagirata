class MonthlySpendingInsight {
  const MonthlySpendingInsight({
    required this.planCode,
    required this.isPlus,
    required this.monthStart,
    required this.totalAmount,
    required this.billCount,
    required this.averageBillAmount,
    required this.previousMonthTotal,
    required this.monthOverMonthPercent,
    required this.outstandingAmount,
    required this.topMerchants,
    required this.monthlyTrend,
    required this.byCategory,
  });

  final String planCode;
  final bool isPlus;
  final DateTime monthStart;
  final double totalAmount;
  final int billCount;
  final double averageBillAmount;
  final double previousMonthTotal;
  final double? monthOverMonthPercent;
  final double outstandingAmount;
  final List<MerchantSpendingInsight> topMerchants;
  final List<MonthlySpendingTrendPoint> monthlyTrend;
  final List<CategorySpendingInsight> byCategory;

  factory MonthlySpendingInsight.fromJson(Map<String, dynamic> json) {
    return MonthlySpendingInsight(
      planCode: json['plan_code']?.toString() ?? 'free',
      isPlus: _readBool(json['is_plus']),
      monthStart:
          DateTime.tryParse(json['month_start']?.toString() ?? '') ??
          DateTime(DateTime.now().year, DateTime.now().month),
      totalAmount: _readDouble(json['total_amount']),
      billCount: _readInt(json['bill_count']),
      averageBillAmount: _readDouble(json['average_bill_amount']),
      previousMonthTotal: _readDouble(json['previous_month_total']),
      monthOverMonthPercent: json['month_over_month_percent'] == null
          ? null
          : _readDouble(json['month_over_month_percent']),
      outstandingAmount: _readDouble(json['outstanding_amount']),
      topMerchants: _readList(
        json['top_merchants'],
        MerchantSpendingInsight.fromJson,
      ),
      monthlyTrend: _readList(
        json['monthly_trend'],
        MonthlySpendingTrendPoint.fromJson,
      ),
      byCategory: _readList(
        json['by_category'],
        CategorySpendingInsight.fromJson,
      ),
    );
  }

  static List<T> _readList<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class MerchantSpendingInsight {
  const MerchantSpendingInsight({
    required this.title,
    required this.totalAmount,
    required this.billCount,
  });

  final String title;
  final double totalAmount;
  final int billCount;

  factory MerchantSpendingInsight.fromJson(Map<String, dynamic> json) {
    return MerchantSpendingInsight(
      title: json['title']?.toString() ?? '-',
      totalAmount: MonthlySpendingInsight._readDouble(json['total_amount']),
      billCount: MonthlySpendingInsight._readInt(json['bill_count']),
    );
  }
}

class CategorySpendingInsight {
  const CategorySpendingInsight({
    required this.category,
    required this.totalAmount,
    required this.billCount,
  });

  final String category;
  final double totalAmount;
  final int billCount;

  factory CategorySpendingInsight.fromJson(Map<String, dynamic> json) {
    return CategorySpendingInsight(
      category: json['category']?.toString() ?? 'lain',
      totalAmount: MonthlySpendingInsight._readDouble(json['total_amount']),
      billCount: MonthlySpendingInsight._readInt(json['bill_count']),
    );
  }
}

class MonthlySpendingTrendPoint {
  const MonthlySpendingTrendPoint({
    required this.monthStart,
    required this.totalAmount,
    required this.billCount,
  });

  final DateTime monthStart;
  final double totalAmount;
  final int billCount;

  factory MonthlySpendingTrendPoint.fromJson(Map<String, dynamic> json) {
    return MonthlySpendingTrendPoint(
      monthStart:
          DateTime.tryParse(json['month_start']?.toString() ?? '') ??
          DateTime(DateTime.now().year, DateTime.now().month),
      totalAmount: MonthlySpendingInsight._readDouble(json['total_amount']),
      billCount: MonthlySpendingInsight._readInt(json['bill_count']),
    );
  }
}
