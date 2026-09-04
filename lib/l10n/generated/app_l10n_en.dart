// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get registerMarketingOptIn =>
      'I want to receive promotional emails, feature updates, and tips from BagiStruk.';

  @override
  String get postLoginWelcomeTitle => 'Welcome to BagiStruk!';

  @override
  String get postLoginWelcomeBody =>
      'Let us know if you want to receive promotional emails, feature updates, and tips from us. You can change this any time from Settings.';

  @override
  String get postLoginWelcomeOptIn =>
      'Send me promotional emails, feature updates, and tips.';

  @override
  String get postLoginWelcomeContinue => 'Continue';

  @override
  String get postLoginWelcomeErrorSave => 'Failed to save. Please try again.';

  @override
  String get registerErrorSaveProfile =>
      'Your account was created but we could not save your preferences. Please try again from Settings after verifying your email.';

  @override
  String get settingsMarketingOptIn => 'Promotional emails';

  @override
  String get settingsMarketingOptInSubtitle =>
      'Tips, feature updates, and offers from BagiStruk.';

  @override
  String get settingsMarketingOptInWebHint =>
      'You can also manage this preference from the BagiStruk website.';

  @override
  String get settingsTitle => 'Profile & Settings';

  @override
  String get settingsTab => 'Settings';

  @override
  String get scanTab => 'Scan';

  @override
  String get historyTab => 'History';

  @override
  String get scanScreenTitle => 'Scan Receipt';

  @override
  String get scanAddPhotos => 'Add Photos';

  @override
  String get scanAction => 'Scan';

  @override
  String get scanInProgress => 'Scanning…';

  @override
  String get scanSourceSheetTitle => 'Add receipt photo';

  @override
  String get scanSourceCamera => 'Camera';

  @override
  String get scanSourceGallery => 'Gallery';

  @override
  String get scanCameraContinuePrompt =>
      'Take another photo for this long receipt?';

  @override
  String get scanCameraTakeAnother => 'Take another';

  @override
  String get scanCameraDone => 'Done';

  @override
  String shareImagesAdded(int count) {
    return '$count shared photo(s) added. Starting scan...';
  }

  @override
  String get scanNotReceiptTitle => 'Not a receipt';

  @override
  String get scanNotReceiptHint =>
      'The selected image doesn\'t look like a receipt. Try a clear photo of a receipt.';

  @override
  String scanPreparingSessionFailed(String message) {
    return 'Could not prepare session: $message';
  }

  @override
  String scanCreditCheckFailed(String message) {
    return 'Could not check scan credits: $message';
  }

  @override
  String scanCreditCostWithBalance(
    int imageCount,
    int creditCost,
    int balance,
  ) {
    return '$imageCount photo(s) will use $creditCost credit(s). Balance: $balance.';
  }

  @override
  String scanCreditRequired(int requiredCredits, int balance) {
    return 'This scan needs $requiredCredits credit(s). Current balance: $balance.';
  }

  @override
  String get scanNoCreditAnonymousTitle => 'Free scan limit reached';

  @override
  String get scanNoCreditFreeTitle => 'This month\'s scan credits are used up';

  @override
  String get scanNoCreditAnonymousBody =>
      'You have used 5 scan credits as a guest. Create an account to get 20 free credits every month.';

  @override
  String scanNoCreditPlusBody(int monthlyAllowance) {
    return 'You have used $monthlyAllowance Plus credits this month. Credits will be available again in the next period.';
  }

  @override
  String scanNoCreditFreeBody(int monthlyAllowance) {
    return 'You have used $monthlyAllowance free credits this month. Upgrade to Plus for 60 credits/month, no ads, and Plus features.';
  }

  @override
  String get scanNoCreditLater => 'Later';

  @override
  String get scanNoCreditRegister => 'Sign Up';

  @override
  String get scanNoCreditPlusSoon => 'Plus coming soon';

  @override
  String get scanStatusPreparingImages => 'Processing images…';

  @override
  String get scanStatusIdle => 'Add photos and tap Scan';

  @override
  String scanStatusScanning(int imageCount) {
    return 'Scanning $imageCount image(s)…';
  }

  @override
  String scanStatusSuccess(int itemCount, String provider) {
    return '$itemCount items detected via $provider';
  }

  @override
  String get ocrErrorNetworkTitle => 'No connection';

  @override
  String get ocrErrorNetworkBody =>
      'Check your internet connection, then scan again.';

  @override
  String get ocrErrorAuthTitle => 'Session expired';

  @override
  String get ocrErrorAuthBody =>
      'Your session has expired. Sign in again to continue.';

  @override
  String get ocrErrorParsingTitle => 'Unreadable response';

  @override
  String get ocrErrorParsingBody =>
      'The scan result from the server could not be processed. Try taking the photo again with better lighting.';

  @override
  String get ocrErrorUnknownTitle => 'Something went wrong';

  @override
  String get ocrErrorUnknownBody =>
      'Something did not work as expected. Try again shortly.';

  @override
  String get ocrErrorNotReceiptTitle => 'Not a receipt';

  @override
  String get ocrErrorNotReceiptBody =>
      'The selected image does not look like a shopping receipt. Try a clear, uncropped receipt photo.';

  @override
  String get ocrErrorCreditTitle => 'No scan credits left';

  @override
  String get ocrErrorCreditBody =>
      'Add credits or wait for the next period to scan again.';

  @override
  String get ocrErrorAiBusyTitle => 'AI service is busy';

  @override
  String get ocrErrorAiBusyBody =>
      'The AI server is receiving many requests. Wait a moment, then scan again.';

  @override
  String get ocrErrorRateLimitTitle => 'Too many requests';

  @override
  String get ocrErrorRateLimitBody =>
      'You reached the scan limit for now. Try again in a few minutes.';

  @override
  String get ocrErrorForbiddenTitle => 'Access denied';

  @override
  String get ocrErrorForbiddenBody =>
      'The server rejected the request. Try signing out and signing in again.';

  @override
  String get ocrErrorTimeoutTitle => 'Request took too long';

  @override
  String get ocrErrorTimeoutBody =>
      'The server took too long to respond. Try again.';

  @override
  String get ocrErrorServerTitle => 'Server issue';

  @override
  String get ocrErrorServerBody =>
      'The server is unstable right now. Wait a moment, then try again.';

  @override
  String get ocrErrorGenericTitle => 'Scan failed';

  @override
  String get ocrErrorGenericBody =>
      'This receipt could not be processed. Try taking another photo or using a different image.';

  @override
  String get retry => 'Retry';

  @override
  String get accountSection => 'Account';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get displayNameFallback => 'BagiStruk User';

  @override
  String get anonDisplayName => 'Me';

  @override
  String get guestAccount => 'Guest Account';

  @override
  String get creditScanTitle => 'Scan credits';

  @override
  String get creditStatusLoading => 'Loading credit status...';

  @override
  String creditStatusRemaining(
    int balance,
    int monthlyAllowance,
    String planCode,
  ) {
    return '$balance/$monthlyAllowance remaining ($planCode)';
  }

  @override
  String get billingTitle => 'Plus and credit packs';

  @override
  String get billingAnonSubtitle =>
      'Create an account first to buy Plus or top up credits.';

  @override
  String creditPlusExpiresAt(String date) {
    return 'Plus expires: $date';
  }

  @override
  String creditTrialExpiresAt(String date) {
    return 'Plus trial expires: $date';
  }

  @override
  String get billingPlusActive => 'Plus active';

  @override
  String get billingPlanFree => 'Free';

  @override
  String get billingPlusCardTitle => 'BagiStruk Plus';

  @override
  String get billingPlusBenefitCredits => '60 OCR credits per month';

  @override
  String get billingPlusBenefitNoAds => 'No ads';

  @override
  String get billingPlusBenefitFeatures => 'Access Plus features';

  @override
  String get billingTopUpCardTitle => 'Top up OCR credits';

  @override
  String get billingManageSubscription => 'Manage subscription';

  @override
  String get billingManageOpenFailed =>
      'Could not open subscription management.';

  @override
  String get billingUpgradePlus => 'Upgrade Plus';

  @override
  String billingUpgradePlusWithPrice(String price) {
    return 'Subscribe monthly • $price';
  }

  @override
  String billingCreditPackTitle(int credits) {
    return '$credits credits';
  }

  @override
  String get billingBuyAction => 'Buy';

  @override
  String get billingBuyCredits => 'Buy 50 credits';

  @override
  String get billingLoading => 'Loading...';

  @override
  String get billingRestorePurchases => 'Restore subscription';

  @override
  String get billingUnavailable =>
      'Google Play Billing is not available on this device.';

  @override
  String get billingProductsNotActive =>
      'Some products are not active in Play Console yet.';

  @override
  String get billingProductsLoadFailed => 'Products could not be loaded.';

  @override
  String get billingOpeningPlay => 'Opening Google Play...';

  @override
  String get billingPurchaseStartFailed => 'Purchase could not be started.';

  @override
  String get billingRestoringPurchases => 'Restoring purchases...';

  @override
  String get billingRestoreFailed => 'Purchases could not be restored.';

  @override
  String get billingPaymentPending => 'Waiting for Google Play payment...';

  @override
  String get billingPurchaseFailed => 'Purchase was canceled or failed.';

  @override
  String get billingPurchaseSuccess => 'Purchase processed successfully.';

  @override
  String get billingPurchaseVerifyFailed => 'Purchase could not be verified.';

  @override
  String get changeName => 'Change Name';

  @override
  String get changeNameSheetTitle => 'Change Display Name';

  @override
  String get changeNameHint => 'Display name';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get plusOnlyShort => 'Plus only.';

  @override
  String get transferBankSettingsTitle => 'Bank transfer info';

  @override
  String get transferBankSettingsSubtitle =>
      'Add an account for WhatsApp settlement messages.';

  @override
  String get transferBankSettingsLockedSubtitle =>
      'Plus only. Bank info can be added to WhatsApp settlement messages.';

  @override
  String get transferBankScreenTitle => 'Bank Transfer';

  @override
  String get transferBankNameLabel => 'Bank name';

  @override
  String get transferAccountNameLabel => 'Account holder name';

  @override
  String get transferAccountNumberLabel => 'Account number';

  @override
  String get transferBankShareTitle => 'Transfer to';

  @override
  String get transferBankShareHint =>
      'When filled, this info appears in settlement messages shared to WhatsApp.';

  @override
  String get transferBankPlusOnly =>
      'Bank transfer info is a Plus feature. Upgrade to save an account and add it to settlement messages.';

  @override
  String get transferBankRequired =>
      'Fill this field or leave everything empty.';

  @override
  String get transferBankSaved => 'Bank transfer info saved.';

  @override
  String get transferBankClear => 'Clear bank info';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordConfirmTitle => 'Send password reset email?';

  @override
  String resetPasswordConfirmBody(String email) {
    return 'We will send a password reset link to $email.';
  }

  @override
  String get resetPasswordSent => 'Password reset email sent.';

  @override
  String get resetPasswordScreenTitle => 'Reset Password';

  @override
  String get resetPasswordScreenHeading => 'Create a New Password';

  @override
  String get resetPasswordScreenBody =>
      'Enter a new password for your account. Once saved, you will be returned to Settings.';

  @override
  String get resetPasswordNewLabel => 'New Password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordSaveAction => 'Save Password';

  @override
  String get resetPasswordMinChars => 'At least 8 characters';

  @override
  String get resetPasswordNeedsAlphaDigit => 'Must contain letters and numbers';

  @override
  String get resetPasswordMismatch => 'Passwords do not match';

  @override
  String get resetPasswordSuccess => 'Password updated successfully';

  @override
  String get resetPasswordSessionExpired =>
      'Reset session expired. Please request a new link.';

  @override
  String get currencyLabel => 'Default Currency';

  @override
  String get currencySearchHint => 'Search currency';

  @override
  String get currencySearchEmpty => 'No currency found.';

  @override
  String get languageLabel => 'Language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get logout => 'Log Out';

  @override
  String get registerPermanent => 'Create Permanent Account';

  @override
  String get confirmLogoutTitle => 'Log out of your account?';

  @override
  String get confirmLogoutBody =>
      'You will be logged out and returned as a guest user.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and saved bill data.';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'This will permanently delete your account, profile, saved bills, bill items, participants, assignments, and settlement status. This action cannot be undone.';

  @override
  String get deleteAccountConfirmPhrase => 'DELETE';

  @override
  String get deleteAccountTypeTitle => 'Type DELETE to confirm';

  @override
  String deleteAccountTypeBody(String phrase) {
    return 'Type $phrase to permanently delete your account.';
  }

  @override
  String get deleteAccountInProgress => 'Deleting account...';

  @override
  String get deleteAccountSuccess =>
      'Your account and saved data have been deleted.';

  @override
  String get deletedBillsTitle => 'Deleted bills';

  @override
  String get deletedBillsSettingsSubtitle =>
      'Restore bills deleted in the last 30 days.';

  @override
  String get deletedBillsSettingsLockedSubtitle =>
      'Plus only. Restore accidentally deleted bills within 30 days.';

  @override
  String get deletedBillsLockedTitle => 'Restore deleted bills with Plus';

  @override
  String get deletedBillsLockedSubtitle =>
      'Deleted bills are kept for 30 days so Plus users can recover accidental deletions.';

  @override
  String get deletedBillsEmpty => 'No deleted bills.';

  @override
  String deletedBillDeletedAt(String date) {
    return 'Deleted $date';
  }

  @override
  String deletedBillExpiresAt(String date) {
    return 'Restorable until $date';
  }

  @override
  String get deletedBillRestoreAction => 'Restore';

  @override
  String get deletedBillRestored => 'Bill restored.';

  @override
  String get deleteBillAction => 'Delete';

  @override
  String get deleteBillConfirmTitle => 'Delete this bill?';

  @override
  String deleteBillConfirmBody(String title, String total) {
    return '$title ($total) will move to Deleted bills. Plus users can restore it within 30 days.';
  }

  @override
  String get deleteBillSuccess => 'Bill moved to Deleted bills.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Try again when the network is stable.';

  @override
  String authErrorServer(String message) {
    return 'Server issue: $message. Try again shortly.';
  }

  @override
  String get authErrorParsing =>
      'The server response could not be read. Try again.';

  @override
  String get authErrorUnknown => 'Something unexpected happened. Try again.';

  @override
  String get authErrorInvalidLogin => 'Email or password is incorrect.';

  @override
  String get authErrorAlreadyRegistered =>
      'Email is already registered. Try logging in.';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Email has not been confirmed. Check your inbox.';

  @override
  String get authErrorDisposableEmail =>
      'Temporary/disposable email cannot be used. Use your main email.';

  @override
  String get authErrorEmailAliasUsed =>
      'This email appears to be an alias of an email that has already been used.';

  @override
  String get authErrorInvalidEmail => 'Email format is not valid yet.';

  @override
  String get authErrorGoogleSignIn =>
      'Google Sign-In failed after choosing an account. Try again; if it keeps happening, check the OAuth Android package name, debug/release SHA-1, and Google Web Client ID.';

  @override
  String get authErrorComingSoon => 'This feature is coming soon.';

  @override
  String get authErrorFallback => 'Authentication failed. Try again.';

  @override
  String get loading => 'Loading...';

  @override
  String get noSessionMessage => 'Sign up or log in to access settings.';

  @override
  String get registerOrLogin => 'Sign up / Log in';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue to BagiStruk.';

  @override
  String get loginSaveBanner => 'Sign up to save your bill history';

  @override
  String get loginResetExpiredBanner =>
      'The password reset session has expired. Please request a new link from Settings.';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginOr => 'or';

  @override
  String get loginEmailHint => 'you@email.com';

  @override
  String get loginOtpButton => 'Send email code';

  @override
  String get loginOtpSending => 'Sending code…';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Sign Up';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get registerBackToScanTooltip => 'Back to Scan';

  @override
  String get registerSkip => 'Skip';

  @override
  String get registerHeading => 'Create a new account';

  @override
  String get registerSubtitle => 'Save your bill history across all devices.';

  @override
  String get registerPasswordHint => 'At least 6 characters';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLoginLink => 'Log In';

  @override
  String get legalAcceptanceAppBarTitle => 'Legal Agreement';

  @override
  String get legalAcceptanceTitle => 'Before you start…';

  @override
  String get legalAcceptanceIntro =>
      'To use BagiStruk, please read and agree to the two documents below. We need separate consent for the Terms of Service and the Privacy Policy.';

  @override
  String get legalAcceptanceReadTerms => 'Read Terms of Service';

  @override
  String get legalAcceptanceReadPrivacy => 'Read Privacy Policy';

  @override
  String get legalAcceptanceAgreeTerms =>
      'I have read and agree to the Terms of Service.';

  @override
  String get legalAcceptanceAgreePrivacy =>
      'I have read and agree to the Privacy Policy.';

  @override
  String get legalAcceptanceAgreeAge =>
      'I am 18 years of age or older, or older if required by my local law.';

  @override
  String get legalAcceptanceContinue => 'Continue';

  @override
  String get legalAcceptanceErrorSave =>
      'Failed to save acceptance. Please try again.';

  @override
  String get verifyEmailTitle => 'Verify email';

  @override
  String get verifyEmailBackTooltip => 'Back';

  @override
  String get verifyEmailHeading => 'Check your email';

  @override
  String get verifyEmailBodyPrefix => 'We sent a confirmation link to ';

  @override
  String get verifyEmailBodySuffix =>
      '. Click that link to activate your account — until then you cannot sign in from other devices.';

  @override
  String get verifyEmailAutonav =>
      'After confirmation, you\'ll be automatically navigated to History.';

  @override
  String get verifyEmailResend => 'Resend email';

  @override
  String get verifyEmailResending => 'Sending…';

  @override
  String get verifyEmailResent => 'Verification email has been resent.';

  @override
  String get verifyEmailUseDifferent => 'Use a different email';

  @override
  String get verifyOtpTitle => 'Enter code';

  @override
  String get verifyOtpHeading => 'Check your email code';

  @override
  String get verifyOtpBodyPrefix => 'We sent an 8-digit code to ';

  @override
  String get verifyOtpBodySuffix => '. Enter it to sign in to your account.';

  @override
  String get verifyOtpInvalid => 'Enter the 8-digit code.';

  @override
  String get verifyOtpButton => 'Verify & sign in';

  @override
  String get verifyOtpResend => 'Resend code';

  @override
  String get verifyOtpResending => 'Sending…';

  @override
  String get verifyOtpResent => 'A new code has been sent.';

  @override
  String verifyOtpResendCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifyOtpUseDifferent => 'Use a different email';

  @override
  String get historySignOutTooltip => 'Sign Out';

  @override
  String get historySignedOut => 'You have been signed out.';

  @override
  String get historyLoadingMessage => 'Loading history…';

  @override
  String get historyTotalBills => 'Total bills';

  @override
  String get historyOutstanding => 'Outstanding';

  @override
  String historyOutstandingCarouselPage(int current, int total) {
    return '$current of $total';
  }

  @override
  String get historyEmptyMessage =>
      'No saved bills yet.\nStart scanning a receipt from the Scan tab.';

  @override
  String get historyWindowFree => 'Free history';

  @override
  String get historyWindowPlus => 'Plus history';

  @override
  String get historyWindowAnonymous => 'History locked';

  @override
  String get historyWindowAnonymousSubtitle =>
      'Sign up to save and view bill history.';

  @override
  String historyWindowFreeSubtitle(int freeDays, int plusDays) {
    return 'Showing bills from the last $freeDays days. Plus can show up to the last $plusDays days.';
  }

  @override
  String historyWindowSubtitle(int days) {
    return 'Showing bills from the last $days days.';
  }

  @override
  String get historyUpgradeCta => 'Upgrade to Plus';

  @override
  String get historyPlusBannerDismiss => 'Dismiss';

  @override
  String historyFreePlusBannerLabel(int freeDays) {
    return '$freeDays-day history · Monthly insight';
  }

  @override
  String historyFreePlusBannerSemantics(int freeDays) {
    return '$freeDays-day history and Monthly insight, a Plus feature. Tap for details.';
  }

  @override
  String get historyFreePlusSheetTitle => 'Plus history features';

  @override
  String get historyFreePlusHistoryTitle => 'Longer history';

  @override
  String historyFreePlusHistoryBody(int freeDays, int plusDays) {
    return 'Free shows the last $freeDays days. Plus shows up to $plusDays days.';
  }

  @override
  String get historyFreePlusDismissAction => 'Not now';

  @override
  String get historyFilterTooltip => 'Sort & filter';

  @override
  String get historyFilterTitle => 'Sort & filter';

  @override
  String get historyFilterSort => 'Sort by';

  @override
  String get historyFilterStatus => 'Payment status';

  @override
  String get historyFilterCurrency => 'Currency';

  @override
  String get historyFilterReset => 'Reset';

  @override
  String get historyFilterEmpty => 'No bills match these filters.';

  @override
  String historyFilterCount(int filteredCount, int totalCount) {
    return '$filteredCount of $totalCount bills';
  }

  @override
  String get historySortNewest => 'Newest';

  @override
  String get historySortOldest => 'Oldest';

  @override
  String get historySortTitle => 'Name A-Z';

  @override
  String get historySortAmountDesc => 'Amount (high first)';

  @override
  String get historySortAmountAsc => 'Amount (low first)';

  @override
  String get historySortNominalDisabled =>
      'Select a single currency to sort by amount.';

  @override
  String get historyStatusAll => 'All';

  @override
  String get historyStatusUnassigned => 'Not split';

  @override
  String get historyStatusUnpaid => 'Unpaid';

  @override
  String get historyStatusPartial => 'Partially paid';

  @override
  String get historyStatusSettled => 'Paid';

  @override
  String get applyAction => 'Apply';

  @override
  String get monthlyInsightTitle => 'Monthly insight';

  @override
  String monthlyInsightMonth(String month, int year) {
    return 'Spending in $month $year';
  }

  @override
  String get monthlyInsightLoading => 'Loading monthly insight...';

  @override
  String get monthlyInsightError => 'Could not load monthly insight.';

  @override
  String get monthlyInsightLockedSubtitle =>
      'See monthly totals, trends, outstanding amount, and top merchants with Plus.';

  @override
  String get monthlyInsightPreviousMonth => 'Previous month';

  @override
  String get monthlyInsightNextMonth => 'Next month';

  @override
  String get monthlyInsightTotal => 'Total';

  @override
  String get monthlyInsightAverage => 'Average bill';

  @override
  String get monthlyInsightBills => 'Bills';

  @override
  String get monthlyInsightOutstanding => 'Outstanding';

  @override
  String get monthlyInsightTopMerchants => 'Top merchants';

  @override
  String monthlyInsightIncrease(String percent) {
    return 'Up $percent% vs last month';
  }

  @override
  String monthlyInsightDecrease(String percent) {
    return 'Down $percent% vs last month';
  }

  @override
  String get monthlyInsightNoChange => 'No change vs last month';

  @override
  String get splitSummaryTitle => 'Summary per Person';

  @override
  String get splitSummaryNoItems => 'No items selected.';

  @override
  String get splitSummarySubtotal => 'Subtotal';

  @override
  String get splitSummaryTax => 'Tax (proportional)';

  @override
  String get splitSummaryService => 'Service (proportional)';

  @override
  String get splitSummaryShare => 'Share';

  @override
  String get participantShareAgain => 'Share again';

  @override
  String get billReviewTitle => 'Review bill';

  @override
  String get billReviewAddItem => 'Add item';

  @override
  String get billReviewDeleteItemTitle => 'Delete item?';

  @override
  String billReviewDeleteItemBody(String name) {
    return 'Item \"$name\" will be deleted.';
  }

  @override
  String get billReviewMerchantHint => 'Merchant name';

  @override
  String get billReviewItemNameHint => 'Item name';

  @override
  String get billReviewUnnamedItem => 'unnamed item';

  @override
  String get billReviewUnitPriceLabel => 'Price / unit';

  @override
  String get billReviewTaxLabel => 'Tax';

  @override
  String get billReviewServiceLabel => 'Service';

  @override
  String get billReviewSaveBill => 'Save Bill';

  @override
  String get billReviewCurrencyPlusTitle => 'Per-bill currency';

  @override
  String get billReviewCurrencyPlusDetail =>
      'Changing currency per bill is a Plus feature. Free users keep using the default currency from Settings.';

  @override
  String billReviewAiLowConfidence(String percent) {
    return 'AI is less confident ($percent%) — verify the numbers.';
  }

  @override
  String billReviewMismatch(String computed, String detected) {
    return 'Total $computed differs from the receipt ($detected). Check again.';
  }

  @override
  String get billReviewTitleRequired => 'Title cannot be empty.';

  @override
  String get billReviewItemsRequired => 'Add at least one item.';

  @override
  String get billReviewInvalidItem =>
      'Check the name, price, and quantity for every item.';

  @override
  String billReviewSaveBillFailed(String message) {
    return 'Could not save bill: $message';
  }

  @override
  String billReviewSaveItemsFailed(String message) {
    return 'Bill was saved, but items could not be saved: $message';
  }

  @override
  String get billSplitTitle => 'Split bill';

  @override
  String get billSplitBackTooltip => 'Back';

  @override
  String get billSplitDone => 'Done';

  @override
  String get billSplitAddPersonTitle => 'Add person';

  @override
  String get billSplitNameHint => 'Name';

  @override
  String get billSplitAdd => 'Add';

  @override
  String get billSplitEmptyItems => 'This bill has no items yet.';

  @override
  String get billSplitTotalBill => 'Total bill';

  @override
  String get billSplitAllAssigned => 'All items have been split';

  @override
  String billSplitUnassigned(String amount) {
    return 'Unassigned: $amount';
  }

  @override
  String get billSplitViewSummary => 'View Summary';

  @override
  String get billSplitStateNotReady => 'State is not ready.';

  @override
  String get billSplitNameRequired => 'Name cannot be empty.';

  @override
  String billSplitAddPersonFailed(String message) {
    return 'Could not add person: $message';
  }

  @override
  String get billSplitSelectPersonFirst => 'Select a person below first.';

  @override
  String billSplitSaveAssignmentFailed(String message) {
    return 'Could not save assignment: $message';
  }

  @override
  String get billSplitRemoveParticipantTitle => 'Remove participant?';

  @override
  String billSplitRemoveParticipantMessage(String name) {
    return 'All items assigned to $name will also be removed.';
  }

  @override
  String get billSplitRemoveParticipantConfirm => 'Remove';

  @override
  String billSplitRemoveParticipantFailed(String message) {
    return 'Failed to remove participant: $message';
  }

  @override
  String get billSplitParticipantBarHint =>
      'Long-press a participant to remove';

  @override
  String get participantPhoneLabel => 'Phone (optional)';

  @override
  String get participantSuggestionTitle => 'Frequently used';

  @override
  String get participantImportFromContacts => 'Import from contacts';

  @override
  String get participantImportFailed =>
      'Could not open contacts. Try again or add manually.';

  @override
  String get participantImportNoPhone => '(this contact has no phone number)';

  @override
  String get billDetailParticipantPhoneLabel => 'Phone';

  @override
  String get billDetailTitle => 'Bill Details';

  @override
  String get billDetailHomeTooltip => 'Home';

  @override
  String get billDetailScanAnotherTooltip => 'Scan another receipt';

  @override
  String get billDetailLoading => 'Loading details…';

  @override
  String get billDetailParticipants => 'Participants';

  @override
  String get billDetailTotalBill => 'Total bill';

  @override
  String billDetailPaidProgress(int paidCount, int totalCount) {
    return '$paidCount/$totalCount participants have paid';
  }

  @override
  String get billDetailSettled => 'Paid';

  @override
  String get billDetailUnsettled => 'Unpaid';

  @override
  String get billDetailEmptyParticipants =>
      'No participants for this bill yet.';

  @override
  String get billDetailGoToSplit => 'Go to Split';

  @override
  String get billDetailParticipantNotFound => 'Participant not found.';

  @override
  String billDetailSaveStatusFailed(String message) {
    return 'Could not save status: $message';
  }

  @override
  String get billDetailStateNotReady =>
      'Data is not ready yet, please try again shortly.';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportPdfPlusLocked => 'Export PDF (Plus)';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvPlusLocked => 'Export CSV (Plus)';

  @override
  String get exportPlusDetail =>
      'PDF and CSV exports are Plus features. Free users can still view and share the basic participant breakdown.';

  @override
  String get exportFailed => 'Could not create the export. Please try again.';

  @override
  String exportPdfSubject(String title) {
    return 'Export $title';
  }

  @override
  String exportPdfShareText(String title) {
    return 'PDF export for $title';
  }

  @override
  String exportCsvSubject(String title) {
    return 'Export $title';
  }

  @override
  String exportCsvShareText(String title) {
    return 'CSV export for $title';
  }

  @override
  String get splitSummaryCopy => 'Copy';

  @override
  String get splitSummaryCopied => 'Copied to clipboard';

  @override
  String get splitShareFailed => 'Could not share';

  @override
  String get settlementTemplateBasic => 'Basic';

  @override
  String get settlementTemplateCompact => 'Compact message';

  @override
  String get settlementTemplateDetailed => 'Detailed message';

  @override
  String get settlementTemplateAll => 'All participants recap';

  @override
  String get settlementTemplatePlusLocked =>
      'Neater WhatsApp templates are available with Plus.';

  @override
  String get settlementMessageBillPrefix => 'Details for';

  @override
  String get settlementMessageRecapPrefix => 'BagiStruk recap -';

  @override
  String get settlementMessageFor => 'For';

  @override
  String settlementMessageGreeting(String name) {
    return 'Hi $name, your share is:';
  }

  @override
  String get settlementMessageTransferNote =>
      'Please transfer if everything looks right. Thank you.';

  @override
  String get settlementMessageItems => 'Your items';

  @override
  String get settlementMessageUnnamedItem => '(unnamed item)';

  @override
  String settlementMessageSharedWith(int count) {
    return 'split by $count';
  }

  @override
  String get settlementMessageTotal => 'Total';

  @override
  String get settlementMessageStatus => 'Status';

  @override
  String get settlementMessagePaid => 'paid';

  @override
  String get settlementMessageUnpaid => 'unpaid';

  @override
  String get settlementMessageGrandTotal => 'Total bill';

  @override
  String get settlementMessageOutstanding => 'Outstanding';

  @override
  String settlementMessageWhatsappLink(String url) {
    return 'Chat via WhatsApp: $url';
  }

  @override
  String settlementPromoFooter(String url) {
    return 'Made with BagiStruk. Try the app on Google Play: $url';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSettingsTile => 'About App';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutSectionApp => 'Application';

  @override
  String get aboutSectionAuthor => 'Author';

  @override
  String get aboutSectionSupport => 'Support';

  @override
  String get aboutAuthorName => 'Alam Aby Bashit';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutGithub => 'GitHub';

  @override
  String get aboutLinkedin => 'LinkedIn';

  @override
  String get aboutBuyMeACoffee => 'Buy Me a Coffee';

  @override
  String get aboutSaweria => 'Saweria';

  @override
  String get aboutPatreon => 'Patreon';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get aboutTermsOfService => 'Terms of Service';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get linkUnavailable => 'Link is not available yet';

  @override
  String get reviewSuspectThousandsBug =>
      'Prices look like the thousand separator may have been read as a decimal. Please verify each amount before saving.';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authInvalidEmailFormat => 'Email format is invalid';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authGoogleSigningIn => 'Signing in...';

  @override
  String get failureRetry => 'Retry';

  @override
  String failurePrefixNetwork(String message) {
    return 'Network: $message';
  }

  @override
  String failurePrefixServer(String code, String message) {
    return 'Server ($code): $message';
  }

  @override
  String failurePrefixServerNoCode(String message) {
    return 'Server: $message';
  }

  @override
  String failurePrefixParsing(String message) {
    return 'Could not parse response: $message';
  }

  @override
  String failurePrefixAuth(String message) {
    return 'Auth: $message';
  }

  @override
  String failurePrefixUnexpected(String error) {
    return 'Unexpected: $error';
  }

  @override
  String get historyFilterActiveBadge => 'Active';

  @override
  String get commonPlus => 'Plus';

  @override
  String get billReviewQtyLabel => 'Qty';

  @override
  String get billReviewSubtotalLabel => 'Subtotal';

  @override
  String get billReviewTotalLabel => 'Total';

  @override
  String get exportLabelItems => 'Items';

  @override
  String get exportLabelParticipants => 'Participants';

  @override
  String get exportLabelCurrency => 'Currency';

  @override
  String get exportLabelName => 'Name';

  @override
  String get exportLabelQty => 'Qty';

  @override
  String get exportLabelPrice => 'Price';

  @override
  String get exportLabelSubtotal => 'Subtotal';

  @override
  String get exportLabelTax => 'Tax';

  @override
  String get exportLabelService => 'Service';

  @override
  String get exportLabelTotal => 'Total';

  @override
  String get exportLabelStatus => 'Status';

  @override
  String get exportLabelAssignedParticipants => 'Assigned participants';

  @override
  String get exportLabelBillTitle => 'Title';

  @override
  String get exportLabelReceiptDate => 'Receipt date';

  @override
  String get exportLabelCreatedAt => 'Created at';

  @override
  String get exportLabelTotalAmount => 'Total amount';

  @override
  String get exportLabelSettledYes => 'yes';

  @override
  String get exportLabelSettledNo => 'no';

  @override
  String get exportLabelPaidStatus => 'paid';

  @override
  String get exportLabelUnpaidStatus => 'unpaid';

  @override
  String exportCsvTopTitle(String title) {
    return 'Bill Detail: $title';
  }

  @override
  String exportPdfSubjectFallback(String title) {
    return 'PDF export $title';
  }

  @override
  String exportPdfShareTextFallback(String title) {
    return 'PDF export for $title';
  }

  @override
  String exportCsvSubjectFallback(String title) {
    return 'CSV export $title';
  }

  @override
  String exportCsvShareTextFallback(String title) {
    return 'CSV export for $title';
  }

  @override
  String settlementMessageCompactTitle(String title) {
    return 'BagiStruk - $title';
  }

  @override
  String settlementMessageDetailedTitle(String title) {
    return 'BagiStruk - $title';
  }

  @override
  String settlementMessageBasicTitle(String title) {
    return '$title';
  }

  @override
  String get billDetailParticipantPhoneHint => 'Phone (optional)';

  @override
  String get appInitErrorTitle => 'BagiStruk failed to start';

  @override
  String get appInitErrorRetryHint =>
      'Check your internet connection, then reopen the app. If the issue persists, check the .env file and Supabase settings.';

  @override
  String appInitErrorEnvLoad(String message) {
    return 'Failed to load configuration (.env): $message';
  }

  @override
  String appInitErrorSupabase(String message) {
    return 'Failed to initialize Supabase: $message';
  }

  @override
  String get paywallTitle => 'Save history & track debts';

  @override
  String get paywallSubtitle =>
      'Sign up or log in to save your history and track money you’re owed.';

  @override
  String get paywallRegister => 'Sign Up';

  @override
  String get paywallLogin => 'Sign In';

  @override
  String get scanEmptyHint =>
      'Take a photo of a shopping or dining receipt to start splitting fairly!';

  @override
  String get adPrivacyChoicesTitle => 'Ad privacy choices';

  @override
  String get adPrivacyChoicesSubtitle =>
      'Review or change ad consent where required.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Start scanning';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPreferencesTitle => 'Set your preferences';

  @override
  String get onboardingPreferencesBody =>
      'Choose your default app language and currency.';

  @override
  String get onboardingPreferencesLanguage => 'App language';

  @override
  String get onboardingPreferencesCurrency => 'Default currency';

  @override
  String get onboardingPreferencesChangeLater =>
      'You can change both later in Settings.';

  @override
  String get onboardingPreferencesSaveError =>
      'Could not save preferences. Please try again.';

  @override
  String get onboardingTitle1 => 'Scan receipt';

  @override
  String get onboardingBody1 =>
      'Take a photo or pick a receipt. BagiStruk automatically reads items and the total.';

  @override
  String get onboardingTitle2 => 'Split it';

  @override
  String get onboardingBody2 =>
      'Organize splits for each person. Add friends and select the items they ordered.';

  @override
  String get onboardingTitle3 => 'Settle up';

  @override
  String get onboardingBody3 =>
      'Share the details via WhatsApp and track payments as they arrive.';

  @override
  String get onboardingReplayFinish => 'Done';

  @override
  String get onboardingSettingsTile => 'View app guide';

  @override
  String get onboardingSaveError => 'Could not save. Please try again.';

  @override
  String get ocrAiDisclosure =>
      'Receipt photos are processed by third-party AI services for item extraction.';
}
