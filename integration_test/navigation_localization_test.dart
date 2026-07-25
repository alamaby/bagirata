import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final _selectedTabProvider = NotifierProvider<_SelectedTabNotifier, int>(
  _SelectedTabNotifier.new,
);

class _SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigates test tabs and switches localized labels', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: _HarnessApp()));

    expect(find.text('Halaman Pindai'), findsOneWidget);
    expect(find.text('Pindai'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Riwayat'), findsOneWidget);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Pengaturan'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('switch-language')));
    await tester.pumpAndSettle();
    expect(find.text('Settings page'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Scan page'), findsOneWidget);
  });
}

class _HarnessApp extends StatefulWidget {
  const _HarnessApp();

  @override
  State<_HarnessApp> createState() => _HarnessAppState();
}

class _HarnessAppState extends State<_HarnessApp> {
  Locale _locale = const Locale('id');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: _NavigationHarness(
        onSwitchLanguage: () => setState(() {
          _locale = _locale.languageCode == 'id'
              ? const Locale('en')
              : const Locale('id');
        }),
      ),
    );
  }
}

class _NavigationHarness extends ConsumerWidget {
  const _NavigationHarness({required this.onSwitchLanguage});

  final VoidCallback onSwitchLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final selectedTab = ref.watch(_selectedTabProvider);
    final pageNames = switch (l10n.localeName) {
      'en' => const ['Scan page', 'History page', 'Settings page'],
      _ => const ['Halaman Pindai', 'Halaman Riwayat', 'Halaman Pengaturan'],
    };

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const ValueKey('switch-language'),
            onPressed: onSwitchLanguage,
            tooltip: 'Switch language',
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Center(child: Text(pageNames[selectedTab])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: ref.read(_selectedTabProvider.notifier).select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            label: l10n.scanTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            label: l10n.historyTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
