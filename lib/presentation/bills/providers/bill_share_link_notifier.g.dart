// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_share_link_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BillShareLink)
const billShareLinkProvider = BillShareLinkProvider._();

final class BillShareLinkProvider
    extends $AsyncNotifierProvider<BillShareLink, BillShareState?> {
  const BillShareLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billShareLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billShareLinkHash();

  @$internal
  @override
  BillShareLink create() => BillShareLink();
}

String _$billShareLinkHash() => r'66573c157adc5fdc39f6667bbd6f3db565ffdffb';

abstract class _$BillShareLink extends $AsyncNotifier<BillShareState?> {
  FutureOr<BillShareState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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
