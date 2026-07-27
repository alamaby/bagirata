import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_messages.dart';
import '../widgets/auth_text_field.dart';

/// Form untuk set password baru setelah user klik link reset password di
/// email. Hanya reachable lewat redirect router saat
/// `AuthChangeEvent.passwordRecovery` aktif (lihat [app_router.dart]). Kalau
/// user nyasar ke sini tanpa sesi recovery (token sudah expired / redirect
/// di-refresh), router redirect akan mengarahkan ke `/login?reason=reset_expired`.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _saving = false;

  // Minimal 8 karakter dan harus mengandung minimal 1 huruf + 1 angka.
  static final _passwordPolicy = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{8,}$');

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    final l10n = AppL10n.of(context);
    final v = value ?? '';
    if (v.isEmpty) return l10n.resetPasswordNewLabel;
    if (v.length < 8) return l10n.resetPasswordMinChars;
    if (!_passwordPolicy.hasMatch(v)) {
      return l10n.resetPasswordNeedsAlphaDigit;
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final l10n = AppL10n.of(context);
    final v = value ?? '';
    if (v.isEmpty) return l10n.resetPasswordConfirmLabel;
    if (v != _newPassword.text) return l10n.resetPasswordMismatch;
    return null;
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.updatePassword(_newPassword.text);
    if (!mounted) return;
    setState(() => _saving = false);
    final l10n = AppL10n.of(context);
    switch (res) {
      case Success():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.resetPasswordSuccess),
              behavior: SnackBarBehavior.floating,
            ),
          );
        context.go(Routes.settings);
      case ResultFailure(:final failure):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(friendlyAuthMessage(failure, l10n)),
              behavior: SnackBarBehavior.floating,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Router is the single authority for recovery routing.
    // This screen assumes the router has already verified the recovery
    // session. If the token is invalid/expired, the router will bounce
    // to /login?reason=reset_expired before this screen renders.

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordScreenTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
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
                      Icons.lock_reset_outlined,
                      size: 48.r,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.resetPasswordScreenHeading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.resetPasswordScreenBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 32.h),
                AuthTextField(
                  controller: _newPassword,
                  label: l10n.resetPasswordNewLabel,
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: _validateNew,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: _confirmPassword,
                  label: l10n.resetPasswordConfirmLabel,
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirm,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.newPassword],
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(
                              scheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          l10n.resetPasswordSaveAction,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
