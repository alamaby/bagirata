import '../../core/error/exception_mapper.dart';
import '../../core/error/result.dart';
import '../../domain/entities/auth_snapshot.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._ds);
  final AuthRemoteDataSource _ds;

  @override
  String? get currentUserId => _ds.currentUserId;

  @override
  bool get isAnonymous => _ds.isAnonymous;

  @override
  bool get isEmailConfirmed => _ds.isEmailConfirmed;

  @override
  bool get isPasswordRecovery => _ds.isPasswordRecovery;

  @override
  String? get currentEmail => _ds.currentEmail;

  @override
  Stream<String?> watchUserId() => _ds.watchUserId();

  @override
  Stream<AuthSnapshot> watchAuthState() => _ds.watchAuthState();

  @override
  Future<Result<String>> signInAnonymously() =>
      guardAsync(_ds.signInAnonymously);

  @override
  Future<Result<String>> ensureSignedIn() => guardAsync(_ds.ensureSignedIn);

  @override
  Future<Result<void>> linkEmail({
    required String email,
    required String password,
  }) => guardAsync(() => _ds.linkEmail(email: email, password: password));

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
  }) => guardAsync(() => _ds.signUp(email: email, password: password));

  @override
  Future<Result<void>> signInWithPassword({
    required String email,
    required String password,
  }) => guardAsync(
    () => _ds.signInWithPassword(email: email, password: password),
  );

  @override
  Future<Result<void>> sendEmailOtp({
    required String email,
    required String languageCode,
  }) => guardAsync(
    () => _ds.sendEmailOtp(email: email, languageCode: languageCode),
  );

  @override
  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String token,
  }) => guardAsync(() => _ds.verifyEmailOtp(email: email, token: token));

  @override
  Future<Result<void>> signInWithGoogle() => guardAsync(_ds.signInWithGoogle);

  @override
  Future<Result<void>> resendEmailChange({required String email}) =>
      guardAsync(() => _ds.resendEmailChange(email: email));

  @override
  Future<Result<void>> recoverSessionFromUri(Uri uri) =>
      guardAsync(() => _ds.recoverSessionFromUri(uri));

  @override
  Future<Result<void>> signOut() => guardAsync(_ds.signOut);

  @override
  Future<Result<void>> deleteAccount() => guardAsync(_ds.deleteAccount);

  @override
  Future<Result<void>> resetPasswordForEmail(String email) =>
      guardAsync(() => _ds.resetPasswordForEmail(email));

  @override
  Future<Result<void>> updatePassword(String newPassword) =>
      guardAsync(() => _ds.updatePassword(newPassword));

  @override
  Future<void> clearPasswordRecovery() => _ds.clearPasswordRecovery();
}
