// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stateful controller for the split screen. Loads the bill graph from the
/// repository and lets the UI mutate participants/assignments live.
///
/// Persistence strategy: participants are upserted on creation (so they have
/// stable IDs), assignments are persisted via [replaceAssignments] on every
/// toggle — the bill graph is small enough that one round-trip per toggle is
/// fine, and it removes the need for an explicit save button.

@ProviderFor(SplitNotifier)
const splitFamily = SplitNotifierFamily._();

/// Stateful controller for the split screen. Loads the bill graph from the
/// repository and lets the UI mutate participants/assignments live.
///
/// Persistence strategy: participants are upserted on creation (so they have
/// stable IDs), assignments are persisted via [replaceAssignments] on every
/// toggle — the bill graph is small enough that one round-trip per toggle is
/// fine, and it removes the need for an explicit save button.
final class SplitNotifierProvider
    extends $AsyncNotifierProvider<SplitNotifier, SplitState> {
  /// Stateful controller for the split screen. Loads the bill graph from the
  /// repository and lets the UI mutate participants/assignments live.
  ///
  /// Persistence strategy: participants are upserted on creation (so they have
  /// stable IDs), assignments are persisted via [replaceAssignments] on every
  /// toggle — the bill graph is small enough that one round-trip per toggle is
  /// fine, and it removes the need for an explicit save button.
  const SplitNotifierProvider._({
    required SplitNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'splitFamily',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$splitNotifierHash();

  @override
  String toString() {
    return r'splitFamily'
        ''
        '($argument)';
  }

  @$internal
  @override
  SplitNotifier create() => SplitNotifier();

  @override
  bool operator ==(Object other) {
    return other is SplitNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$splitNotifierHash() => r'095168825df007a966f4139dc28cd1adc3d3194b';

/// Stateful controller for the split screen. Loads the bill graph from the
/// repository and lets the UI mutate participants/assignments live.
///
/// Persistence strategy: participants are upserted on creation (so they have
/// stable IDs), assignments are persisted via [replaceAssignments] on every
/// toggle — the bill graph is small enough that one round-trip per toggle is
/// fine, and it removes the need for an explicit save button.

final class SplitNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SplitNotifier,
          AsyncValue<SplitState>,
          SplitState,
          FutureOr<SplitState>,
          String
        > {
  const SplitNotifierFamily._()
    : super(
        retry: null,
        name: r'splitFamily',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stateful controller for the split screen. Loads the bill graph from the
  /// repository and lets the UI mutate participants/assignments live.
  ///
  /// Persistence strategy: participants are upserted on creation (so they have
  /// stable IDs), assignments are persisted via [replaceAssignments] on every
  /// toggle — the bill graph is small enough that one round-trip per toggle is
  /// fine, and it removes the need for an explicit save button.

  SplitNotifierProvider call(String billId) =>
      SplitNotifierProvider._(argument: billId, from: this);

  @override
  String toString() => r'splitFamily';
}

/// Stateful controller for the split screen. Loads the bill graph from the
/// repository and lets the UI mutate participants/assignments live.
///
/// Persistence strategy: participants are upserted on creation (so they have
/// stable IDs), assignments are persisted via [replaceAssignments] on every
/// toggle — the bill graph is small enough that one round-trip per toggle is
/// fine, and it removes the need for an explicit save button.

abstract class _$SplitNotifier extends $AsyncNotifier<SplitState> {
  late final _$args = ref.$arg as String;
  String get billId => _$args;

  FutureOr<SplitState> build(String billId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<SplitState>, SplitState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SplitState>, SplitState>,
              AsyncValue<SplitState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
