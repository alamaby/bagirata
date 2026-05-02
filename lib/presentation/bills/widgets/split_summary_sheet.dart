import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/app_format.dart';
import '../../../domain/entities/participant.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/split_notifier.dart';
import 'participant_avatar.dart';

/// Bottom-sheet summary listing per-participant items, proportional tax/
/// service, and total. Each row has a "Bagikan ke WhatsApp" button that opens
/// `wa.me/?text=...` with a pre-formatted breakdown.
class SplitSummarySheet extends StatelessWidget {
  const SplitSummarySheet({super.key, required this.state});

  final SplitState state;

  static Future<void> show(BuildContext context, SplitState state) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => SplitSummarySheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = AppFormat.currency();
    final totals = state.calculateTotals();
    final byId = {for (final t in totals) t.participantId: t};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        child: ListView(
          controller: scrollCtrl,
          children: [
            Text(
              l10n.splitSummaryTitle,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              state.bill.title,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            SizedBox(height: 16.h),
            for (final p in state.participants)
              _ParticipantSummaryCard(
                participant: p,
                items: state.itemsForParticipant(p.id),
                total: byId[p.id]!,
                bill: state,
                currency: currency,
                l10n: l10n,
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantSummaryCard extends StatelessWidget {
  const _ParticipantSummaryCard({
    required this.participant,
    required this.items,
    required this.total,
    required this.bill,
    required this.currency,
    required this.l10n,
  });

  final Participant participant;
  final List<ParticipantItemShare> items;
  final ParticipantTotal total;
  final SplitState bill;
  final NumberFormat currency;
  final AppL10n l10n;

  String _buildShareText() {
    final buf = StringBuffer();
    buf.writeln('*Rincian ${bill.bill.title}*');
    buf.writeln('Untuk: ${participant.name}');
    buf.writeln('');
    if (items.isEmpty) {
      buf.writeln('_Tidak ada item._');
    } else {
      buf.writeln('*Item:*');
      for (final s in items) {
        final name = s.item.name.isEmpty ? '(tanpa nama)' : s.item.name;
        final shareNote =
            s.sharedWith > 1 ? ' (dibagi ${s.sharedWith})' : '';
        buf.writeln('• $name$shareNote — ${currency.format(s.share)}');
      }
    }
    buf.writeln('');
    buf.writeln('Subtotal: ${currency.format(total.subtotal)}');
    if (total.tax > 0) buf.writeln('Pajak: ${currency.format(total.tax)}');
    if (total.service > 0) {
      buf.writeln('Service: ${currency.format(total.service)}');
    }
    buf.writeln('*Total: ${currency.format(total.total)}*');
    return buf.toString();
  }

  Future<void> _shareWhatsapp(BuildContext context) async {
    final text = Uri.encodeComponent(_buildShareText());
    final uri = Uri.parse('https://wa.me/?text=$text');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.splitWhatsappFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ParticipantAvatar(
                id: participant.id,
                name: participant.name,
                size: 40,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  participant.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                currency.format(total.total),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                l10n.splitSummaryNoItems,
                style: TextStyle(fontSize: 13.sp, color: scheme.outline),
              ),
            )
          else
            for (final s in items)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.item.name.isEmpty ? '(tanpa nama)' : s.item.name,
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    if (s.sharedWith > 1)
                      Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Text(
                          '÷${s.sharedWith}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    Text(
                      currency.format(s.share),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          if (total.tax > 0 || total.service > 0) ...[
            SizedBox(height: 8.h),
            Divider(height: 1, color: scheme.outlineVariant),
            SizedBox(height: 8.h),
            _SummaryLine(
              label: l10n.splitSummarySubtotal,
              value: currency.format(total.subtotal),
            ),
            if (total.tax > 0)
              _SummaryLine(
                label: l10n.splitSummaryTax,
                value: currency.format(total.tax),
              ),
            if (total.service > 0)
              _SummaryLine(
                label: l10n.splitSummaryService,
                value: currency.format(total.service),
              ),
          ],
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _shareWhatsapp(context),
              icon: const Icon(Icons.share),
              label: Text(l10n.splitSummaryShareWhatsapp),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF128C7E),
                minimumSize: Size.fromHeight(40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
