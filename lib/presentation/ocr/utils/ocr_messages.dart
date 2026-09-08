import '../../../core/error/failure.dart';
import '../../../l10n/generated/app_l10n.dart';

/// Maps OCR pipeline [Failure]s to short, friendly localized messages.
/// The raw failure payload (provider JSON, stack traces, attempts log) is
/// useful for debugging but unreadable in the UI — we surface a clean message
/// and keep the technical details for logs only.
class OcrMessage {
  const OcrMessage({
    required this.title,
    required this.body,
    this.canRetry = true,
  });

  final String title;
  final String body;
  final bool canRetry;
}

OcrMessage friendlyOcrMessage(Failure failure, AppL10n l10n) {
  return switch (failure) {
    NetworkFailure() => OcrMessage(
      title: l10n.ocrErrorNetworkTitle,
      body: l10n.ocrErrorNetworkBody,
    ),
    AuthFailure() => OcrMessage(
      title: l10n.ocrErrorAuthTitle,
      body: l10n.ocrErrorAuthBody,
      canRetry: false,
    ),
    ParsingFailure() => OcrMessage(
      title: l10n.ocrErrorParsingTitle,
      body: l10n.ocrErrorParsingBody,
    ),
    ServerFailure(:final code, :final message) => _serverMessage(
      code,
      message,
      l10n,
    ),
    UnknownFailure() => OcrMessage(
      title: l10n.ocrErrorUnknownTitle,
      body: l10n.ocrErrorUnknownBody,
    ),
  };
}

OcrMessage _serverMessage(int? code, String raw, AppL10n l10n) {
  final lower = raw.toLowerCase();

  if (lower.contains('not_a_receipt')) {
    return OcrMessage(
      title: l10n.ocrErrorNotReceiptTitle,
      body: l10n.ocrErrorNotReceiptBody,
    );
  }
  if (lower.contains('ocr_credit_required') ||
      lower.contains('anonymous_scan_limit_reached')) {
    return OcrMessage(
      title: l10n.ocrErrorCreditTitle,
      body: l10n.ocrErrorCreditBody,
      canRetry: false,
    );
  }
  if (lower.contains('all_providers_failed') ||
      lower.contains('unavailable') ||
      lower.contains('high demand') ||
      code == 503) {
    return OcrMessage(
      title: l10n.ocrErrorAiBusyTitle,
      body: l10n.ocrErrorAiBusyBody,
    );
  }
  if (code == 429 || lower.contains('rate limit') || lower.contains('quota')) {
    return OcrMessage(
      title: l10n.ocrErrorRateLimitTitle,
      body: l10n.ocrErrorRateLimitBody,
    );
  }
  if (code == 401 || code == 403) {
    return OcrMessage(
      title: l10n.ocrErrorForbiddenTitle,
      body: l10n.ocrErrorForbiddenBody,
      canRetry: false,
    );
  }
  if (code == 408 || lower.contains('timeout')) {
    return OcrMessage(
      title: l10n.ocrErrorTimeoutTitle,
      body: l10n.ocrErrorTimeoutBody,
    );
  }
  // 413 from the pre-LLM size guard (max 10 images / 20MB total): retrying
  // the same draft is pointless — the user must drop or shrink photos.
  // canRetry=false hides the Plus in-card retry for this case.
  if (code == 413 ||
      lower.contains('too_many_images') ||
      lower.contains('images_too_large') ||
      lower.contains('too_large') ||
      lower.contains('too large') ||
      lower.contains('payload too large')) {
    return OcrMessage(
      title: l10n.ocrErrorTooLargeTitle,
      body: l10n.ocrErrorTooLargeBody,
      canRetry: false,
    );
  }
  if (code != null && code >= 500) {
    return OcrMessage(
      title: l10n.ocrErrorServerTitle,
      body: l10n.ocrErrorServerBody,
    );
  }
  return OcrMessage(
    title: l10n.ocrErrorGenericTitle,
    body: l10n.ocrErrorGenericBody,
  );
}
