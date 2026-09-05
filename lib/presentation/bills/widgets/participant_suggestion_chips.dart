import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/saved_participant.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/saved_participants_notifier.dart';
import 'participant_avatar.dart';

class ParticipantSuggestionChips extends ConsumerWidget {
  const ParticipantSuggestionChips({
    super.key,
    required this.onSelected,
    this.excludeNames = const {},
  });

  final ValueChanged<SavedParticipant> onSelected;

  /// Lowercased participant names already on the bill — hidden so the user
  /// cannot re-add someone twice.
  final Set<String> excludeNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedParticipantsProvider);
    final all = async.value ?? const <SavedParticipant>[];
    final suggestions = all
        .where((p) => !excludeNames.contains(p.name.trim().toLowerCase()))
        .toList(growable: false);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppL10n.of(context).participantSuggestionTitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 74.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final p = suggestions[index];
                  return _SuggestionChip(
                    participant: p,
                    onTap: () => onSelected(p),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        )
        .animate()
        .fadeIn(duration: 180.ms)
        .slideY(begin: 0.08, end: 0, duration: 180.ms);
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.participant, required this.onTap});

  final SavedParticipant participant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: 86.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ParticipantAvatar(
                id: '${participant.name}-${participant.phone}',
                name: participant.name,
                size: 34,
              ),
              SizedBox(height: 5.h),
              Text(
                participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
              if (participant.phone.isNotEmpty)
                Text(
                  participant.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
