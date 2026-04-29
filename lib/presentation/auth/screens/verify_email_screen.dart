import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../utils/auth_messages.dart';

/// Shown after `signUp` while waiting for the user to click the email link.
///
/// Anonymous-user upgrade keeps `is_anonymous = true` and the new email in the
/// `email_change` field until the link is clicked. We park the user here so
/// they don't get the misleading "logged in" UX, then auto-route to /history
/// when [authStateProvider] flips to signed-in (handled by router redirect).
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _resending = false;

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.resendEmailChange(email: widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    switch (res) {
      case Success():
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Email verifikasi sudah dikirim ulang.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case ResultFailure(:final failure):
        messenger.showSnackBar(
          SnackBar(
            content: Text(friendlyAuthMessage(failure)),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _cancel() async {
    // User changed their mind — sign out the partial upgrade and start fresh
    // anonymous so they can re-enter the register form with a different email.
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    await repo.signInAnonymously();
    if (!mounted) return;
    context.go(Routes.scan);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 48.r,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Cek email kamu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Kami sudah mengirim link konfirmasi ke ',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Klik link itu untuk mengaktifkan akunmu — sampai itu kamu belum bisa login dari perangkat lain.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: scheme.primary, size: 20.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Setelah konfirmasi, kamu otomatis dipindahkan ke Riwayat.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              OutlinedButton.icon(
                onPressed: _resending ? null : _resend,
                icon: _resending
                    ? SizedBox(
                        height: 16.r,
                        width: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _resending ? 'Mengirim…' : 'Kirim ulang email',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: _cancel,
                child: Text(
                  'Pakai email lain',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
