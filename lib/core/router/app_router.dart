import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_snapshot.dart';
import '../../domain/entities/ocr_result.dart';
import '../../presentation/auth/providers/auth_providers.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/bills/screens/bill_list_screen.dart';
import '../../presentation/bills/screens/bill_review_screen.dart';
import '../../presentation/bills/screens/bill_split_screen.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/ocr/screens/receipt_capture_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _AuthRefreshNotifier();
  ref.listen(authStateProvider, (_, _) => refresh.bump());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.billList,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Treat unknown state (first frame before stream emits) as anonymous —
      // bootstrap signs in anonymously before runApp, so this fallback avoids
      // flashing a logged-in screen while the stream is still warming up.
      final snap = switch (ref.read(authStateProvider)) {
        AsyncData<AuthSnapshot>(:final value) => value,
        _ => null,
      };
      final isAnon = snap?.isAnonymous ?? true;
      final isSignedIn = snap?.userId != null && !isAnon;

      final loc = state.matchedLocation;
      final goingToProtected = loc == Routes.dashboard;
      final onAuthScreen = loc == Routes.login || loc == Routes.register;

      if (goingToProtected && !isSignedIn) {
        return '${Routes.login}?reason=save_history';
      }
      if (onAuthScreen && isSignedIn) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.billList,
        name: Routes.billListName,
        builder: (context, state) => const BillListScreen(),
      ),
      GoRoute(
        path: Routes.capture,
        name: Routes.captureName,
        builder: (context, state) => const ReceiptCaptureScreen(),
      ),
      GoRoute(
        path: Routes.billReview,
        name: Routes.billReviewName,
        builder: (context, state) =>
            BillReviewScreen(ocr: state.extra! as OcrResult),
      ),
      GoRoute(
        path: Routes.billSplit,
        name: Routes.billSplitName,
        builder: (context, state) =>
            BillSplitScreen(billId: state.pathParameters['billId']!),
      ),
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) =>
            LoginScreen(reason: state.uri.queryParameters['reason']),
      ),
      GoRoute(
        path: Routes.register,
        name: Routes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        name: Routes.dashboardName,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}
