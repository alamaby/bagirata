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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
    final res = await repo.signUp(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    switch (res) {
      case Success():
        final email = Uri.encodeQueryComponent(_email.text.trim());
        context.go('${Routes.verifyEmail}?email=$email');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali ke Scan',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.scan);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(Routes.scan),
            child: const Text('Lewati'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              children: [
                SizedBox(height: 16.h),
                Text(
                  'Buat akun baru',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Simpan riwayat tagihanmu di semua perangkat.',
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
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  hint: 'Minimal 6 karakter',
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: validatePassword,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.newPassword],
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
                          'Daftar',
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
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 13.sp, color: scheme.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: _loading ? null : () => context.go(Routes.login),
                      child: Text(
                        'Login',
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
