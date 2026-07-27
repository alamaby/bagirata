import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import '../../domain/entities/auth_snapshot.dart';
import '../../domain/entities/ocr_result.dart';
import '../../presentation/auth/providers/auth_providers.dart';
import '../../presentation/auth/providers/pending_registration_executor.dart';
import '../../presentation/auth/screens/legal_acceptance_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/post_login_welcome_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/reset_password_screen.dart';
import '../../presentation/auth/screens/verify_email_screen.dart';
import '../../presentation/auth/screens/verify_otp_screen.dart';
import '../../presentation/bills/screens/bill_detail_screen.dart';
import '../../presentation/bills/screens/deleted_bills_screen.dart';
import '../../presentation/bills/screens/bill_review_screen.dart';
import '../../presentation/bills/screens/bill_split_screen.dart';
import '../../presentation/history/screens/history_screen.dart';
import '../../presentation/ocr/screens/receipt_capture_screen.dart';
import '../../presentation/about/screens/about_screen.dart';
import '../../presentation/about/screens/privacy_policy_screen.dart';
import '../../presentation/about/screens/terms_of_service_screen.dart';
import '../../presentation/onboarding/screens/onboarding_screen.dart';
import '../../presentation/settings/providers/profile_notifier.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/settings/screens/transfer_bank_info_screen.dart';
import '../../presentation/shell/screens/main_shell_screen.dart';
import '../error/result.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _AuthRefreshNotifier();
  ref.listen(authStateProvider, (_, _) => refresh.bump());
  // Also bump on app_config and profile changes so the legal-acceptance
  // gate re-evaluates as soon as the user accepts (profile) or the
  // operator bumps the legal doc version in `app_config`.
  ref.listen(appConfigProvider, (_, _) => refresh.bump());
  ref.listen(profileProvider, (_, _) => refresh.bump());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.scan,
    refreshListenable: refresh,
    redirect: (context, state) async {
      final rawLoc = state.uri.toString();
      final loc = state.matchedLocation;

      // ── Supabase email-link callback ──────────────────────────────────
      // Two entry points reach this block:
      //   1. App was cold-started by the deep link — GoRouter sees the
      //      full URI as the initial location.
      //   2. App was already running — DeepLinkHandler already called
      //      `getSessionFromUrl()`, but we still land here as a redirect
      //      target and need to route the user to the correct screen.
      //
      // Both rawUri patterns (fragment or query) are handled.
      final looksLikeCallback =
          loc == Routes.callback ||
          rawLoc.contains('access_token=') ||
          rawLoc.contains('refresh_token=') ||
          rawLoc.contains('code=') ||
          rawLoc.contains('type=email_change') ||
          rawLoc.contains('type=signup') ||
          rawLoc.contains('type=recovery') ||
          rawLoc.contains('error_description=');
      if (looksLikeCallback) {
        final isRecovery = rawLoc.contains('type=recovery');
        final result = await ref
            .read(authRepositoryProvider)
            .recoverSessionFromUri(state.uri);
        final recoveryFlagActive =
            ref.read(authRepositoryProvider).isPasswordRecovery;
        if (result is Success<void> || (isRecovery && recoveryFlagActive)) {
          // Apply any pending post-signup actions (marketing opt-in, welcome
          // marker) that were deferred from the register screen so they are
          // only written after the email is confirmed.
          if (!isRecovery) {
            await ref
                .read(pendingRegistrationExecutorProvider.notifier)
                .execute();
          }
          return isRecovery ? Routes.resetPassword : Routes.history;
        }
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

      // ── Password-recovery session ────────────────────────────────────
      // Single source of truth: persistent recovery flag from
      // PasswordRecoverySession (via IAuthRepository). The snapshot field
      // AuthSnapshot.isPasswordRecovery is NOT used for routing because it
      // can be stale (stream event already fired before ProviderScope mounted
      // on cold start, or stream event fires after redirect runs on warm start).
      // This gate must run BEFORE every other entry-point gate (legal,
      // onboarding, history paywall) so a user mid-recovery does not get
      // bounced to onboarding or paywall screens that would discard the
      // recovery session.
      final isRecoveryActive = ref.read(authRepositoryProvider).isPasswordRecovery;

      if (isRecoveryActive) {
        // Recovery session is active: user MUST be on /reset-password.
        if (loc != Routes.resetPassword) {
          return Routes.resetPassword;
        }
        // Already on /reset-password → no redirect, let the screen handle it.
      } else if (loc == Routes.resetPassword) {
        // No active recovery session but user is on /reset-password.
        // This happens when the token expired or someone navigated manually.
        // Bounce to login with expired reason.
        return '${Routes.login}?reason=reset_expired';
      }

      final goingToProtected = loc.startsWith(Routes.history);
      final onAuthScreen =
          loc == Routes.login ||
          loc == Routes.register ||
          loc == Routes.verifyEmail ||
          loc == Routes.verifyOtp;

      if (goingToProtected && !isSignedIn) {
        return '${Routes.login}?reason=save_history';
      }
      if (onAuthScreen && isSignedIn) {
        // Honor an explicit `from=<path>` (set by the paywall sheet so users
        // who triggered login from e.g. the Settings tab return there instead
        // of being bounced to /history).
        final from = state.uri.queryParameters['from'];
        if (from != null && from.isNotEmpty) return from;
        return Routes.history;
      }

      // ToS/PP acceptance gate. Skipped while the user is reading either
      // legal document (so a push to /terms-of-service or /privacy-policy
      // from inside the gate does not immediately pop them back).
      final cfg = switch (ref.read(appConfigProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final profile = switch (ref.read(profileProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final onLegalDocScreen =
          state.matchedLocation == Routes.termsOfService ||
          state.matchedLocation == Routes.privacyPolicy;
      if (cfg != null &&
          profile != null &&
          profile.id.isNotEmpty &&
          !onLegalDocScreen) {
        final needsAccept =
            profile.acceptedTermsVersion != cfg.termsVersion ||
            profile.acceptedPrivacyVersion != cfg.privacyVersion;
        if (needsAccept && state.matchedLocation != Routes.legalAcceptance) {
          final from = state.matchedLocation;
          return '${Routes.legalAcceptance}'
              '?from=${Uri.encodeQueryComponent(from)}';
        }

        // Post-login welcome (Google sign-in only). Email/password sign-up
        // defers `welcomed_at` until after email confirmation — the pending
        // registration executor stamps it in the callback, so the welcome
        // gate does not fire for freshly-confirmed email users.
        // Excluded from the legal-acceptance screen so a user mid-acceptance
        // is not bounced to the welcome screen.
        if (!profile.isAnonymous &&
            profile.welcomedAt == null &&
            state.matchedLocation != Routes.postLoginWelcome &&
            state.matchedLocation != Routes.legalAcceptance) {
          final from = state.matchedLocation;
          return '${Routes.postLoginWelcome}'
              '?from=${Uri.encodeQueryComponent(from)}';
        }

        // Onboarding gate. Shown after legal acceptance & post-login welcome.
        // Applies to anonymous users too (first app open).
        if (profile.onboardingCompletedAt == null &&
            state.matchedLocation != Routes.onboarding &&
            state.matchedLocation != Routes.legalAcceptance &&
            state.matchedLocation != Routes.postLoginWelcome) {
          return Routes.onboarding;
        }
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                name: Routes.settingsName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.transferBankInfo,
        name: Routes.transferBankInfoName,
        builder: (context, state) => const TransferBankInfoScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: Routes.resetPasswordName,
        builder: (context, state) => const ResetPasswordScreen(),
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
        path: Routes.deletedBills,
        name: Routes.deletedBillsName,
        builder: (context, state) => const DeletedBillsScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: Routes.onboardingName,
        builder: (context, state) => OnboardingScreen(
          isReplay: state.uri.queryParameters['mode'] == 'replay',
        ),
      ),
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) => LoginScreen(
          reason: state.uri.queryParameters['reason'],
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: Routes.register,
        name: Routes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        name: Routes.verifyEmailName,
        builder: (context, state) =>
            VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        name: Routes.verifyOtpName,
        builder: (context, state) => VerifyOtpScreen(
          email: state.uri.queryParameters['email'] ?? '',
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: Routes.about,
        name: Routes.aboutName,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        name: Routes.privacyPolicyName,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: Routes.termsOfService,
        name: Routes.termsOfServiceName,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: Routes.legalAcceptance,
        name: Routes.legalAcceptanceName,
        builder: (context, state) =>
            LegalAcceptanceScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.postLoginWelcome,
        name: Routes.postLoginWelcomeName,
        builder: (context, state) =>
            PostLoginWelcomeScreen(from: state.uri.queryParameters['from']),
      ),
      // Catch-all for Supabase email confirmation / password-reset deep
      // links. The redirect block above processes the session; this route
      // exists only so GoRouter doesn't 404 before the redirect fires.
      GoRoute(
        path: Routes.callback,
        name: Routes.callbackName,
        redirect: (context, state) => null,
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}
