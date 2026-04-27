import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/network/supabase_client_provider.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_bill_repository.dart';
import '../domain/repositories/i_ocr_repository.dart';
import 'datasources/auth_remote_datasource.dart';
import 'datasources/bill_remote_datasource.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/bill_repository_impl.dart';
import 'repositories/ocr_repository_impl.dart';
import 'services/ocr_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
BillRemoteDataSource billRemoteDataSource(Ref ref) =>
    BillRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
IBillRepository billRepository(Ref ref) =>
    BillRepositoryImpl(ref.watch(billRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
IOCRRepository ocrRepository(Ref ref) =>
    OcrRepositoryImpl(ref.watch(ocrServiceProvider));

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
