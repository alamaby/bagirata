import '../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract interface class IProfileRepository {
  /// Loads the current user's profile row, joined with the email + anon flag
  /// from the active Supabase session.
  Future<Result<UserProfile>> getCurrentProfile();

  Future<Result<void>> updateDisplayName(String name);

  /// [code] must be one of `IDR`, `USD`, `MYR`, `AUD`, `SGD`, `SAR`.
  Future<Result<void>> updateDefaultCurrency(String code);

  /// [code] must be `id` or `en`.
  Future<Result<void>> updateLanguage(String code);

  /// [mode] must be `light`, `dark`, or `system`.
  Future<Result<void>> updateThemePref(String mode);
}
