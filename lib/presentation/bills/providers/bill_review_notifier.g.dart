// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_review_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live-editable review state seeded from an [OcrResult]. Total recalculation
/// happens on every mutation so the sticky bottom bar stays in sync.

@ProviderFor(BillReviewNotifier)
const billReviewFamily = BillReviewNotifierFamily._();

/// Live-editable review state seeded from an [OcrResult]. Total recalculation
/// happens on every mutation so the sticky bottom bar stays in sync.
final class BillReviewNotifierProvider
    extends $NotifierProvider<BillReviewNotifier, BillReviewState> {
  /// Live-editable review state seeded from an [OcrResult]. Total recalculation
  /// happens on every mutation so the sticky bottom bar stays in sync.
  const BillReviewNotifierProvider._({
    required BillReviewNotifierFamily super.from,
    required OcrResult super.argument,
  }) : super(
         retry: null,
         name: r'billReviewFamily',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$billReviewNotifierHash();

  @override
  String toString() {
    return r'billReviewFamily'
        ''
        '($argument)';
  }

  @$internal
  @override
  BillReviewNotifier create() => BillReviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillReviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillReviewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BillReviewNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$billReviewNotifierHash() =>
    r'c667d41083d642e8b37b5a6f7b7e4d102711cf8d';

/// Live-editable review state seeded from an [OcrResult]. Total recalculation
/// happens on every mutation so the sticky bottom bar stays in sync.

final class BillReviewNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          BillReviewNotifier,
          BillReviewState,
          BillReviewState,
          BillReviewState,
          OcrResult
        > {
  const BillReviewNotifierFamily._()
    : super(
        retry: null,
        name: r'billReviewFamily',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live-editable review state seeded from an [OcrResult]. Total recalculation
  /// happens on every mutation so the sticky bottom bar stays in sync.

  BillReviewNotifierProvider call(OcrResult ocr) =>
      BillReviewNotifierProvider._(argument: ocr, from: this);

  @override
  String toString() => r'billReviewFamily';
}

/// Live-editable review state seeded from an [OcrResult]. Total recalculation
/// happens on every mutation so the sticky bottom bar stays in sync.

abstract class _$BillReviewNotifier extends $Notifier<BillReviewState> {
  late final _$args = ref.$arg as OcrResult;
  OcrResult get ocr => _$args;

  BillReviewState build(OcrResult ocr);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<BillReviewState, BillReviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BillReviewState, BillReviewState>,
              BillReviewState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
