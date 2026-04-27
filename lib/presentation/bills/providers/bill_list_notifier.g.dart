// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Async-loaded list of bills for the current user. Uses [AsyncValue] so the
/// UI gets standard loading / data / error rendering for free.

@ProviderFor(BillListNotifier)
const billListProvider = BillListNotifierProvider._();

/// Async-loaded list of bills for the current user. Uses [AsyncValue] so the
/// UI gets standard loading / data / error rendering for free.
final class BillListNotifierProvider
    extends $AsyncNotifierProvider<BillListNotifier, List<Bill>> {
  /// Async-loaded list of bills for the current user. Uses [AsyncValue] so the
  /// UI gets standard loading / data / error rendering for free.
  const BillListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billListNotifierHash();

  @$internal
  @override
  BillListNotifier create() => BillListNotifier();
}

String _$billListNotifierHash() => r'95447fe656121aecaf73f03bde4a89f6d47153d7';

/// Async-loaded list of bills for the current user. Uses [AsyncValue] so the
/// UI gets standard loading / data / error rendering for free.

abstract class _$BillListNotifier extends $AsyncNotifier<List<Bill>> {
  FutureOr<List<Bill>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Bill>>, List<Bill>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Bill>>, List<Bill>>,
              AsyncValue<List<Bill>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
