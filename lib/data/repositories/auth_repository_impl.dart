import '../../core/error/exception_mapper.dart';
import '../../core/error/failure.dart';
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
  Stream<String?> watchUserId() => _ds.watchUserId();

  @override
  Stream<AuthSnapshot> watchAuthState() => _ds.watchAuthState();

  @override
  Future<Result<String>> signInAnonymously() =>
      guardAsync(_ds.signInAnonymously);

  @override
  Future<Result<void>> linkEmail({required String email, required String password}) =>
      guardAsync(() => _ds.linkEmail(email: email, password: password));

  @override
  Future<Result<void>> signUp({required String email, required String password}) =>
      guardAsync(() => _ds.signUp(email: email, password: password));

  @override
  Future<Result<void>> signInWithPassword({required String email, required String password}) =>
      guardAsync(() => _ds.signInWithPassword(email: email, password: password));

  @override
  Future<Result<void>> signInWithGoogle() async =>
      const Result.failure(Failure.auth('Google sign-in coming soon'));

  @override
  Future<Result<void>> signOut() => guardAsync(_ds.signOut);
}
