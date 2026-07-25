import 'dart:async';
import 'dart:typed_data';

import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/datasources/app_config_remote_datasource.dart';
import 'package:bagistruk/data/datasources/auth_remote_datasource.dart';
import 'package:bagistruk/data/datasources/bill_remote_datasource.dart';
import 'package:bagistruk/data/datasources/profile_remote_datasource.dart';
import 'package:bagistruk/data/dtos/bill_dto.dart';
import 'package:bagistruk/data/dtos/item_dto.dart';
import 'package:bagistruk/data/dtos/ocr_response_dto.dart';
import 'package:bagistruk/data/dtos/profile_dto.dart';
import 'package:bagistruk/data/repositories/app_config_repository_impl.dart';
import 'package:bagistruk/data/repositories/auth_repository_impl.dart';
import 'package:bagistruk/data/repositories/bill_repository_impl.dart';
import 'package:bagistruk/data/repositories/ocr_repository_impl.dart'
    show OcrRepositoryImpl;
import 'package:bagistruk/data/repositories/profile_repository_impl.dart';
import 'package:bagistruk/data/services/ocr_service.dart';
import 'package:bagistruk/domain/entities/auth_snapshot.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repository_contract_test.mocks.dart';

@GenerateMocks([
  BillRemoteDataSource,
  OCRService,
])
void main() {
  setUpAll(() {
    provideDummy<Result<String>>(Result.success(''));
    provideDummy<Result<BillDto>>(Result.success(
      BillDto(
        id: '',
        title: '',
        totalAmount: 0,
        currencyCode: 'IDR',
        tax: 0,
        service: 0,
        createdAt: DateTime.utc(2026),
      ),
    ));
    provideDummy<Result<List<ItemDto>>>(Result.success([]));
    provideDummy<Result<OcrResponseDto>>(Result.success(
      OcrResponseDto(items: [], providerUsed: ''),
    ));
  });

  group('BillRepositoryImpl', () {
    late MockBillRemoteDataSource dataSource;
    late BillRepositoryImpl repository;
    late Bill bill;
    late BillDto dto;

    setUp(() {
      dataSource = MockBillRemoteDataSource();
      repository = BillRepositoryImpl(dataSource);
      bill = Bill(
        id: 'bill-1',
        title: 'Dinner',
        totalAmount: 125000,
        currencyCode: 'IDR',
        tax: 10000,
        service: 5000,
        isSettled: true,
        receiptDate: DateTime.utc(2026, 7, 23),
        createdAt: DateTime.utc(2026, 7, 24),
      );
      dto = BillDto.fromEntity(bill);
    });

    test(
      'createBill authenticates before upsert and maps returned DTO',
      () async {
        when(dataSource.authEnsureSignedIn())
            .thenAnswer((_) async => const Result.success('user-1'));
        when(dataSource.upsertBill(any)).thenAnswer((_) async => dto);

        final result = await repository.createBill(bill);

        expect(result, Result.success(bill));
        // Verify call order using verifyInOrder without capture
        verifyInOrder([
          dataSource.authEnsureSignedIn(),
          dataSource.upsertBill(dto),
        ]);
      },
    );

    test('createBill preserves auth failure and never upserts', () async {
      const failure = Failure.auth('session unavailable');
      when(dataSource.authEnsureSignedIn())
          .thenAnswer((_) async => const Result.failure(failure));

      final result = await repository.createBill(bill);

      expect(result.failureOrNull, same(failure));
      verifyNever(dataSource.upsertBill(any));
    });

    test('updateBill uses same auth-before-upsert contract', () async {
      when(dataSource.authEnsureSignedIn())
          .thenAnswer((_) async => const Result.success('user-1'));
      when(dataSource.upsertBill(any)).thenAnswer((_) async => dto);

      expect(await repository.updateBill(bill), Result.success(bill));
      verifyInOrder([
        dataSource.authEnsureSignedIn(),
        dataSource.upsertBill(dto),
      ]);
    });

    test('listBills maps DTOs to immutable entity list', () async {
      when(dataSource.listBills(createdAfter: anyNamed('createdAfter')))
          .thenAnswer((_) async => [dto]);

      final result = await repository.listBills(
        createdAfter: DateTime.utc(2026, 1),
      );

      expect(result.dataOrNull, [bill]);
      expect(() => result.dataOrNull!.add(bill), throwsUnsupportedError);
    });

    test('datasource exception maps to repository failure', () async {
      when(dataSource.getBill('bill-1')).thenThrow(
        const PostgrestException(message: 'denied', code: '403'),
      );

      final result = await repository.getBill('bill-1');

      expect(
        result.failureOrNull,
        const Failure.server(code: 403, message: 'denied'),
      );
    });
  });

  group('OcrRepositoryImpl', () {
    late MockOCRService service;
    late OcrRepositoryImpl repository;

    setUp(() {
      service = MockOCRService();
      repository = OcrRepositoryImpl(service);
    });

    test('forwards request fields and maps DTO to entity', () async {
      final images = [
        Uint8List.fromList([1, 2, 3]),
      ];
      final dto = OcrResponseDto(
        items: const [OcrLineItemDto(name: 'Noodles', price: 25000, qty: 2)],
        detectedTotal: 50000,
        merchant: 'Warung',
        confidence: 0.92,
        providerUsed: 'gemini',
      );
      when(service.processReceipt(
        images,
        hint: 'food',
        currency: 'IDR',
        fingerprintHeaders: const {'x-device': 'hash'},
      )).thenAnswer((_) async => Result.success(dto));

      final result = await repository.processReceipt(
        images,
        hint: 'food',
        currency: 'IDR',
        fingerprintHeaders: const {'x-device': 'hash'},
      );

      expect(result.dataOrNull, dto.toEntity());
      verify(
        service.processReceipt(
          images,
          hint: 'food',
          currency: 'IDR',
          fingerprintHeaders: const {'x-device': 'hash'},
        ),
      ).called(1);
    });

    test('preserves exact service failure', () async {
      final images = [Uint8List(0)];
      const failure = Failure.server(code: 429, message: 'quota exceeded');
      when(service.processReceipt(
        images,
        hint: null,
        currency: null,
        fingerprintHeaders: null,
      )).thenAnswer((_) async => const Result.failure(failure));

      final result = await repository.processReceipt(images);

      expect(result.failureOrNull, same(failure));
    });
  });

  group('ProfileRepositoryImpl', () {
    late _FakeProfileRemoteDataSource dataSource;
    late ProfileRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeProfileRemoteDataSource();
      repository = ProfileRepositoryImpl(dataSource);
    });

    test('getCurrentProfile combines profile DTO with auth state', () async {
      dataSource.mockCurrentEmail = 'user@example.com';
      dataSource.mockIsAnonymous = true;
      dataSource.mockProfileDto = const ProfileDto(
        id: 'user-1',
        displayName: 'Ayu',
        defaultCurrency: 'IDR',
        languagePref: 'id',
        marketingEmailOptIn: true,
      );

      final profile = (await repository.getCurrentProfile()).dataOrNull!;

      expect(profile.id, 'user-1');
      expect(profile.displayName, 'Ayu');
      expect(profile.email, 'user@example.com');
      expect(profile.isAnonymous, isTrue);
      expect(profile.defaultCurrency, 'IDR');
      expect(profile.marketingEmailOptIn, isTrue);
    });

    test('marketing opt-in writes profile before subscriber', () async {
      dataSource.mockCurrentEmail = 'user@example.com';

      final result = await repository.setMarketingEmailOptIn(
        optedIn: true,
        source: 'settings',
        preferredLanguage: 'id',
      );

      expect(result.isSuccess, isTrue);
      final profileWrite = dataSource.lastUpdateFields!;
      expect(profileWrite['marketing_email_opt_in'], isTrue);
      expect(profileWrite['marketing_email_opt_in_source'], 'settings');
      expect(
        DateTime.parse(
          profileWrite['marketing_email_opt_in_at']! as String,
        ).isUtc,
        isTrue,
      );
      expect(dataSource.subscriberEmail, 'user@example.com');
      expect(dataSource.subscriberOptedIn, isTrue);
    });

    test('anonymous profile skips subscriber write', () async {
      dataSource.mockCurrentEmail = null;

      final result = await repository.setMarketingEmailOptIn(
        optedIn: true,
        source: 'settings',
      );

      expect(result.isSuccess, isTrue);
      expect(dataSource.subscriberEmail, isNull);
    });

    test('subscriber failure restores exact previous profile state', () async {
      final previousAt = DateTime.utc(2026, 6, 1, 10);
      dataSource.mockCurrentEmail = 'user@example.com';
      dataSource.mockProfileDto = ProfileDto(
        id: 'user-1',
        marketingEmailOptIn: true,
        marketingEmailOptInAt: previousAt,
        marketingEmailOptInSource: 'registration',
      );
      dataSource.upsertSubscriberThrows =
          const PostgrestException(message: 'subscriber denied');

      final result = await repository.setMarketingEmailOptIn(
        optedIn: false,
        source: 'settings',
      );

      expect(
        result.failureOrNull,
        const Failure.server(message: 'subscriber denied'),
      );
      // First updateFields call writes the new value (optedIn: false)
      final firstWrite = dataSource.updateFieldsCalls.first;
      expect(firstWrite['marketing_email_opt_in'], isFalse);
      // Second updateFields call is the rollback to previous (optedIn: true)
      final rollbackWrite = dataSource.updateFieldsCalls.last;
      expect(rollbackWrite, {
        'marketing_email_opt_in': true,
        'marketing_email_opt_in_at': previousAt.toIso8601String(),
        'marketing_email_opt_in_source': 'registration',
      });
    });

    test(
      'rollback failure does not replace original subscriber failure',
      () async {
        dataSource.mockCurrentEmail = 'user@example.com';
        dataSource.upsertSubscriberThrows =
            const AuthException('subscriber auth failed');
        dataSource.rollbackShouldFail = true;

        final result = await repository.setMarketingEmailOptIn(
          optedIn: true,
          source: 'settings',
        );

        expect(
          result.failureOrNull,
          const Failure.auth('subscriber auth failed'),
        );
        expect(dataSource.updateFieldsCalls.length, 2);
      },
    );
  });

  group('AuthRepositoryImpl', () {
    late _FakeAuthRemoteDataSource dataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeAuthRemoteDataSource();
      repository = AuthRepositoryImpl(dataSource);
    });

    test('delegates current auth properties', () {
      dataSource.mockUserId = 'user-1';
      dataSource.mockEmail = 'user@example.com';
      dataSource.mockIsAnonymous = false;
      dataSource.mockIsEmailConfirmed = true;

      expect(repository.currentUserId, 'user-1');
      expect(repository.currentEmail, 'user@example.com');
      expect(repository.isAnonymous, isFalse);
      expect(repository.isEmailConfirmed, isTrue);
    });

    test('delegates auth streams without wrapping them', () {
      final userIds = Stream<String?>.value('user-1');
      final states = Stream<AuthSnapshot>.value(
        const AuthSnapshot(userId: 'user-1', isAnonymous: false),
      );
      dataSource.mockUserIdStream = userIds;
      dataSource.mockAuthStateStream = states;

      expect(repository.watchUserId(), same(userIds));
      expect(repository.watchAuthState(), same(states));
    });

    test('delegates parameterized sign-up', () async {
      final result = await repository.signUp(
        email: 'user@example.com',
        password: 'secret123',
      );

      expect(result.isSuccess, isTrue);
      expect(dataSource.lastSignUpEmail, 'user@example.com');
      expect(dataSource.lastSignUpPassword, 'secret123');
    });

    test('maps datasource AuthException to AuthFailure', () async {
      dataSource.ensureSignedInThrows = const AuthException('expired session');

      final result = await repository.ensureSignedIn();

      expect(result.failureOrNull, const Failure.auth('expired session'));
    });

    test('maps edge function error while delegating deleteAccount', () async {
      dataSource.deleteAccountThrows = FunctionException(
        status: 503,
        details: 'temporarily unavailable',
      );

      final result = await repository.deleteAccount();

      expect(
        result.failureOrNull,
        const Failure.server(code: 503, message: 'temporarily unavailable'),
      );
      expect(dataSource.deleteAccountCalled, isTrue);
    });
  });

  group('AppConfigRepositoryImpl', () {
    late _FakeAppConfigRemoteDataSource dataSource;
    late AppConfigRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeAppConfigRemoteDataSource();
      repository = AppConfigRepositoryImpl(dataSource);
    });

    test('maps remote rows and caches successful result', () async {
      dataSource.rows = [
        {'key': 'legal.terms_version', 'value': '3'},
        {'key': 'legal.privacy_version', 'value': 4},
      ];

      final first = await repository.getConfig();
      final second = await repository.getConfig();

      expect(first.dataOrNull!.termsVersion, 3);
      expect(first.dataOrNull!.privacyVersion, 4);
      expect(second.dataOrNull, same(first.dataOrNull));
      expect(dataSource.readAllCalls, 1);
    });

    test('coalesces concurrent cold reads into one request', () async {
      final completer = Completer<List<Map<String, dynamic>>>();
      dataSource.readAllCallback = () => completer.future;

      final first = repository.getConfig();
      final second = repository.getConfig();
      completer.complete([
        {'key': 'legal.terms_version', 'value': 5},
        {'key': 'legal.privacy_version', 'value': 6},
      ]);

      final results = await Future.wait([first, second]);
      expect(results.map((r) => r.dataOrNull!.termsVersion), [5, 5]);
      expect(dataSource.readAllCalls, 1);
    });

    test('failed request is not cached and next call retries', () async {
      var calls = 0;
      dataSource.readAllCallback = () async {
        calls++;
        if (calls == 1) throw TimeoutException('slow config');
        return [
          {'key': 'legal.terms_version', 'value': 7},
        ];
      };

      final failed = await repository.getConfig();
      final retried = await repository.getConfig();

      expect(failed.failureOrNull, const Failure.network('slow config'));
      expect(retried.dataOrNull!.termsVersion, 7);
      expect(calls, 2);
    });

    test('invalidate clears cache and forces refetch', () async {
      var version = 1;
      dataSource.readAllCallback = () async => [
        {'key': 'legal.terms_version', 'value': version++},
      ];

      final first = await repository.getConfig();
      repository.invalidate();
      final second = await repository.getConfig();

      expect(first.dataOrNull!.termsVersion, 1);
      expect(second.dataOrNull!.termsVersion, 2);
      expect(dataSource.readAllCalls, 2);
    });
  });
}

