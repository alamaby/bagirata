import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shell/widgets/paywall_bottom_sheet.dart';
import '../providers/profile_notifier.dart';
import '../providers/settings_actions.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/currency_picker_dialog.dart';
import '../widgets/edit_name_sheet.dart';
import '../widgets/language_picker_dialog.dart';
import '../widgets/theme_picker_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final authSnap = switch (ref.watch(authStateProvider)) {
      AsyncData<AuthSnapshot>(:final value) => value,
      _ => null,
    };

    // No session at all (cold start before lazy anon kicks in). Mirror the
    // dashboard tab's pattern: show the paywall sheet inviting register/login
    // rather than a generic error. Once a session exists (anon or email) the
    // normal settings body renders.
    if (authSnap?.userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: _NoSessionView(
          onTap: () => showPaywallSheet(context, from: Routes.settings),
        ),
      );
    }

    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: l10n.errorGeneric,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => _SettingsBody(profile: profile),
      ),
    );
  }
}

class _NoSessionView extends StatefulWidget {
  const _NoSessionView({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NoSessionView> createState() => _NoSessionViewState();
}

class _NoSessionViewState extends State<_NoSessionView> {
  @override
  void initState() {
    super.initState();
    // Auto-open the paywall on first frame so the user sees the register/login
    // prompt immediately, matching the dashboard tab's UX. Tapping the
    // placeholder button reopens it in case the user dismisses the sheet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48.r,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.noSessionMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: widget.onTap,
              child: Text(l10n.registerOrLogin),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final isAnon = profile.isAnonymous;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        _SectionHeader(l10n.accountSection),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(
            profile.displayName?.trim().isNotEmpty == true
                ? profile.displayName!
                : l10n.displayNameFallback,
          ),
          subtitle: Text(
            isAnon ? l10n.guestAccount : (profile.email ?? '—'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(l10n.changeName),
          onTap: () => _onChangeName(context, ref),
        ),
        if (!isAnon)
          ListTile(
            leading: const Icon(Icons.lock_reset_outlined),
            title: Text(l10n.resetPassword),
            onTap: () => _onResetPassword(context, ref, profile.email ?? ''),
          ),
        const Divider(),
        _SectionHeader(l10n.preferencesSection),
        ListTile(
          leading: const Icon(Icons.payments_outlined),
          title: Text(l10n.currencyLabel),
          trailing: Text(
            profile.defaultCurrency,
            style: theme.textTheme.bodyMedium,
          ),
          onTap: () => _onPickCurrency(context, ref, profile.defaultCurrency),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.languageLabel),
          trailing: Text(
            profile.languagePref.toUpperCase(),
            style: theme.textTheme.bodyMedium,
          ),
          onTap: () => _onPickLanguage(context, ref, profile.languagePref),
        ),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: Text(l10n.themeLabel),
          trailing: Text(
            _themeLabel(l10n, profile.themePref),
            style: theme.textTheme.bodyMedium,
          ),
          onTap: () => _onPickTheme(context, ref, profile.themePref),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: isAnon
              ? FilledButton.icon(
                  icon: const Icon(Icons.person_add_alt_1),
                  onPressed: () => context.pushNamed(Routes.registerName),
                  label: Text(l10n.registerPermanent),
                )
              : FilledButton.icon(
                  icon: const Icon(Icons.logout),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                  onPressed: () => _onLogout(context, ref),
                  label: Text(l10n.logout),
                ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  String _themeLabel(AppL10n l10n, String pref) => switch (pref) {
        'light' => l10n.themeLight,
        'dark' => l10n.themeDark,
        _ => l10n.themeSystem,
      };

  Future<void> _onChangeName(BuildContext context, WidgetRef ref) async {
    final next = await showEditNameSheet(context, profile.displayName ?? '');
    if (next == null || next.trim().isEmpty) return;
    final res = await ref
        .read(profileProvider.notifier)
        .updateDisplayName(next);
    if (!context.mounted) return;
    if (res is ResultFailure<void>) _snack(context, AppL10n.of(context).errorGeneric);
  }

  Future<void> _onResetPassword(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) async {
    final l10n = AppL10n.of(context);
    if (email.isEmpty) return;
    final ok = await showConfirmDialog(
      context,
      title: l10n.resetPasswordConfirmTitle,
      body: l10n.resetPasswordConfirmBody(email),
      confirmLabel: l10n.saveAction,
    );
    if (ok != true || !context.mounted) return;
    final res =
        await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
    if (!context.mounted) return;
    _snack(
      context,
      res is Success<void> ? l10n.resetPasswordSent : l10n.errorGeneric,
    );
  }

  Future<void> _onPickCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final code = await showCurrencyPickerDialog(context, current);
    if (code == null || code == current) return;
    final res =
        await ref.read(profileProvider.notifier).updateCurrency(code);
    if (!context.mounted) return;
    if (res is ResultFailure<void>) _snack(context, AppL10n.of(context).errorGeneric);
  }

  Future<void> _onPickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final code = await showLanguagePickerDialog(context, current);
    if (code == null || code == current) return;
    final res =
        await ref.read(profileProvider.notifier).updateLanguage(code);
    if (!context.mounted) return;
    if (res is ResultFailure<void>) _snack(context, AppL10n.of(context).errorGeneric);
  }

  Future<void> _onPickTheme(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final mode = await showThemePickerDialog(context, current);
    if (mode == null || mode == current) return;
    final res =
        await ref.read(profileProvider.notifier).updateTheme(mode);
    if (!context.mounted) return;
    if (res is ResultFailure<void>) _snack(context, AppL10n.of(context).errorGeneric);
  }

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.confirmLogoutTitle,
      body: l10n.confirmLogoutBody,
      confirmLabel: l10n.logout,
      destructive: true,
    );
    if (ok != true || !context.mounted) return;
    await performLogout(ref);
    // Router redirect handles navigation back to /scan when authState emits.
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          SizedBox(height: 12.h),
          Text(message),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppL10n.of(context).retry),
          ),
        ],
      ),
    );
  }
}

