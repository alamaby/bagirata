import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../shared/widgets/app_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final repo = ref.read(authRepositoryProvider);
            await repo.signOut();
            await repo.signInAnonymously();
            if (!context.mounted) return;
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Kamu sudah keluar.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go(Routes.billList);
          },
        ),
      ],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard_outlined, size: 64.r, color: scheme.primary),
              SizedBox(height: 16.h),
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                'Fitur premium akan segera hadir di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: scheme.onSurfaceVariant),
              ),
              SizedBox(height: 24.h),
              FilledButton.tonal(
                onPressed: () => context.go(Routes.billList),
                child: const Text('Kembali ke daftar tagihan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
