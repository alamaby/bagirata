import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';

/// [from] — optional path to return to after the user successfully signs in
/// from this sheet. When omitted, login lands on `/history` (legacy default
/// for the Riwayat paywall flow).
Future<void> showPaywallSheet(BuildContext context, {String? from}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => _PaywallSheet(from: from),
  );
}

class _PaywallSheet extends StatelessWidget {
  const _PaywallSheet({this.from});

  final String? from;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_outline,
                  size: 36.r,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Simpan riwayat & lacak piutang',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Daftar atau masuk untuk menyimpan riwayat dan melacak piutangmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                final fromQ =
                    from != null ? '?from=${Uri.encodeComponent(from!)}' : '';
                context.push('${Routes.register}$fromQ');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text(
                  'Daftar',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final fromQ = from != null
                    ? '&from=${Uri.encodeComponent(from!)}'
                    : '';
                context.push('${Routes.login}?reason=save_history$fromQ');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text(
                  'Masuk',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
