import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reproducible color + initials avatar for a participant.
///
/// Color is derived from a stable hash of the id so the same person keeps
/// the same color across rebuilds and even cold app launches.
class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    super.key,
    required this.id,
    required this.name,
    this.size = 44,
    this.active = false,
    this.onTap,
  });

  final String id;
  final String name;
  final double size;
  final bool active;
  final VoidCallback? onTap;

  static const _palette = <Color>[
    Color(0xFF6C9A8B),
    Color(0xFFE07A5F),
    Color(0xFF81B29A),
    Color(0xFF3D5A80),
    Color(0xFFEE6C4D),
    Color(0xFF8E7DBE),
    Color(0xFFD4A373),
    Color(0xFF5A8C7B),
    Color(0xFFC97B84),
    Color(0xFF4F8FBA),
  ];

  static Color colorFor(String key) {
    var h = 0;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palette[h % _palette.length];
  }

  static String initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(id);
    final dim = size.r;
    final scheme = Theme.of(context).colorScheme;
    final widget = Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: active
            ? Border.all(color: scheme.primary, width: 3.r)
            : Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.r),
        boxShadow: active
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initialsFor(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: (size * 0.38).sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (onTap == null) return widget;
    return GestureDetector(onTap: onTap, child: widget);
  }
}
