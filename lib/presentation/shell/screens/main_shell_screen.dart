import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../auth/providers/auth_providers.dart';
import '../widgets/paywall_bottom_sheet.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int _historyIndex = 1;
  static const int _settingsIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onSelect(context, ref, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: l10n.scanTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.historyTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }

  void _onSelect(BuildContext context, WidgetRef ref, int index) {
    if (index == _historyIndex && !_isSignedIn(ref)) {
      showPaywallSheet(context);
      return;
    }
    // Settings only needs *some* session (anon is fine — anon users see the
    // "Daftar Akun Permanen" CTA). On a true cold start (no anon session yet)
    // the profile fetch would fail; show the paywall instead.
    if (index == _settingsIndex && !_hasSession(ref)) {
      showPaywallSheet(context, from: Routes.settings);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  AuthSnapshot? _snapshot(WidgetRef ref) => switch (ref.read(authStateProvider)) {
        AsyncData<AuthSnapshot>(:final value) => value,
        _ => null,
      };

  bool _isSignedIn(WidgetRef ref) {
    final snap = _snapshot(ref);
    return snap?.userId != null && !(snap?.isAnonymous ?? true);
  }

  bool _hasSession(WidgetRef ref) => _snapshot(ref)?.userId != null;
}
