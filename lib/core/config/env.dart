import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed accessor for environment variables loaded from `.env`.
///
/// Why a wrapper: callers should not depend on dotenv directly so the source
/// of secrets can swap (e.g. `--dart-define`, remote config) without touching
/// every call-site.
class Env {
  const Env._();

  static String get supabaseUrl => _required('SUPABASE_URL');
  static String get supabaseAnonKey => _required('SUPABASE_ANON_KEY');

  static String _required(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing required env var: $key. See .env.example.');
    }
    return value;
  }
}
