import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/app_format.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/participant.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shared/widgets/loading_view.dart';
import '../providers/split_notifier.dart';
import '../widgets/participant_avatar.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(splitFamily(billId));
    final currency = AppFormat.currency();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split bill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () => _exit(context, ref),
        ),
        actions: [
          TextButton(
            onPressed: () => _exit(context, ref),
            child: const Text('Selesai'),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const LoadingView(message: 'Loading…'),
          error: (e, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ),
          data: (state) => _SplitBody(
            state: state,
            billId: billId,
            currency: currency,
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

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addParticipant(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Tambah orang'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nama'),
            onSubmitted: (_) => Navigator.pop(ctx, ctrl.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) return;
    final err = await _notifier(ref).addParticipant(name);
    if (err != null && context.mounted) _toast(context, err);
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
        Expanded(
          child: state.items.isEmpty
              ? Center(
                  child: Text(
                    'Bill ini belum punya item.',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    final assignees = state.participants
                        .where((p) => state.assignments.any(
                              (a) =>
                                  a.itemId == item.id &&
                                  a.participantId == p.id,
                            ))
                        .toList(growable: false);
                    final isMine = state.selectedParticipantId != null &&
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
                        final err =
                            await _notifier(ref).toggleAssignment(item.id);
                        if (err != null && context.mounted) {
                          _toast(context, err);
                        }
                      },
                    );
                  },
                ),
        ),
        _SummaryButton(
          visible: state.unassignedSubtotal <= 0.0001 &&
              state.participants.isNotEmpty &&
              state.items.isNotEmpty,
          onTap: () => SplitSummarySheet.show(context, state),
        ),
        _ParticipantBar(
          participants: state.participants,
          selectedId: state.selectedParticipantId,
          onSelect: (id) => _notifier(ref).selectParticipant(id),
          onAdd: () => _addParticipant(context, ref),
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
            'Total tagihan',
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
                allAssigned
                    ? Icons.check_circle
                    : Icons.pending_outlined,
                size: 16.r,
                color: allAssigned
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
              SizedBox(width: 6.w),
              Text(
                allAssigned
                    ? 'Semua item sudah dibagi'
                    : 'Belum dibagi: ${currency.format(unassignedSubtotal)}',
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
                        item.name.isEmpty ? '(tanpa nama)' : item.name,
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
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
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
  });

  final List<Participant> participants;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 108.h,
          child: Row(
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
                    return Column(
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
                                .animate(key: ValueKey('avatar-${p.id}-idle'))
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
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Pinned divider + add button — always visible at the right
              // edge no matter how many participants exist.
              Container(
                width: 1,
                height: 64.h,
                color: scheme.outlineVariant,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: _AddButton(onTap: onAdd),
              ),
            ],
          ),
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
            child: Icon(Icons.person_add_alt_1,
                color: scheme.primary, size: 22.r),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Tambah',
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
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.receipt_long),
          label: const Text('Lihat Rincian'),
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
