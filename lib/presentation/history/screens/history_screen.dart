import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/billing/plus_feature_limits.dart';
import '../../../core/format/app_format.dart';
import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/bill_payment_status.dart';
import '../../../domain/entities/ocr_result.dart';
import '../../../domain/entities/history_summary.dart';
import '../../../domain/entities/monthly_spending_insight.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../../core/ads/ad_config.dart';
import '../../ads/widgets/banner_ad_widget.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';
import '../../insights/providers/monthly_spending_insight_provider.dart';
import '../../settings/providers/preferences_providers.dart';
import '../../shared/widgets/plus_info_icon.dart';
import '../providers/history_filter_notifier.dart';
import '../providers/history_list_notifier.dart';
import '../providers/history_plus_banner_notifier.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  /// Currently selected Monthly Insight month (first day of the month).
  DateTime _selectedInsightMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  /// Explicitly chosen insight currency; `null` falls back to the default
  /// profile currency or the first available currency.
  String? _selectedInsightCurrency;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Resolves the effective insight currency. Keeps the user's choice while it
  /// remains available, otherwise prefers the default profile currency and
  /// finally the first available currency.
  String _effectiveInsightCurrency(
    List<String> currencies,
    String defaultCurrency,
  ) {
    if (currencies.isEmpty) return defaultCurrency;
    final selected = _selectedInsightCurrency;
    if (selected != null && currencies.contains(selected)) return selected;
    if (currencies.contains(defaultCurrency)) return defaultCurrency;
    return currencies.first;
  }

  bool _isFutureMonth(DateTime month) {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return month.year > now.year ||
        (month.year == now.year && month.month > now.month);
  }

  /// Next is only reachable from a strictly earlier month (never the current
  /// or a future month).
  bool _canGoNextMonth(DateTime month) {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return month.year < now.year ||
        (month.year == now.year && month.month < now.month);
  }

  /// Whether [month] overlaps the Plus/Free history visibility window.
  bool _canReachMonth(DateTime month, {required String? planCode}) {
    final cutoff = PlusFeatureLimits.historyCutoff(planCode: planCode);
    if (cutoff == null) return false;
    final lastDayUtc = DateTime.utc(month.year, month.month + 1, 0);
    final cutoffUtc = DateTime.utc(cutoff.year, cutoff.month, cutoff.day);
    return lastDayUtc.isAfter(cutoffUtc);
  }

  void _previousInsightMonth({required String? planCode}) {
    final prev = DateTime(
      _selectedInsightMonth.year,
      _selectedInsightMonth.month - 1,
    );
    if (!_canReachMonth(prev, planCode: planCode)) return;
    setState(() => _selectedInsightMonth = prev);
  }

  void _nextInsightMonth() {
    final next = DateTime(
      _selectedInsightMonth.year,
      _selectedInsightMonth.month + 1,
    );
    if (_isFutureMonth(next)) return;
    setState(() => _selectedInsightMonth = next);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter <= 400) {
      ref.read(historyListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final HistoryListState historyState = ref.watch(historyListProvider);
    final filter = ref.watch(historyFilterProvider);
    final creditStatusAsync = ref.watch(ocrCreditStatusProvider);
    final creditStatus = switch (creditStatusAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final defaultCurrency = ref.watch(currencyPrefProvider);
    final insightCurrency = CurrencyFormatter.of(defaultCurrency);
    final planCode = creditStatus?.planCode;
    final isPlus = creditStatus?.isPlus ?? false;
    final historyDays = PlusFeatureLimits.historyDays(planCode: planCode);
    final hasHistoryAccess = historyDays > 0;
    final bannerState = ref.watch(historyPlusBannerProvider);
    final isBannerDismissed =
        bannerState is AsyncData<bool> && bannerState.value;
    final bannerReady = bannerState is AsyncData<bool>;
    final items = historyState.items;
    final summary = historyState.summary;
    final currencies = summary?.availableCurrencies ?? <String>[];
    final hasSummary = summary != null && summary.totalBillCount > 0;
    final hasItems = items.isNotEmpty;
    final selectedCurrency = _effectiveInsightCurrency(
      currencies,
      defaultCurrency,
    );
    final monthlyInsight = ref.watch(
      monthlySpendingInsightProvider(
        (month: _selectedInsightMonth, currencyCode: selectedCurrency),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(historyListProvider.notifier).refresh();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: Text(l10n.historyTab),
                pinned: true,
                actions: [
                  IconButton(
                    tooltip: l10n.manualBillAction,
                    icon: const Icon(Icons.note_add_outlined),
                    onPressed: () => context.pushNamed(
                      Routes.billReviewName,
                      extra: OcrResult.manual(),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.historyFilterTooltip,
                    icon: Badge(
                      isLabelVisible: filter.hasActiveFilters,
                      label: Text(
                        l10n.historyFilterActiveBadge,
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: const Icon(Icons.tune),
                    ),
                    onPressed: () => _openFilterSheet(
                      context,
                      ref,
                      currencies,
                      filter,
                    ),
                  ),
                ],
              ),
              if (summary != null)
                SliverToBoxAdapter(
                  child: _SummaryCards(
                    summary: summary,
                    defaultCurrency: defaultCurrency,
                  ),
                ),
              if (filter.hasActiveFilters && hasItems)
                SliverToBoxAdapter(
                  child: _ActiveFilterChips(
                    filter: filter,
                    currencies: currencies,
                    onRemoveStatus: () => ref
                        .read(historyFilterProvider.notifier)
                        .setPaymentStatus(null),
                    onRemoveCurrency: () {
                      final current = ref.read(historyFilterProvider);
                      final normalized = normalizeHistoryFilter(
                        current.copyWith(currencyCode: null),
                        currencies,
                      );
                      ref
                          .read(historyFilterProvider.notifier)
                          .apply(normalized);
                    },
                    onReset: () =>
                        ref.read(historyFilterProvider.notifier).reset(),
                  ),
                ),
              if (!isPlus && hasHistoryAccess)
                SliverToBoxAdapter(
                  child: _FreeHistoryPlusBanner(
                    freeDays: PlusFeatureLimits.freeHistoryDays,
                    plusDays: PlusFeatureLimits.plusHistoryDays,
                    onTap: () => _showFreeHistoryPlusSheet(
                      context,
                      freeDays: PlusFeatureLimits.freeHistoryDays,
                      plusDays: PlusFeatureLimits.plusHistoryDays,
                      currency: insightCurrency,
                    ),
                  ),
                )
              else if (!isPlus || !isBannerDismissed)
                SliverToBoxAdapter(
                  child: _HistoryAccessBanner(
                    isPlus: isPlus,
                    hasHistoryAccess: hasHistoryAccess,
                    days: historyDays,
                    onDismiss: isPlus && bannerReady && !isBannerDismissed
                        ? () => ref
                              .read(historyPlusBannerProvider.notifier)
                              .dismiss()
                        : null,
                  ),
                ),
              if (isPlus && hasHistoryAccess && hasSummary)
                SliverToBoxAdapter(
                  child: _MonthlyInsightSection(
                    isPlus: isPlus,
                    insight: monthlyInsight,
                    month: _selectedInsightMonth,
                    currency: selectedCurrency,
                    availableCurrencies: currencies,
                    canGoNext: _canGoNextMonth(_selectedInsightMonth),
                    canGoPrevious: _canReachMonth(
                      _selectedInsightMonth,
                      planCode: planCode,
                    ),
                    onPreviousMonth: () =>
                        _previousInsightMonth(planCode: planCode),
                    onNextMonth: _nextInsightMonth,
                    onCurrencyChanged: (code) => setState(
                      () => _selectedInsightCurrency = code,
                    ),
                  ),
                ),
              if (filter.hasActiveFilters && hasItems)
                SliverToBoxAdapter(
                  child: _FilteredCountLabel(filteredCount: items.length),
                ),
              if (historyState.isLoadingInitial)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (historyState.initialFailure != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    message: l10n.errorGeneric,
                    onRetry: () =>
                        ref.read(historyListProvider.notifier).refresh(),
                  ),
                )
              else if (!hasHistoryAccess)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else if (!hasSummary)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else if (!hasItems && filter.hasActiveFilters)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _FilteredEmptyState(
                    onReset: () =>
                        ref.read(historyFilterProvider.notifier).reset(),
                  ),
                )
              else if (hasItems)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.h),
                    itemBuilder: (context, i) {
                      final bill = items[i];
                      final currency = CurrencyFormatter.of(bill.currencyCode);
                      final createdLabel = AppFormat.longDate(
                        AppFormat.intlLocaleOf(Localizations.localeOf(context)),
                      ).format(bill.createdAt);
                      return Card(
                        child: ListTile(
                          title: Text(bill.title),
                          subtitle: Text(
                            '${currency.format(bill.totalAmount)}  •  ${_paymentStatusLabel(l10n, bill.paymentStatus)}  •  $createdLabel',
                          ),
                          trailing: IconButton(
                            tooltip: l10n.deleteBillAction,
                            onPressed: () => _deleteBill(
                              context,
                              ref,
                              bill.id,
                              currency.format(bill.totalAmount),
                            ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          onTap: () => context.pushNamed(
                            Routes.billDetailName,
                            pathParameters: {'billId': bill.id},
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                ),
              if (historyState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (historyState.loadMoreFailure != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(historyListProvider.notifier).loadMore(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              const SliverToBoxAdapter(
                child: BannerAdWidget(placement: BannerAdPlacement.history),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _paymentStatusLabel(AppL10n l10n, BillPaymentStatus status) =>
      switch (status) {
        BillPaymentStatus.unassigned => l10n.historyStatusUnassigned,
        BillPaymentStatus.unpaid => l10n.historyStatusUnpaid,
        BillPaymentStatus.partial => l10n.historyStatusPartial,
        BillPaymentStatus.settled => l10n.historyStatusSettled,
      };

  Future<void> _deleteBill(
    BuildContext context,
    WidgetRef ref,
    String billId,
    String formattedTotal,
  ) async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBillConfirmTitle),
        content: Text(l10n.deleteBillConfirmBody('', formattedTotal)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
              foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteBillAction),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final deleted = await ref
        .read(historyListProvider.notifier)
        .deleteBill(billId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(deleted ? l10n.deleteBillSuccess : l10n.errorGeneric),
        ),
      );
  }

  void _openFilterSheet(
    BuildContext context,
    WidgetRef ref,
    List<String> currencies,
    HistoryFilterState currentFilter,
  ) {
    final draft = HistoryFilterState(
      sort: currentFilter.sort,
      paymentStatus: currentFilter.paymentStatus,
      currencyCode: currentFilter.currencyCode,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _FilterSheet(
        initialFilter: draft,
        currencies: currencies,
        onApply: (applied) {
          final normalized = normalizeHistoryFilter(applied, currencies);
          ref.read(historyFilterProvider.notifier).apply(normalized);
        },
      ),
    );
  }

  Future<void> _showFreeHistoryPlusSheet(
    BuildContext context, {
    required int freeDays,
    required int plusDays,
    required NumberFormat currency,
  }) async {
    final shouldUpgrade = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _FreeHistoryPlusSheet(
        freeDays: freeDays,
        plusDays: plusDays,
        currency: currency,
      ),
    );
    if (shouldUpgrade == true && context.mounted) {
      context.goNamed(Routes.settingsName);
    }
  }
}

class _FilteredCountLabel extends StatelessWidget {
  const _FilteredCountLabel({required this.filteredCount});

  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      child: Text(
        l10n.historyFilterCount(filteredCount, 0),
        style: TextStyle(fontSize: 12.sp, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.filter,
    required this.currencies,
    required this.onRemoveStatus,
    required this.onRemoveCurrency,
    required this.onReset,
  });

  final HistoryFilterState filter;
  final List<String> currencies;
  final VoidCallback onRemoveStatus;
  final VoidCallback onRemoveCurrency;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final chips = <Widget>[];

    if (filter.paymentStatus != null) {
      chips.add(
        _FilterChip(
          label: _statusLabel(l10n, filter.paymentStatus!),
          onRemoved: onRemoveStatus,
        ),
      );
    }

    if (filter.currencyCode != null) {
      chips.add(
        _FilterChip(label: filter.currencyCode!, onRemoved: onRemoveCurrency),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      child: Row(
        children: [
          Wrap(spacing: 8.w, runSpacing: 4.h, children: chips),
          SizedBox(width: 8.w),
          TextButton.icon(
            icon: Icon(Icons.close, size: 16.r),
            label: Text(
              l10n.historyFilterReset,
              style: TextStyle(fontSize: 12.sp),
            ),
            onPressed: onReset,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: scheme.error,
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(AppL10n l10n, BillPaymentStatus status) =>
      switch (status) {
        BillPaymentStatus.unassigned => l10n.historyStatusUnassigned,
        BillPaymentStatus.unpaid => l10n.historyStatusUnpaid,
        BillPaymentStatus.partial => l10n.historyStatusPartial,
        BillPaymentStatus.settled => l10n.historyStatusSettled,
      };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemoved});

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: scheme.onSecondaryContainer,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemoved,
            child: Icon(
              Icons.close,
              size: 14.r,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialFilter,
    required this.currencies,
    required this.onApply,
  });

  final HistoryFilterState initialFilter;
  final List<String> currencies;
  final ValueChanged<HistoryFilterState> onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late HistoryFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
  }

  bool get _isNominalAvailable =>
      _draft.currencyCode != null || widget.currencies.length == 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.historyFilterTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                _SectionLabel(l10n.historyFilterSort),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _SortChip(
                      label: l10n.historySortNewest,
                      selected: _draft.sort == HistorySort.newest,
                      onSelected: () => setState(
                        () =>
                            _draft = _draft.copyWith(sort: HistorySort.newest),
                      ),
                    ),
                    _SortChip(
                      label: l10n.historySortOldest,
                      selected: _draft.sort == HistorySort.oldest,
                      onSelected: () => setState(
                        () =>
                            _draft = _draft.copyWith(sort: HistorySort.oldest),
                      ),
                    ),
                    _SortChip(
                      label: l10n.historySortTitle,
                      selected: _draft.sort == HistorySort.titleAsc,
                      onSelected: () => setState(
                        () => _draft = _draft.copyWith(
                          sort: HistorySort.titleAsc,
                        ),
                      ),
                    ),
                    _SortChip(
                      label: l10n.historySortAmountDesc,
                      selected: _draft.sort == HistorySort.amountDesc,
                      enabled: _isNominalAvailable,
                      onSelected: () => setState(
                        () => _draft = _draft.copyWith(
                          sort: HistorySort.amountDesc,
                        ),
                      ),
                    ),
                    _SortChip(
                      label: l10n.historySortAmountAsc,
                      selected: _draft.sort == HistorySort.amountAsc,
                      enabled: _isNominalAvailable,
                      onSelected: () => setState(
                        () => _draft = _draft.copyWith(
                          sort: HistorySort.amountAsc,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isNominalAvailable) ...[
                  SizedBox(height: 4.h),
                  Text(
                    l10n.historySortNominalDisabled,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                _SectionLabel(l10n.historyFilterStatus),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _StatusChoiceChip(
                      label: l10n.historyStatusAll,
                      selected: _draft.paymentStatus == null,
                      onSelected: () => setState(
                        () => _draft = _draft.copyWith(paymentStatus: null),
                      ),
                    ),
                    ...BillPaymentStatus.values.map(
                      (s) => _StatusChoiceChip(
                        label: _statusLabel(l10n, s),
                        selected: _draft.paymentStatus == s,
                        onSelected: () => setState(
                          () => _draft = _draft.copyWith(paymentStatus: s),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _SectionLabel(l10n.historyFilterCurrency),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _StatusChoiceChip(
                      label: l10n.historyStatusAll,
                      selected: _draft.currencyCode == null,
                      onSelected: () => setState(
                        () {
                          _draft = normalizeHistoryFilter(
                            _draft.copyWith(currencyCode: null),
                            widget.currencies,
                          );
                        },
                      ),
                    ),
                    ...widget.currencies.map(
                      (c) => _StatusChoiceChip(
                        label: c,
                        selected: _draft.currencyCode == c,
                        onSelected: () => setState(
                          () => _draft = _draft.copyWith(currencyCode: c),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _draft = const HistoryFilterState()),
                        child: Text(l10n.historyFilterReset),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onApply(_draft);
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.applyAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppL10n l10n, BillPaymentStatus status) =>
      switch (status) {
        BillPaymentStatus.unassigned => l10n.historyStatusUnassigned,
        BillPaymentStatus.unpaid => l10n.historyStatusUnpaid,
        BillPaymentStatus.partial => l10n.historyStatusPartial,
        BillPaymentStatus.settled => l10n.historyStatusSettled,
      };
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    this.enabled = true,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onSelected() : null,
      showCheckmark: false,
      selectedColor: scheme.primaryContainer,
      disabledColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected
            ? scheme.onPrimaryContainer
            : enabled
            ? null
            : scheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

class _StatusChoiceChip extends StatelessWidget {
  const _StatusChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: scheme.secondaryContainer,
    );
  }
}

// ---- Monthly Insight (unchanged, kept minimal for brevity) ----

class _MonthlyInsightSection extends StatelessWidget {
  const _MonthlyInsightSection({
    required this.isPlus,
    required this.insight,
    required this.month,
    required this.currency,
    required this.availableCurrencies,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrencyChanged,
  });
  final bool isPlus;
  final AsyncValue<MonthlySpendingInsight?> insight;
  final DateTime month;
  final String currency;
  final List<String> availableCurrencies;
  final bool canGoNext;
  final bool canGoPrevious;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyFormatter.of(currency);
    if (!isPlus) {
      return _InsightShell(
        locked: true,
        child: _LockedInsightPreview(currency: currencyFormat),
      );
    }
    return insight.when(
      loading: () => _InsightShell(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  AppL10n.of(context).monthlyInsightLoading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, _) => _InsightShell(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            AppL10n.of(context).monthlyInsightError,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      data: (data) {
        if (data == null || !data.isPlus) {
          return _InsightShell(
            locked: true,
            child: _LockedInsightPreview(currency: currencyFormat),
          );
        }
        return _InsightShell(
          child: _MonthlyInsightCard(
            insight: data,
            month: month,
            currency: currencyFormat,
            selectedCurrency: currency,
            availableCurrencies: availableCurrencies,
            canGoNext: canGoNext,
            canGoPrevious: canGoPrevious,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onCurrencyChanged: onCurrencyChanged,
          ),
        );
      },
    );
  }
}

class _InsightShell extends StatelessWidget {
  const _InsightShell({required this.child, this.locked = false});
  final Widget child;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: locked ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: child,
      ),
    );
  }
}

class _LockedInsightPreview extends StatelessWidget {
  const _LockedInsightPreview({required this.currency});
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_outlined, color: scheme.onSurfaceVariant),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.monthlyInsightTitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PlusInfoIcon(
                      title: l10n.monthlyInsightTitle,
                      message: l10n.monthlyInsightLockedSubtitle,
                      iconColor: scheme.onSurfaceVariant,
                    ),
                    _SmallPlusPill(color: scheme.onSurfaceVariant),
                  ],
                ),
                SizedBox(height: 12.h),
                _BlurredMetricRow(currency: currency),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          IconButton.filledTonal(
            tooltip: l10n.historyUpgradeCta,
            onPressed: () => context.goNamed(Routes.settingsName),
            icon: const Icon(Icons.workspace_premium_outlined),
          ),
        ],
      ),
    );
  }
}

class _MonthlyInsightCard extends StatelessWidget {
  const _MonthlyInsightCard({
    required this.insight,
    required this.month,
    required this.currency,
    required this.selectedCurrency,
    required this.availableCurrencies,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrencyChanged,
  });
  final MonthlySpendingInsight insight;
  final DateTime month;
  final NumberFormat currency;
  final String selectedCurrency;
  final List<String> availableCurrencies;
  final bool canGoNext;
  final bool canGoPrevious;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final monthLabel = DateFormat.MMMM(
      AppFormat.intlLocaleOf(Localizations.localeOf(context)),
    ).format(month);
    final mom = insight.monthOverMonthPercent;
    final showCurrencySelector = availableCurrencies.length > 1;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.monthlyInsightPreviousMonth,
                onPressed: canGoPrevious ? onPreviousMonth : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights,
                          color: scheme.primary,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            l10n.monthlyInsightTitle,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _SmallPlusPill(color: scheme.primary),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.monthlyInsightMonth(monthLabel, month.year),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.monthlyInsightNextMonth,
                onPressed: canGoNext ? onNextMonth : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (showCurrencySelector) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: availableCurrencies.map(
                (code) => ChoiceChip(
                  label: Text(code),
                  selected: code == selectedCurrency,
                  showCheckmark: false,
                  onSelected: (_) => onCurrencyChanged(code),
                  visualDensity: VisualDensity.compact,
                  selectedColor: scheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 12.sp,
                    color: code == selectedCurrency
                        ? scheme.onPrimaryContainer
                        : null,
                  ),
                ),
              ).toList(growable: false),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.monthlyInsightTotal,
                  value: currency.format(insight.totalAmount),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  label: l10n.monthlyInsightAverage,
                  value: currency.format(insight.averageBillAmount),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.monthlyInsightBills,
                  value: '${insight.billCount}',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  label: l10n.monthlyInsightOutstanding,
                  value: currency.format(insight.outstandingAmount),
                ),
              ),
            ],
          ),
          if (mom != null) ...[
            SizedBox(height: 12.h),
            _MonthComparison(percent: mom),
          ],
          if (insight.monthlyTrend.isNotEmpty) ...[
            SizedBox(height: 14.h),
            _TrendBars(points: insight.monthlyTrend, currency: currency),
          ],
          if (insight.topMerchants.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Text(
              l10n.monthlyInsightTopMerchants,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6.h),
            ...insight.topMerchants.map(
              (m) => _MerchantRow(merchant: m, currency: currency),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MonthComparison extends StatelessWidget {
  const _MonthComparison({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isUp = percent > 0;
    final isFlat = percent.abs() < 0.01;
    final icon = isFlat
        ? Icons.trending_flat
        : isUp
        ? Icons.trending_up
        : Icons.trending_down;
    final label = isFlat
        ? l10n.monthlyInsightNoChange
        : isUp
        ? l10n.monthlyInsightIncrease(percent.abs().toStringAsFixed(1))
        : l10n.monthlyInsightDecrease(percent.abs().toStringAsFixed(1));
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 18.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.points, required this.currency});
  final List<MonthlySpendingTrendPoint> points;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxAmount = points.fold<double>(
      0,
      (max, p) => p.totalAmount > max ? p.totalAmount : max,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points
          .map((point) {
            final ratio = maxAmount <= 0 ? 0.04 : point.totalAmount / maxAmount;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    Tooltip(
                      message: currency.format(point.totalAmount),
                      child: Container(
                        height: (52.h * ratio.clamp(0.04, 1)).toDouble(),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      DateFormat.MMM().format(point.monthStart),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({required this.merchant, required this.currency});
  final MerchantSpendingInsight merchant;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              merchant.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            currency.format(merchant.totalAmount),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPlusPill extends StatelessWidget {
  const _SmallPlusPill({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Semantics(
      label: l10n.commonPlus,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          l10n.commonPlus,
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BlurredMetricRow extends StatelessWidget {
  const _BlurredMetricRow({required this.currency});
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: AppL10n.of(context).monthlyInsightTotal,
            value: currency.format(0),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _MetricTile(
            label: AppL10n.of(context).monthlyInsightBills,
            value: '--',
          ),
        ),
      ],
    );
  }
}

class _FreeHistoryPlusSheet extends StatelessWidget {
  const _FreeHistoryPlusSheet({
    required this.freeDays,
    required this.plusDays,
    required this.currency,
  });

  final int freeDays;
  final int plusDays;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.historyFreePlusSheetTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _SmallPlusPill(color: scheme.primary),
                  ],
                ),
                SizedBox(height: 16.h),
                _FreeSheetFeatureRow(
                  icon: Icons.history_toggle_off_outlined,
                  title: l10n.historyFreePlusHistoryTitle,
                  body: l10n.historyFreePlusHistoryBody(freeDays, plusDays),
                ),
                SizedBox(height: 12.h),
                _FreeSheetFeatureRow(
                  icon: Icons.insights_outlined,
                  title: l10n.monthlyInsightTitle,
                  body: l10n.monthlyInsightLockedSubtitle,
                ),
                SizedBox(height: 14.h),
                _BlurredMetricRow(currency: currency),
                SizedBox(height: 20.h),
                FilledButton.icon(
                  icon: Icon(Icons.workspace_premium_outlined, size: 20.r),
                  label: Text(l10n.historyUpgradeCta),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.historyFreePlusDismissAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeSheetFeatureRow extends StatelessWidget {
  const _FreeSheetFeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.onSurfaceVariant, size: 22.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeHistoryPlusBanner extends StatelessWidget {
  const _FreeHistoryPlusBanner({
    required this.freeDays,
    required this.plusDays,
    required this.onTap,
  });

  final int freeDays;
  final int plusDays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final semantics = l10n.historyFreePlusBannerSemantics(freeDays);
    final label = l10n.historyFreePlusBannerLabel(freeDays);
    return Semantics(
      button: true,
      label: semantics,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 48.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_outlined,
                      color: scheme.onSurfaceVariant,
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _SmallPlusPill(color: scheme.primary),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.chevron_right,
                      color: scheme.onSurfaceVariant,
                      size: 20.r,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryAccessBanner extends StatelessWidget {
  const _HistoryAccessBanner({
    required this.isPlus,
    required this.hasHistoryAccess,
    required this.days,
    this.onDismiss,
  });
  final bool isPlus;
  final bool hasHistoryAccess;
  final int days;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bg = isPlus ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final fg = isPlus ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    final title = isPlus
        ? l10n.historyWindowPlus
        : hasHistoryAccess
        ? l10n.historyWindowFree
        : l10n.historyWindowAnonymous;
    final details = isPlus
        ? l10n.historyWindowSubtitle(days)
        : hasHistoryAccess
        ? l10n.historyWindowFreeSubtitle(
            PlusFeatureLimits.freeHistoryDays,
            PlusFeatureLimits.plusHistoryDays,
          )
        : l10n.historyWindowAnonymousSubtitle;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: fg.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(
              isPlus
                  ? Icons.workspace_premium
                  : hasHistoryAccess
                  ? Icons.history_toggle_off_outlined
                  : Icons.lock_outline,
              color: fg,
              size: 22.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: fg,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isPlus)
                        Semantics(
                          label: l10n.commonPlus,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: fg.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              l10n.commonPlus,
                              style: TextStyle(
                                color: fg,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      PlusInfoIcon(
                        title: title,
                        message: details,
                        iconColor: fg,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isPlus && onDismiss != null) ...[
              SizedBox(width: 4.w),
              IconButton(
                tooltip: l10n.historyPlusBannerDismiss,
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: fg, size: 20.r),
              ),
            ],
            if (!isPlus) ...[
              SizedBox(width: 8.w),
              IconButton.filledTonal(
                tooltip: l10n.historyUpgradeCta,
                onPressed: () => context.goNamed(Routes.settingsName),
                icon: const Icon(Icons.workspace_premium_outlined),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatefulWidget {
  const _SummaryCards({
    required this.summary,
    required this.defaultCurrency,
  });
  final HistorySummary summary;
  final String defaultCurrency;

  @override
  State<_SummaryCards> createState() => _SummaryCardsState();
}

class _SummaryCardsState extends State<_SummaryCards> {
  static const _autoRotateInterval = Duration(seconds: 4);
  static const _pageDuration = Duration(milliseconds: 300);

  final PageController _controller = PageController();
  Timer? _timer;
  bool _userInteracting = false;
  int _currentPage = 0;
  late List<OutstandingByCurrency> _ordered;

  bool get _isCarousel => _ordered.length > 1;

  @override
  void initState() {
    super.initState();
    _ordered = _orderOutstanding();
    _startAutoRotate();
  }

  @override
  void didUpdateWidget(covariant _SummaryCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.outstanding != widget.summary.outstanding) {
      _ordered = _orderOutstanding();
      _startAutoRotate();
      if (_currentPage >= _ordered.length) {
        _currentPage = 0;
        _controller.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Default currency first, then remaining currencies alphabetically.
  List<OutstandingByCurrency> _orderOutstanding() {
    final list = [...widget.summary.outstanding];
    list.sort((a, b) {
      if (a.currency == widget.defaultCurrency) return -1;
      if (b.currency == widget.defaultCurrency) return 1;
      return a.currency.compareTo(b.currency);
    });
    return list;
  }

  void _startAutoRotate() {
    _timer?.cancel();
    _timer = null;
    if (!_isCarousel) return;
    if (WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      return;
    }
    _timer = Timer.periodic(_autoRotateInterval, (_) {
      if (!mounted || _userInteracting || !_controller.hasClients) return;
      final current = _controller.page?.round() ?? 0;
      final next = current >= _ordered.length - 1 ? 0 : current + 1;
      _controller.animateToPage(
        next,
        duration: _pageDuration,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final totalBills = widget.summary.totalBillCount;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.historyTotalBills,
              value: '$totalBills',
              icon: Icons.receipt_long_outlined,
              color: scheme.primaryContainer,
              onColor: scheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _buildOutstandingCard(context)),
        ],
      ),
    );
  }

  Widget _buildOutstandingCard(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final outstanding = _ordered;

    if (outstanding.isEmpty) {
      final zero = CurrencyFormatter.of(widget.defaultCurrency).format(0);
      return _StatCard(
        label: l10n.historyOutstanding,
        value: zero,
        icon: Icons.account_balance_wallet_outlined,
        color: scheme.tertiaryContainer,
        onColor: scheme.onTertiaryContainer,
      );
    }

    if (!_isCarousel) {
      final entry = outstanding.first;
      final entryFormat = CurrencyFormatter.of(entry.currency);
      return _StatCard(
        label: l10n.historyOutstanding,
        value: entryFormat.format(entry.amount),
        icon: Icons.account_balance_wallet_outlined,
        color: scheme.tertiaryContainer,
        onColor: scheme.onTertiaryContainer,
      );
    }

    return _StatCardShell(
      label: l10n.historyOutstanding,
      icon: Icons.account_balance_wallet_outlined,
      color: scheme.tertiaryContainer,
      onColor: scheme.onTertiaryContainer,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  setState(() => _userInteracting = true);
                } else if (notification is ScrollEndNotification) {
                  setState(() => _userInteracting = false);
                  _startAutoRotate();
                }
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: outstanding.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final entry = outstanding[index];
                  final entryFormat = CurrencyFormatter.of(entry.currency);
                  return Semantics(
                    label:
                        '${l10n.historyOutstanding}: '
                        '${entryFormat.format(entry.amount)}. '
                        '${l10n.historyOutstandingCarouselPage(index + 1, outstanding.length)}.',
                    child: _CardValueText(
                      value: entryFormat.format(entry.amount),
                      color: scheme.onTertiaryContainer,
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isCarousel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  outstanding.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: _currentPage == i ? 8.w : 5.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? scheme.onTertiaryContainer
                          : scheme.onTertiaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single-line scaled value shown inside a summary stat card.
class _CardValueText extends StatelessWidget {
  const _CardValueText({required this.value, required this.color});
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// Stat card shell. Both summary cards share this exact structure and a fixed
/// value area so they always have the same height — regardless of whether the
/// outstanding side shows a single value, a carousel, or an empty state.
class _StatCardShell extends StatelessWidget {
  const _StatCardShell({
    required this.label,
    required this.icon,
    required this.color,
    required this.onColor,
    required this.child,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: onColor, size: 20.r),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: onColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          SizedBox(height: 40.h, child: child),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return _StatCardShell(
      label: label,
      icon: icon,
      color: color,
      onColor: onColor,
      child: _CardValueText(value: value, color: onColor),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56.r,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.historyEmptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 56.r,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.historyFilterEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: scheme.onSurfaceVariant),
            ),
            SizedBox(height: 16.h),
            FilledButton.tonal(
              onPressed: onReset,
              child: Text(l10n.historyFilterReset),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48.r,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
