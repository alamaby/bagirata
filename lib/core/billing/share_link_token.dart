import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

/// Share-link token helpers (M2/F5).
///
/// The raw token is opaque and travels only in the deep link + clipboard.
/// What persists server-side is the SHA-256 hex (`token_hash`), so a DB leak
/// never yields usable links. Matches the `email_canonical_hash` pattern.
class ShareLinkToken {
  ShareLinkToken._();

  static const _uuid = Uuid();

  /// A fresh opaque token, e.g. `bagistruk://share/<token>`.
  static String generate() => _uuid.v4().replaceAll('-', '');

  /// `token_hash` as stored in `bill_share_tokens`.
  static String hash(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  /// Two-line share text: the raw tappable link first, then a localized
  /// fallback line for recipients without the app (custom-scheme links are
  /// dead text there). Clipboard keeps the raw link only.
  static String shareText({
    required String link,
    required String fallbackLine,
  }) =>
      '$link\n$fallbackLine';
}

/// Countdown math for share-link expiry display. Pure Dart (no Flutter, no
/// clock) so it stays trivially unit-testable.
///
/// Skew policy: the server (`expires_at > NOW()`) is the sole source of
/// truth. The client never guesses "still valid" — `remaining` clamps at
/// zero and the UI renders the expired state. A few seconds of device-clock
/// skew can only show "expired" marginally early, never a live countdown
/// for a dead link.
class ShareLinkCountdown {
  const ShareLinkCountdown._();

  /// Time left, never negative.
  static Duration remaining({
    required DateTime expiresAt,
    required DateTime now,
  }) {
    final diff = expiresAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  static bool isExpired({required DateTime expiresAt, required DateTime now}) =>
      remaining(expiresAt: expiresAt, now: now) == Duration.zero;

  /// Display bucket: days (≥24h), hours (≥1h), minutes otherwise.
  /// Whole units, floored — except sub-minute remainders round up to 1 min
  /// so a live link never reads "0 minutes".
  static int wholeDays(Duration remaining) => remaining.inHours ~/ 24;

  static int wholeHours(Duration remaining) => remaining.inHours;

  static int wholeMinutes(Duration remaining) =>
      (remaining.inSeconds / 60).ceil().clamp(1, 24 * 60);
}
