import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';
import 'result.dart';

/// Wraps an async datasource call and translates known framework exceptions
/// into [Failure] variants. Keeps every repository implementation free of
/// boilerplate try/catch ladders.
Future<Result<T>> guardAsync<T>(Future<T> Function() body) async {
  try {
    final value = await body();
    return Result.success(value);
  } on PostgrestException catch (e) {
    return Result.failure(
      Failure.server(code: int.tryParse(e.code ?? ''), message: e.message),
    );
  } on AuthException catch (e) {
    return Result.failure(Failure.auth(e.message));
  } on FunctionException catch (e) {
    return Result.failure(
      Failure.server(code: e.status, message: e.details?.toString() ?? 'Edge function error'),
    );
  } on SocketException catch (e) {
    return Result.failure(Failure.network(e.message));
  } on TimeoutException catch (e) {
    return Result.failure(Failure.network(e.message ?? 'Request timed out'));
  } on FormatException catch (e) {
    return Result.failure(Failure.parsing(e.message));
  } catch (e, st) {
    return Result.failure(Failure.unknown(e, st));
  }
}
