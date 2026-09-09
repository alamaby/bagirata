// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_templates_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// M4/F12 template list + mutations. List loads on build (PostgREST SELECT,
/// RLS owner-only); create/instantiate/delete go through the
/// `*_template*` RPCs that enforce the Free 5-cap and snapshot validation
/// server-side.

@ProviderFor(BillTemplates)
const billTemplatesProvider = BillTemplatesProvider._();

/// M4/F12 template list + mutations. List loads on build (PostgREST SELECT,
/// RLS owner-only); create/instantiate/delete go through the
/// `*_template*` RPCs that enforce the Free 5-cap and snapshot validation
/// server-side.
final class BillTemplatesProvider
    extends $AsyncNotifierProvider<BillTemplates, List<BillTemplate>> {
  /// M4/F12 template list + mutations. List loads on build (PostgREST SELECT,
  /// RLS owner-only); create/instantiate/delete go through the
  /// `*_template*` RPCs that enforce the Free 5-cap and snapshot validation
  /// server-side.
  const BillTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billTemplatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billTemplatesHash();

  @$internal
  @override
  BillTemplates create() => BillTemplates();
}

String _$billTemplatesHash() => r'70266304b2bfa1b7a0406704d3f796429c130e5d';

/// M4/F12 template list + mutations. List loads on build (PostgREST SELECT,
/// RLS owner-only); create/instantiate/delete go through the
/// `*_template*` RPCs that enforce the Free 5-cap and snapshot validation
/// server-side.

abstract class _$BillTemplates extends $AsyncNotifier<List<BillTemplate>> {
  FutureOr<List<BillTemplate>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<BillTemplate>>, List<BillTemplate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BillTemplate>>, List<BillTemplate>>,
              AsyncValue<List<BillTemplate>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
