import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/bill_template.dart';

part 'bill_templates_notifier.g.dart';

/// Outcome of template mutations without touching the displayed list until
/// the server confirms (list refreshes via invalidateSelf on success).
class TemplateActionResult {
  const TemplateActionResult._({this.limited = false, this.failed = false});

  const TemplateActionResult.ok() : this._();
  const TemplateActionResult.limited() : this._(limited: true);
  const TemplateActionResult.failed() : this._(failed: true);

  final bool limited;
  final bool failed;
  bool get ok => !limited && !failed;
}

/// M4/F12 template list + mutations. List loads on build (PostgREST SELECT,
/// RLS owner-only); create/instantiate/delete go through the
/// `*_template*` RPCs that enforce the Free 5-cap and snapshot validation
/// server-side.
@riverpod
class BillTemplates extends _$BillTemplates {
  @override
  Future<List<BillTemplate>> build() async {
    final repo = ref.watch(billRepositoryProvider);
    final res = await repo.listTemplates();
    return switch (res) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw failure,
    };
  }

  /// Centralized Free-limit match (case-insensitive; the RPC raises
  /// `template_limit: ...` which PostgREST surfaces in the message).
  static bool isLimitError(Object e) =>
      e.toString().toLowerCase().contains('template_limit');

  Future<TemplateActionResult> createFromBill({
    required String billId,
    required String name,
  }) async {
    try {
      final repo = ref.read(billRepositoryProvider);
      // Cold-start guard (same class as the share-link first-tap failure):
      // without a re-attached session the RPC raises 'authentication
      // required', the toast says failed, and the retry then succeeds —
      // leaving the user staring at a template that "failed" to create.
      final authRes = await repo.ensureSignedIn();
      if (authRes is ResultFailure) {
        AppLogger.error(
          'BillTemplates.createFromBill ensureSignedIn failed',
          authRes.failure,
          StackTrace.current,
        );
        return const TemplateActionResult.failed();
      }
      final res = await repo.createTemplateFromBill(
        billId: billId,
        name: name.trim(),
      );
      switch (res) {
        case ResultFailure(:final failure):
          AppLogger.error(
            'BillTemplates.createFromBill failed',
            failure,
            StackTrace.current,
          );
          return isLimitError(failure)
              ? const TemplateActionResult.limited()
              : const TemplateActionResult.failed();
        case Success():
          ref.invalidateSelf();
          return const TemplateActionResult.ok();
      }
    } catch (e, st) {
      AppLogger.error('BillTemplates.createFromBill failed', e, st);
      return isLimitError(e)
          ? const TemplateActionResult.limited()
          : const TemplateActionResult.failed();
    }
  }

  /// Instantiates [templateId] into a fresh bill; returns the new bill id.
  Future<String?> instantiate(String templateId) async {
    try {
      final repo = ref.read(billRepositoryProvider);
      final authRes = await repo.ensureSignedIn();
      if (authRes is ResultFailure) {
        AppLogger.error(
          'BillTemplates.instantiate ensureSignedIn failed',
          authRes.failure,
          StackTrace.current,
        );
        return null;
      }
      final res = await repo.instantiateTemplate(templateId);
      switch (res) {
        case ResultFailure(:final failure):
          AppLogger.error(
            'BillTemplates.instantiate failed',
            failure,
            StackTrace.current,
          );
          return null;
        case Success(:final data):
          ref.invalidateSelf();
          return data;
      }
    } catch (e, st) {
      AppLogger.error('BillTemplates.instantiate failed', e, st);
      return null;
    }
  }

  Future<bool> remove(String templateId) async {
    try {
      final repo = ref.read(billRepositoryProvider);
      final authRes = await repo.ensureSignedIn();
      if (authRes is ResultFailure) {
        AppLogger.error(
          'BillTemplates.remove ensureSignedIn failed',
          authRes.failure,
          StackTrace.current,
        );
        return false;
      }
      final res = await repo.deleteTemplate(templateId);
      if (res is ResultFailure) {
        AppLogger.error(
          'BillTemplates.remove failed',
          res.failure,
          StackTrace.current,
        );
        return false;
      }
      ref.invalidateSelf();
      return true;
    } catch (e, st) {
      AppLogger.error('BillTemplates.remove failed', e, st);
      return false;
    }
  }
}
