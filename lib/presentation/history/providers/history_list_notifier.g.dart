// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryListNotifier)
const historyListProvider = HistoryListNotifierProvider._();

final class HistoryListNotifierProvider
    extends $NotifierProvider<HistoryListNotifier, HistoryListState> {
  const HistoryListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyListNotifierHash();

  @$internal
  @override
  HistoryListNotifier create() => HistoryListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryListState>(value),
    );
  }
}

String _$historyListNotifierHash() =>
    r'130332d6eb285aca6cb42231da3d123c75849c1b';

abstract class _$HistoryListNotifier extends $Notifier<HistoryListState> {
  HistoryListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HistoryListState, HistoryListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryListState, HistoryListState>,
              HistoryListState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
