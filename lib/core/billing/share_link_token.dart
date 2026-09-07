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
}
