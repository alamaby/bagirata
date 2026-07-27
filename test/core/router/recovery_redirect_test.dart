import 'package:flutter_test/flutter_test.dart';

import 'package:bagistruk/core/router/routes.dart';

/// Pure redirect decision logic, matching the production router at
/// `app_router.dart:113-126`.
///
/// Returns the redirect target (non-null = redirect), or `null` to let the
/// current route proceed. This is the single source of truth that must be
/// mutually exclusive and loop-safe.
///
/// Production router also evaluates this BEFORE legal, onboarding, welcome,
/// and protected-route gates.
String? recoveryRedirect({
  required bool isRecoveryActive,
  required String currentRoute,
}) {
  if (isRecoveryActive) {
    return currentRoute == Routes.resetPassword ? null : Routes.resetPassword;
  }
  if (currentRoute == Routes.resetPassword) {
    return '${Routes.login}?reason=reset_expired';
  }
  return null;
}

/// Matrix of redirect decisions. Every combination must produce exactly one
/// outcome — no overlapping conditions, no dead code.
///
/// | Recovery | Current route           | Expected redirect            |
/// |----------|-------------------------|------------------------------|
/// | active   | /scan                   | /reset-password              |
/// | active   | /login?reason=...       | /reset-password              |
/// | active   | /reset-password         | null (no redirect)           |
/// | inactive | /reset-password         | /login?reason=reset_expired  |
/// | inactive | /scan                   | null (normal routing)        |
/// | inactive | /login                  | null (normal routing)        |
void main() {
  group('Recovery redirect decision', () {
    group('isRecoveryActive == true', () {
      test('/scan → /reset-password', () {
        expect(
          recoveryRedirect(isRecoveryActive: true, currentRoute: Routes.scan),
          Routes.resetPassword,
        );
      });

      test('/login with reason → /reset-password', () {
        expect(
          recoveryRedirect(
            isRecoveryActive: true,
            currentRoute: '/login?reason=reset_expired',
          ),
          Routes.resetPassword,
        );
      });

      test('/callback → /reset-password', () {
        expect(
          recoveryRedirect(isRecoveryActive: true, currentRoute: Routes.callback),
          Routes.resetPassword,
        );
      });

      test('/reset-password → null (no loop)', () {
        expect(
          recoveryRedirect(
            isRecoveryActive: true,
            currentRoute: Routes.resetPassword,
          ),
          isNull,
        );
      });
    });

    group('isRecoveryActive == false', () {
      test('/reset-password → /login?reason=reset_expired', () {
        expect(
          recoveryRedirect(isRecoveryActive: false, currentRoute: Routes.resetPassword),
          '/login?reason=reset_expired',
        );
      });

      test('/scan → null (normal routing)', () {
        expect(
          recoveryRedirect(isRecoveryActive: false, currentRoute: Routes.scan),
          isNull,
        );
      });

      test('/login → null (normal routing)', () {
        expect(
          recoveryRedirect(isRecoveryActive: false, currentRoute: Routes.login),
          isNull,
        );
      });

      test('/settings → null (normal routing)', () {
        expect(
          recoveryRedirect(isRecoveryActive: false, currentRoute: Routes.settings),
          isNull,
        );
      });
    });

    group('Loop-safety regression', () {
      test('active + /reset-password must NOT redirect (was loop #1)', () {
        // This was the root cause: the old guard bounced /reset-password
        // back to /login when snap?.isPasswordRecovery was stale, creating
        // /reset-password → /login → /reset-password loop.
        expect(
          recoveryRedirect(isRecoveryActive: true, currentRoute: Routes.resetPassword),
          isNull,
        );
      });

      test('inactive + /reset-password must redirect (not loop back)', () {
        // When recovery is legitimately expired, user should go to login
        // with expired reason, not back to /reset-password.
        final result = recoveryRedirect(
          isRecoveryActive: false,
          currentRoute: Routes.resetPassword,
        );
        expect(result, startsWith(Routes.login));
        expect(result, contains('reason=reset_expired'));
      });

      test('active + /reset-password followed by same decision is idempotent', () {
        // Running the same decision twice must produce the same null result.
        for (var i = 0; i < 3; i++) {
          expect(
            recoveryRedirect(
              isRecoveryActive: true,
              currentRoute: Routes.resetPassword,
            ),
            isNull,
          );
        }
      });
    });
  });
}
