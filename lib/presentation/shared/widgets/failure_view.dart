import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/error/failure.dart';

class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry});
  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              _label(failure),
              style: TextStyle(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }

  static String _label(Failure f) => switch (f) {
        NetworkFailure(:final message) => 'Network: $message',
        ServerFailure(:final message, :final code) =>
          'Server${code != null ? ' ($code)' : ''}: $message',
        ParsingFailure(:final message) => 'Could not parse response: $message',
        AuthFailure(:final message) => 'Auth: $message',
        UnknownFailure(:final error) => 'Unexpected: $error',
      };
}
