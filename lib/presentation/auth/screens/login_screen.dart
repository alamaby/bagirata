import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../utils/auth_messages.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.reason});

  final String? reason;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.signInWithPassword(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    switch (res) {
      case Success():
        context.go(Routes.dashboard);
      case ResultFailure(:final failure):
        _showError(friendlyAuthMessage(failure));
    }
  }

  Future<void> _googleSignIn() async {
    if (_loading) return;
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.signInWithGoogle();
    if (!mounted) return;
    if (res case ResultFailure(:final failure)) {
      _showError(friendlyAuthMessage(failure));
    }
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
              Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer, fontSize: 13.sp),
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
    final scheme = Theme.of(context).colorScheme;
    final showSaveBanner = widget.reason == 'save_history';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              children: [
                if (showSaveBanner) ...[
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_outline, color: Color(0xFFFFA726)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Daftar untuk menyimpan riwayat tagihanmu',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
                SizedBox(height: 16.h),
                Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Masuk untuk melanjutkan ke BagiStruk.',
                  style: TextStyle(fontSize: 14.sp, color: scheme.onSurfaceVariant),
                ),
                SizedBox(height: 32.h),
                AuthTextField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  hint: 'kamu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: validatePassword,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                          ),
                        )
                      : Text(
                          'Masuk',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(child: Divider(color: scheme.outlineVariant)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'atau',
                        style: TextStyle(fontSize: 12.sp, color: scheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Divider(color: scheme.outlineVariant)),
                  ],
                ),
                SizedBox(height: 20.h),
                GoogleSignInButton(
                  enabled: !_loading,
                  onPressed: _googleSignIn,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(fontSize: 13.sp, color: scheme.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: _loading ? null : () => context.go(Routes.register),
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
