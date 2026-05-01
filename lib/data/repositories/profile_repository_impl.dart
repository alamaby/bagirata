import '../../core/error/exception_mapper.dart';
import '../../core/error/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  ProfileRepositoryImpl(this._ds);
  final ProfileRemoteDataSource _ds;

  @override
  Future<Result<UserProfile>> getCurrentProfile() => guardAsync(() async {
        final dto = await _ds.getCurrentProfile();
        return UserProfile(
          id: dto.id,
          displayName: dto.displayName,
          email: _ds.currentEmail,
          defaultCurrency: dto.defaultCurrency,
          languagePref: dto.languagePref,
          themePref: dto.themePref,
          isAnonymous: _ds.isAnonymous,
        );
      });

  @override
  Future<Result<void>> updateDisplayName(String name) =>
      guardAsync(() => _ds.updateField('display_name', name.trim()));

  @override
  Future<Result<void>> updateDefaultCurrency(String code) =>
      guardAsync(() => _ds.updateField('default_currency', code));

  @override
  Future<Result<void>> updateLanguage(String code) =>
      guardAsync(() => _ds.updateField('language_pref', code));

  @override
  Future<Result<void>> updateThemePref(String mode) =>
      guardAsync(() => _ds.updateField('theme_pref', mode));
}
