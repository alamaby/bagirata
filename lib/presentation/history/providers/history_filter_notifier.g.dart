// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_filter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryFilterNotifier)
const historyFilterProvider = HistoryFilterNotifierProvider._();

final class HistoryFilterNotifierProvider
    extends $NotifierProvider<HistoryFilterNotifier, HistoryFilterState> {
  const HistoryFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyFilterNotifierHash();

  @$internal
  @override
  HistoryFilterNotifier create() => HistoryFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilterState>(value),
    );
  }
}

String _$historyFilterNotifierHash() =>
    r'9d29d5a0caf16bd4c505c00c4920ffe06c6002f2';

abstract class _$HistoryFilterNotifier extends $Notifier<HistoryFilterState> {
  HistoryFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HistoryFilterState, HistoryFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterState, HistoryFilterState>,
              HistoryFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
