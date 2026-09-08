// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_share_link_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BillShareLink)
const billShareLinkFamily = BillShareLinkFamily._();

final class BillShareLinkProvider
    extends $AsyncNotifierProvider<BillShareLink, BillShareState?> {
  const BillShareLinkProvider._({
    required BillShareLinkFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'billShareLinkFamily',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$billShareLinkHash();

  @override
  String toString() {
    return r'billShareLinkFamily'
        ''
        '($argument)';
  }

  @$internal
  @override
  BillShareLink create() => BillShareLink();

  @override
  bool operator ==(Object other) {
    return other is BillShareLinkProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$billShareLinkHash() => r'7ec22e732fa7b004280a0d8d144f872471d25e6e';

final class BillShareLinkFamily extends $Family
    with
        $ClassFamilyOverride<
          BillShareLink,
          AsyncValue<BillShareState?>,
          BillShareState?,
          FutureOr<BillShareState?>,
          String
        > {
  const BillShareLinkFamily._()
    : super(
        retry: null,
        name: r'billShareLinkFamily',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BillShareLinkProvider call(String billId) =>
      BillShareLinkProvider._(argument: billId, from: this);

  @override
  String toString() => r'billShareLinkFamily';
}

abstract class _$BillShareLink extends $AsyncNotifier<BillShareState?> {
  late final _$args = ref.$arg as String;
  String get billId => _$args;

  FutureOr<BillShareState?> build(String billId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<BillShareState?>, BillShareState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BillShareState?>, BillShareState?>,
              AsyncValue<BillShareState?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
