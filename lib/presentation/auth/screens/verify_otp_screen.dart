import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../settings/providers/preferences_providers.dart';
import '../utils/auth_messages.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, required this.email, this.from});

  final String email;
  final String? from;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const int _otpLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  Timer? _timer;
  bool _verifying = false;
  bool _resending = false;
  int _cooldown = 60;

  bool get _busy => _verifying || _resending;

  @override
  void initState() {
    super.initState();
    _startCooldown(rebuild: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _startCooldown({bool rebuild = true}) {
    _timer?.cancel();
    if (rebuild) {
      setState(() => _cooldown = 60);
    } else {
      _cooldown = 60;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
        return;
      }
      setState(() => _cooldown--);
    });
  }

  Future<void> _verify() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _verifying = true);
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.verifyEmailOtp(
      email: widget.email,
      token: _otp.text.trim(),
    );
    if (!mounted) return;
    setState(() => _verifying = false);

    switch (res) {
      case Success():
        context.go(widget.from ?? Routes.history);
      case ResultFailure(:final failure):
        _showError(friendlyAuthMessage(failure, AppL10n.of(context)));
    }
  }

  Future<void> _resend() async {
    if (_busy || _cooldown > 0) return;

    setState(() => _resending = true);
    final repo = ref.read(authRepositoryProvider);
    final languageCode = ref.read(localePrefProvider).languageCode;
    final res = await repo.sendEmailOtp(
      email: widget.email,
      languageCode: languageCode,
    );
    if (!mounted) return;
    setState(() => _resending = false);

    final l10n = AppL10n.of(context);
    switch (res) {
      case Success():
        _startCooldown();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.verifyOtpResent),
              behavior: SnackBarBehavior.floating,
            ),
          );
      case ResultFailure(:final failure):
        _showError(friendlyAuthMessage(failure, AppL10n.of(context)));
    }
  }

  String? _validateOtp(String? value) {
    final code = value?.trim() ?? '';
    if (code.length != _otpLength) return AppL10n.of(context).verifyOtpInvalid;
    return null;
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: scheme.onErrorContainer,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final resendLabel = _cooldown > 0
        ? l10n.verifyOtpResendCountdown(_cooldown)
        : l10n.verifyOtpResend;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyOtpTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
                    Icons.pin_outlined,
                    size: 48.r,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.verifyOtpHeading,
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
                    TextSpan(text: l10n.verifyOtpBodyPrefix),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    TextSpan(text: l10n.verifyOtpBodySuffix),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              TextFormField(
                controller: _otp,
                enabled: !_busy,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                validator: _validateOtp,
                onFieldSubmitted: (_) => _verify(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_otpLength),
                ],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: '00000000',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: _busy ? null : _verify,
                child: _verifying
                    ? SizedBox(
                        height: 20.r,
                        width: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                        ),
                      )
                    : Text(
                        l10n.verifyOtpButton,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: _busy || _cooldown > 0 ? null : _resend,
                icon: _resending
                    ? SizedBox(
                        height: 16.r,
                        width: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _resending ? l10n.verifyOtpResending : resendLabel,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => context.go(
                        Uri(
                          path: Routes.login,
                          queryParameters: {
                            if (widget.from != null && widget.from!.isNotEmpty)
                              'from': widget.from!,
                          },
                        ).toString(),
                      ),
                child: Text(
                  l10n.verifyOtpUseDifferent,
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
