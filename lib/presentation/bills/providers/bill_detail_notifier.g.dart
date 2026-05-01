// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the bill graph for the detail screen and exposes the settlement
/// toggle. Strategy: optimistic UI update; on persist failure roll back to the
/// previous state. After a successful participant update, evaluate whether
/// the whole bill should flip `is_settled`.

@ProviderFor(BillDetailNotifier)
const billDetailFamily = BillDetailNotifierFamily._();

/// Loads the bill graph for the detail screen and exposes the settlement
/// toggle. Strategy: optimistic UI update; on persist failure roll back to the
/// previous state. After a successful participant update, evaluate whether
/// the whole bill should flip `is_settled`.
final class BillDetailNotifierProvider
    extends $AsyncNotifierProvider<BillDetailNotifier, BillDetailState> {
  /// Loads the bill graph for the detail screen and exposes the settlement
  /// toggle. Strategy: optimistic UI update; on persist failure roll back to the
  /// previous state. After a successful participant update, evaluate whether
  /// the whole bill should flip `is_settled`.
  const BillDetailNotifierProvider._({
    required BillDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'billDetailFamily',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$billDetailNotifierHash();

  @override
  String toString() {
    return r'billDetailFamily'
        ''
        '($argument)';
  }

  @$internal
  @override
  BillDetailNotifier create() => BillDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is BillDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$billDetailNotifierHash() =>
    r'e60ccb9a087756d789cace3b3818fb158e93ea3b';

/// Loads the bill graph for the detail screen and exposes the settlement
/// toggle. Strategy: optimistic UI update; on persist failure roll back to the
/// previous state. After a successful participant update, evaluate whether
/// the whole bill should flip `is_settled`.

final class BillDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          BillDetailNotifier,
          AsyncValue<BillDetailState>,
          BillDetailState,
          FutureOr<BillDetailState>,
          String
        > {
  const BillDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'billDetailFamily',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads the bill graph for the detail screen and exposes the settlement
  /// toggle. Strategy: optimistic UI update; on persist failure roll back to the
  /// previous state. After a successful participant update, evaluate whether
  /// the whole bill should flip `is_settled`.

  BillDetailNotifierProvider call(String billId) =>
      BillDetailNotifierProvider._(argument: billId, from: this);

  @override
  String toString() => r'billDetailFamily';
}

/// Loads the bill graph for the detail screen and exposes the settlement
/// toggle. Strategy: optimistic UI update; on persist failure roll back to the
/// previous state. After a successful participant update, evaluate whether
/// the whole bill should flip `is_settled`.

abstract class _$BillDetailNotifier extends $AsyncNotifier<BillDetailState> {
  late final _$args = ref.$arg as String;
  String get billId => _$args;

  FutureOr<BillDetailState> build(String billId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<BillDetailState>, BillDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BillDetailState>, BillDetailState>,
              AsyncValue<BillDetailState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
