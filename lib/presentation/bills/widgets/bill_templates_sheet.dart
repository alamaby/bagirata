import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/app_format.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/bill_templates_notifier.dart';
import '../../history/providers/history_list_notifier.dart';

/// M4/F12 template picker bottom sheet. Lists the owner's templates
/// (newest first) with per-row Use + delete; instantiate navigates to the
/// fresh bill's detail screen. Opened from the History AppBar.
class BillTemplatesSheet extends ConsumerStatefulWidget {
  const BillTemplatesSheet({super.key, required this.parentContext});

  /// The context that opened the sheet. Navigation after `pop()` must use
  /// this — the sheet's own context is deactivated once popped, and
  /// pushing through it throws ("deactivated widget's ancestor").
  final BuildContext parentContext;

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => BillTemplatesSheet(parentContext: context),
  );

  @override
  ConsumerState<BillTemplatesSheet> createState() =>
      _BillTemplatesSheetState();
}

class _BillTemplatesSheetState extends ConsumerState<BillTemplatesSheet> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final templates = ref.watch(billTemplatesProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.billTemplatesTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: templates.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.toString())),
                      TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(billTemplatesProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (list) => list.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(l10n.billTemplatesEmpty),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final t = list[i];
                          final busy = _busyId == t.id;
                          final dateLabel = AppFormat.longDate(
                            AppFormat.intlLocaleOf(
                              Localizations.localeOf(context),
                            ),
                          ).format(t.createdAt);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.name),
                            subtitle: Text(
                              '${l10n.billTemplateUsedCount(t.useCount)}  •  $dateLabel',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () => _useTemplate(ctx, t.id),
                                  child: Text(l10n.billTemplateUse),
                                ),
                                IconButton(
                                  tooltip: l10n.billTemplateDeleteTitle,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: busy
                                      ? null
                                      : () =>
                                            _confirmDelete(ctx, t.id, t.name),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useTemplate(BuildContext context, String templateId) async {
    final l10n = AppL10n.of(context);
    setState(() => _busyId = templateId);
    try {
      final newBillId = await ref
          .read(billTemplatesProvider.notifier)
          .instantiate(templateId);
      if (!context.mounted) return;
      if (newBillId == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.billTemplateInstantiateFailed)),
          );
        return;
      }
      ref.invalidate(historyListProvider);
      Navigator.of(context).pop();
      // Fire-and-forget via the opener's context (this sheet's context is
      // deactivated by the pop above); navigation owns its own lifecycle.
      unawaited(
        widget.parentContext.pushNamed(
          Routes.billDetailName,
          pathParameters: {'billId': newBillId},
        ),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String templateId,
    String name,
  ) async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.billTemplateDeleteTitle),
        content: Text(l10n.billTemplateDeleteBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
              foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteBillAction),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    setState(() => _busyId = templateId);
    try {
      final deleted = await ref
          .read(billTemplatesProvider.notifier)
          .remove(templateId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              deleted ? l10n.billTemplateDeleted : l10n.billTemplateDeleteFailed,
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }
}
