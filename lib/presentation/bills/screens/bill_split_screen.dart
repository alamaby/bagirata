import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/participant.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shared/widgets/loading_view.dart';
import '../providers/split_notifier.dart';
import '../widgets/participant_avatar.dart';
import '../providers/saved_participants_notifier.dart';
import '../widgets/participant_suggestion_chips.dart';
import '../widgets/split_summary_sheet.dart';

/// Item-splitting screen.
///
/// Flow: user taps a participant avatar at the bottom to make them "active",
/// then taps items in the middle list to assign/unassign. Header keeps the
/// running unassigned amount visible so the user knows when they're done.
class BillSplitScreen extends ConsumerWidget {
  const BillSplitScreen({super.key, required this.billId});

  final String billId;

  void _exit(BuildContext context, WidgetRef ref) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final snap = switch (ref.read(authStateProvider)) {
      AsyncData<AuthSnapshot>(:final value) => value,
      _ => null,
    };
    final isSignedIn = snap?.userId != null && !(snap?.isAnonymous ?? true);
    context.go(isSignedIn ? Routes.history : Routes.scan);
  }

  /// Done with splitting → land on the settlement screen for this bill.
  void _finish(BuildContext context) {
    context.pushReplacementNamed(
      Routes.billDetailName,
      pathParameters: {'billId': billId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(splitFamily(billId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppL10n.of(context).billSplitTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: AppL10n.of(context).billSplitBackTooltip,
            onPressed: () => _exit(context, ref),
          ),
          actions: [
            TextButton(
              onPressed: () => _finish(context),
              child: Text(AppL10n.of(context).billSplitDone),
            ),
          ],
        ),
        body: SafeArea(
          child: async.when(
            loading: () => LoadingView(message: AppL10n.of(context).loading),
            error: (e, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(e.toString(), textAlign: TextAlign.center),
              ),
            ),
            data: (state) => _SplitBody(
              state: state,
              billId: billId,
              currency: CurrencyFormatter.of(state.bill.currencyCode),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitBody extends ConsumerWidget {
  const _SplitBody({
    required this.state,
    required this.billId,
    required this.currency,
  });

  final SplitState state;
  final String billId;
  final NumberFormat currency;

  SplitNotifier _notifier(WidgetRef ref) =>
      ref.read(splitFamily(billId).notifier);

  void _toast(BuildContext context, SplitActionError error) {
    final l10n = AppL10n.of(context);
    final msg = switch (error.kind) {
      SplitActionErrorKind.notReady => l10n.billSplitStateNotReady,
      SplitActionErrorKind.nameRequired => l10n.billSplitNameRequired,
      SplitActionErrorKind.duplicateName => l10n.billSplitDuplicateName,
      SplitActionErrorKind.addPersonFailed => l10n.billSplitAddPersonFailed(
        error.message ?? '',
      ),
      SplitActionErrorKind.selectPersonFirst => l10n.billSplitSelectPersonFirst,
      SplitActionErrorKind.saveAssignmentFailed =>
        l10n.billSplitSaveAssignmentFailed(error.message ?? ''),
      SplitActionErrorKind.removeParticipantFailed =>
        l10n.billSplitRemoveParticipantFailed(error.message ?? ''),
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmRemoveParticipant(
    BuildContext context,
    WidgetRef ref,
    Participant participant,
  ) async {
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.billSplitRemoveParticipantTitle),
        content: Text(l10n.billSplitRemoveParticipantMessage(participant.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n.billSplitRemoveParticipantConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final err = await _notifier(ref).removeParticipant(participant.id);
    if (err != null && context.mounted) _toast(context, err);
  }

  Future<void> _addParticipant(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final result =
        await showModalBottomSheet<({String name, String? phone})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _AddPersonSheet(
        billId: billId,
        nameCtrl: nameCtrl,
        phoneCtrl: phoneCtrl,
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      phoneCtrl.dispose();
    });
    if (result == null) return;
    if (result.name.trim().isEmpty) return;
    final err = await _notifier(
      ref,
    ).addParticipant(result.name, phone: result.phone);
    if (err != null && context.mounted) _toast(context, err);
    if (err == null) {
      await ref
          .read(savedParticipantsProvider.notifier)
          .bump(name: result.name, phone: result.phone);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _Header(
          totalAmount: state.bill.totalAmount,
          unassignedSubtotal: state.unassignedSubtotal,
          currency: currency,
        ),
        if (state.participants.length >= 2 && state.items.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final err = await _notifier(ref).assignAll();
                  if (err != null && context.mounted) _toast(context, err);
                },
                icon: const Icon(Icons.group_add_outlined),
                label: Text(AppL10n.of(context).billSplitAssignAll),
              ),
            ),
          ),
        Expanded(
          child: state.items.isEmpty
              ? Center(
                  child: Text(
                    AppL10n.of(context).billSplitEmptyItems,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    final assignees = state.participants
                        .where(
                          (p) => state.assignments.any(
                            (a) =>
                                a.itemId == item.id && a.participantId == p.id,
                          ),
                        )
                        .toList(growable: false);
                    final isMine =
                        state.selectedParticipantId != null &&
                        assignees.any(
                          (p) => p.id == state.selectedParticipantId,
                        );
                    return _ItemRow(
                      item: item,
                      assignees: assignees,
                      currency: currency,
                      activeMine: isMine,
                      hasSelected: state.selectedParticipantId != null,
                      onTap: () async {
                        final err = await _notifier(
                          ref,
                        ).toggleAssignment(item.id);
                        if (err != null && context.mounted) {
                          _toast(context, err);
                        }
                      },
                    );
                  },
                ),
        ),
        _SummaryButton(
          visible:
              state.unassignedSubtotal <= 0.0001 &&
              state.participants.isNotEmpty &&
              state.items.isNotEmpty,
          onTap: () => SplitSummarySheet.show(context, state),
        ),
        _ParticipantBar(
          participants: state.participants,
          selectedId: state.selectedParticipantId,
          onSelect: (id) => _notifier(ref).selectParticipant(id),
          onAdd: () => _addParticipant(context, ref),
          onRemove: (p) => _confirmRemoveParticipant(context, ref, p),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalAmount,
    required this.unassignedSubtotal,
    required this.currency,
  });

  final double totalAmount;
  final double unassignedSubtotal;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allAssigned = unassignedSubtotal <= 0.0001;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppL10n.of(context).billSplitTotalBill,
            style: TextStyle(
              fontSize: 12.sp,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            currency.format(totalAmount),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                allAssigned ? Icons.check_circle : Icons.pending_outlined,
                size: 16.r,
                color: allAssigned
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
              SizedBox(width: 6.w),
              Text(
                allAssigned
                    ? AppL10n.of(context).billSplitAllAssigned
                    : AppL10n.of(context).billSplitUnassigned(
                        currency.format(unassignedSubtotal),
                      ),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: allAssigned
                      ? Colors.green.shade800
                      : Colors.orange.shade900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.assignees,
    required this.currency,
    required this.activeMine,
    required this.hasSelected,
    required this.onTap,
  });

  final Item item;
  final List<Participant> assignees;
  final NumberFormat currency;
  final bool activeMine;
  final bool hasSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlight = activeMine
        ? scheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;
    final perUnit = currency.format(item.price);
    final lineTotal = currency.format(item.price * item.qty);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Material(
        color: highlight,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: hasSelected ? onTap : null,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: activeMine ? scheme.primary : scheme.outlineVariant,
                width: activeMine ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty
                            ? AppL10n.of(context).settlementMessageUnnamedItem
                            : item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.qty == item.qty.roundToDouble() ? item.qty.toStringAsFixed(0) : item.qty} × $perUnit',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: scheme.outline,
                        ),
                      ),
                      if (assignees.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _AvatarStack(participants: assignees)
                            .animate(key: ValueKey(assignees.length))
                            .fadeIn(duration: 180.ms)
                            .slideY(begin: 0.2, end: 0, duration: 180.ms),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  lineTotal,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}

class _AddPersonSheet extends ConsumerStatefulWidget {
  const _AddPersonSheet({
    required this.billId,
    required this.nameCtrl,
    required this.phoneCtrl,
  });

  final String billId;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  @override
  ConsumerState<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<_AddPersonSheet> {
  bool _importing = false;

  /// Participants already on the bill, read live so the suggestion filter
  /// never goes stale while the sheet is open.
  Set<String> get _excludeNames => <String>{
    for (final p
        in ref.watch(splitFamily(widget.billId)).value?.participants ??
            const <Participant>[])
      p.name.trim().toLowerCase(),
  };

  Future<void> _pickContact() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final picker = FlutterNativeContactPicker();
      final contact = await picker.selectPhoneNumber();
      if (contact == null || !mounted) return;
      final l10n = AppL10n.of(context);
      // Keep the raw text in the field for familiar display (`08…`);
      // normalization to `62…` happens once at save in `addParticipant`.
      final phone = contact.selectedPhoneNumber?.trim().isNotEmpty == true
          ? contact.selectedPhoneNumber!.trim()
          : null;
      final name = contact.fullName?.trim().isNotEmpty == true
          ? contact.fullName!.trim()
          : null;
      if (name == null && phone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.participantImportNoPhone)),
        );
        return;
      }
      // Fields already filled: ask before overwriting instead of silently
      // ignoring the picked contact.
      final needsConfirm =
          (name != null && widget.nameCtrl.text.trim().isNotEmpty) ||
          (phone != null && widget.phoneCtrl.text.trim().isNotEmpty);
      if (needsConfirm) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.billSplitOverwriteContactTitle),
            content: Text(l10n.billSplitOverwriteContactBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.billSplitOverwriteContactConfirm),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
      }
      setState(() {
        if (name != null) widget.nameCtrl.text = name;
        if (phone != null) widget.phoneCtrl.text = phone;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).participantImportFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h + viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.billSplitAddPersonTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: widget.nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.billSplitNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.phoneCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.participantPhoneLabel,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Semantics(
                    label: l10n.participantImportFromContacts,
                    child: IconButton(
                      icon: _importing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.contacts_outlined),
                      tooltip: l10n.participantImportFromContacts,
                      onPressed: _importing ? null : _pickContact,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ParticipantSuggestionChips(
                excludeNames: _excludeNames,
                onSelected: (participant) async {
                  // Don't silently discard what the user already typed.
                  if (widget.nameCtrl.text.trim().isNotEmpty ||
                      widget.phoneCtrl.text.trim().isNotEmpty) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          AppL10n.of(
                            ctx,
                          ).billSplitOverwriteContactTitle,
                        ),
                        content: Text(
                          AppL10n.of(
                            ctx,
                          ).billSplitOverwriteContactBody,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(AppL10n.of(ctx).cancelAction),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              AppL10n.of(
                                ctx,
                              ).billSplitOverwriteContactConfirm,
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !context.mounted) return;
                  }
                  // One-tap add: close the sheet with the suggestion's values
                  // instead of merely prefilling the form. Post-pop
                  // validation (empty/duplicate race) still toasts on the
                  // split screen via `_addParticipant`.
                  if (!context.mounted) return;
                  Navigator.of(context).pop((
                    name: participant.name,
                    phone: participant.phone.isEmpty ? null : participant.phone,
                  ));
                },
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancelAction),
                  ),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop((
                        name: widget.nameCtrl.text,
                        phone: widget.phoneCtrl.text.trim().isEmpty
                            ? null
                            : widget.phoneCtrl.text.trim(),
                      ));
                    },
                    child: Text(l10n.billSplitAdd),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.participants});

  final List<Participant> participants;

  @override
  Widget build(BuildContext context) {
    const visibleMax = 4;
    final shown = participants.take(visibleMax).toList(growable: false);
    final extra = participants.length - shown.length;
    const dim = 24.0;
    final overlap = 16.w;
    return SizedBox(
      height: dim.r,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: ParticipantAvatar(
                id: shown[i].id,
                name: shown[i].name,
                size: dim,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * overlap,
              child: Container(
                width: dim.r,
                height: dim.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.r),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticipantBar extends StatelessWidget {
  const _ParticipantBar({
    required this.participants,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Participant> participants;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<Participant> onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppL10n.of(context);
    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (participants.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 6.h),
                child: Semantics(
                  label: l10n.billSplitParticipantBarHint,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12.r,
                        color: scheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          l10n.billSplitParticipantBarHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: 108.h,
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Scrollable participants area — takes whatever space is left
              // after the pinned add button so it never pushes the button off
              // screen, regardless of participant count.
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
                  itemCount: participants.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, i) {
                    final p = participants[i];
                    final active = p.id == selectedId;
                    final avatar = ParticipantAvatar(
                      id: p.id,
                      name: p.name,
                      size: 52,
                      active: active,
                      onTap: () => onSelect(p.id),
                    );
                    return Center(
                      child: GestureDetector(
                        onLongPress: () => onRemove(p),
                        child: Semantics(
                          label: l10n.billSplitParticipantBarHint,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              active
                                  ? avatar
                                      .animate(
                                        key: ValueKey('avatar-${p.id}-active'),
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scaleXY(
                                        begin: 1.0,
                                        end: 1.06,
                                        duration: 700.ms,
                                        curve: Curves.easeInOut,
                                      )
                                  : avatar
                                      .animate(
                                        key: ValueKey('avatar-${p.id}-idle'),
                                      )
                                      .fadeIn(duration: 200.ms),
                              SizedBox(height: 4.h),
                              SizedBox(
                                width: 60.w,
                                child: Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Pinned divider + add button — always visible at the right
              // edge no matter how many participants exist.
              Container(width: 1, height: 64.h, color: scheme.outlineVariant),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: _AddButton(onTap: onAdd),
              ),
            ],
          ),
        ),
        ],
      ),
    ),
  );
}
  }

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dim = 52.r;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkResponse(
          onTap: onTap,
          radius: dim / 2 + 6,
          child: Container(
            width: dim,
            height: dim,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHighest,
              border: Border.all(
                color: scheme.outline,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1,
              color: scheme.primary,
              size: 22.r,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          AppL10n.of(context).billSplitAdd,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// Sticky CTA above the participant bar. Animates in only when every item is
/// assigned (`unassignedSubtotal == 0`). Hidden state collapses to zero height
/// so the bar below sits flush against the items list.
class _SummaryButton extends StatelessWidget {
  const _SummaryButton({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child:
          SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(AppL10n.of(context).billSplitViewSummary),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 220.ms)
              .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