class _FakeAppConfigRemoteDataSource implements AppConfigRemoteDataSource {
  List<Map<String, dynamic>> rows = [];
  Future<List<Map<String, dynamic>>> Function()? readAllCallback;
  int readAllCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    readAllCalls++;
    if (readAllCallback != null) return readAllCallback!();
    return rows;
  }
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? mockUserId;
  String? mockEmail;
  bool mockIsAnonymous = false;
  bool mockIsEmailConfirmed = false;
  Stream<String?>? mockUserIdStream;
  Stream<AuthSnapshot>? mockAuthStateStream;
  String? lastSignUpEmail;
  String? lastSignUpPassword;
  Object? ensureSignedInThrows;
  Object? deleteAccountThrows;
  bool deleteAccountCalled = false;

  @override
  String? get currentUserId => mockUserId;

  @override
  String? get currentEmail => mockEmail;

  @override
  bool get isAnonymous => mockIsAnonymous;

  @override
  bool get isEmailConfirmed => mockIsEmailConfirmed;

  @override
  Stream<String?> watchUserId() =>
      mockUserIdStream ?? const Stream<String?>.empty();

  @override
  Stream<AuthSnapshot> watchAuthState() =>
      mockAuthStateStream ?? const Stream<AuthSnapshot>.empty();

  @override
  Future<String> signInAnonymously() async => throw UnimplementedError();

  @override
  Future<String> ensureSignedIn() async {
    if (ensureSignedInThrows != null) throw ensureSignedInThrows!;
    return mockUserId ?? '';
  }

  @override
  Future<void> linkEmail({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp({required String email, required String password}) async {
    lastSignUpEmail = email;
    lastSignUpPassword = password;
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> sendEmailOtp({
    required String email,
    required String languageCode,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> resendEmailChange({required String email}) =>
      throw UnimplementedError();

  @override
  Future<void> recoverSessionFromUri(Uri uri) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
    if (deleteAccountThrows != null) throw deleteAccountThrows!;
  }

  @override
  Future<void> resetPasswordForEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<void> updatePassword(String newPassword) =>
      throw UnimplementedError();
}

class _FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileDto mockProfileDto = const ProfileDto(id: '');
  String? mockCurrentEmail;
  bool mockIsAnonymous = false;
  Map<String, Object?>? lastUpdateFields;
  List<Map<String, Object?>> updateFieldsCalls = [];
  String? subscriberEmail;
  bool? subscriberOptedIn;
  Object? upsertSubscriberThrows;
  bool rollbackShouldFail = false;

  @override
  String? get currentUserId => 'fake-user';

  @override
  String? get currentEmail => mockCurrentEmail;

  @override
  bool get isAnonymous => mockIsAnonymous;

  @override
  Future<ProfileDto> getCurrentProfile() async => mockProfileDto;

  @override
  Future<void> updateField(String column, Object? value) async {
    lastUpdateFields = {column: value};
    updateFieldsCalls.add({column: value});
  }

  @override
  Future<void> updateFields(Map<String, Object?> values) async {
    if (rollbackShouldFail && updateFieldsCalls.length >= 2) {
      throw StateError('rollback failed');
    }
    lastUpdateFields = values;
    updateFieldsCalls.add(values);
  }

  @override
  Future<void> upsertMarketingSubscriber({
    required String email,
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  }) async {
    subscriberEmail = email;
    subscriberOptedIn = optedIn;
    if (upsertSubscriberThrows != null) throw upsertSubscriberThrows!;
  }

  @override
  Future<Map<String, dynamic>> getOcrCreditStatus() async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getMonthlySpendingInsight({
    required String currencyCode,
  }) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getTransferBankInfo() async =>
      throw UnimplementedError();

  @override
  Future<void> updateTransferBankInfo({
    String? bankName,
    String? accountName,
    String? accountNumber,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> touchLastActive() async {}
}