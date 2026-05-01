import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_snapshot.dart';
import '../../domain/entities/ocr_result.dart';
import '../../presentation/auth/providers/auth_providers.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/verify_email_screen.dart';
import '../../presentation/bills/screens/bill_detail_screen.dart';
import '../../presentation/bills/screens/bill_review_screen.dart';
import '../../presentation/bills/screens/bill_split_screen.dart';
import '../../presentation/history/screens/history_screen.dart';
import '../../presentation/ocr/screens/receipt_capture_screen.dart';
import '../../presentation/shell/screens/main_shell_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _AuthRefreshNotifier();
  ref.listen(authStateProvider, (_, _) => refresh.bump());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.scan,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Supabase email-link callback. The provider redirects to the app's Site
      // URL with `#access_token=...&type=email_change` (or signup/recovery).
      // supabase_flutter parses the fragment automatically and updates the
      // session; we just need to land the user on a real route. The next
      // redirect tick will then push them to /history because auth state is
      // signed-in.
      final rawLoc = state.uri.toString();
      if (rawLoc.contains('access_token=') ||
          rawLoc.contains('type=email_change') ||
          rawLoc.contains('type=signup') ||
          rawLoc.contains('type=recovery')) {
        return Routes.scan;
      }

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
      final goingToProtected = loc.startsWith(Routes.history);
      final onAuthScreen = loc == Routes.login ||
          loc == Routes.register ||
          loc == Routes.verifyEmail;

      if (goingToProtected && !isSignedIn) {
        return '${Routes.login}?reason=save_history';
      }
      if (onAuthScreen && isSignedIn) {
        return Routes.history;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.scan,
                name: Routes.scanName,
                builder: (context, state) => const ReceiptCaptureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                name: Routes.historyName,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
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
        path: Routes.billDetail,
        name: Routes.billDetailName,
        builder: (context, state) =>
            BillDetailScreen(billId: state.pathParameters['billId']!),
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
        path: Routes.verifyEmail,
        name: Routes.verifyEmailName,
        builder: (context, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}
