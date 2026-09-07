class Routes {
  const Routes._();

  static const String scan = '/scan';
  static const String scanName = 'scan';

  static const String history = '/history';
  static const String historyName = 'history';

  static const String settings = '/settings';
  static const String settingsName = 'settings';
  static const String transferBankInfo = '/settings/transfer-bank';
  static const String transferBankInfoName = 'transfer-bank-info';

  /// Form untuk set password baru setelah user klik link di email
  /// password-reset. Hanya reachable via `AuthChangeEvent.passwordRecovery`.
  /// Jika user nyasar ke sini tanpa sesi recovery aktif, router redirect
  /// ke `/login?reason=reset_expired`.
  static const String resetPassword = '/reset-password';
  static const String resetPasswordName = 'reset-password';

  static const String capture = '/capture';
  static const String captureName = 'capture';

  static const String billReview = '/review';
  static const String billReviewName = 'bill-review';

  static const String billSplit = '/split/:billId';
  static const String billSplitName = 'bill-split';

  static const String billDetail = '/detail/:billId';
  static const String billDetailName = 'bill-detail';

  static const String deletedBills = '/deleted-bills';
  static const String deletedBillsName = 'deleted-bills';

  static const String login = '/login';
  static const String loginName = 'login';

  static const String register = '/register';
  static const String registerName = 'register';

  static const String verifyEmail = '/verify-email';
  static const String verifyEmailName = 'verify-email';

  static const String verifyOtp = '/verify-otp';
  static const String verifyOtpName = 'verify-otp';

  static const String about = '/about';
  static const String aboutName = 'about';

  static const String privacyPolicy = '/privacy-policy';
  static const String privacyPolicyName = 'privacy-policy';

  static const String termsOfService = '/terms-of-service';
  static const String termsOfServiceName = 'terms-of-service';

  /// First-run gate that requires the user to accept the current Terms of
  /// Service and Privacy Policy versions before any other route is
  /// reachable. Routed to by `appRouter.redirect` whenever
  /// `profile.acceptedTermsVersion` or `profile.acceptedPrivacyVersion` does
  /// not match `app_config.legal.terms_version` / `legal.privacy_version`.
  static const String legalAcceptance = '/legal-acceptance';
  static const String legalAcceptanceName = 'legal-acceptance';

  /// Catch-all route for Supabase email confirmation / password-reset
  /// deep-link callbacks (`bagistruk://auth/callback`).
  static const String callback = '/callback';
  static const String callbackName = 'callback';

  /// Public read-only bill view (`bagistruk://share/<token>`). No login wall
  /// and no legal/onboarding gates — viewers without an account must land
  /// here directly (exempted in the router redirect).
  static const String share = '/share/:token';
  static const String shareName = 'share';

  /// One-time screen shown after a non-anonymous user finishes the
  /// authentication flow (currently Google sign-in) to collect an explicit
  /// marketing email opt-in. Email/password sign-up collects the same
  /// opt-in on the register form and stamps `welcomed_at` after email
  /// confirmation through the pending registration executor, so the
  /// welcome screen only fires for users who skipped the register form.
  static const String postLoginWelcome = '/post-login-welcome';
  static const String postLoginWelcomeName = 'post-login-welcome';

  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';
}
