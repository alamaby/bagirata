import '../../core/error/exception_mapper.dart';
import '../../core/error/result.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._ds);
  final AuthRemoteDataSource _ds;

  @override
  String? get currentUserId => _ds.currentUserId;

  @override
  Stream<String?> watchUserId() => _ds.watchUserId();

  @override
  Future<Result<String>> signInAnonymously() =>
      guardAsync(_ds.signInAnonymously);

  @override
  Future<Result<void>> linkEmail({required String email, required String password}) =>
      guardAsync(() => _ds.linkEmail(email: email, password: password));

  @override
  Future<Result<void>> signOut() => guardAsync(_ds.signOut);
}
