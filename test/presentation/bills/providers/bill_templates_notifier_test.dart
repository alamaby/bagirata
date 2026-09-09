import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/bill_template.dart';
import 'package:bagistruk/presentation/bills/providers/bill_templates_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../bill_review_notifier_save_test.mocks.dart';

void main() {
  late MockIBillRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    provideDummy<Result<void>>(const Result.success(null));
    provideDummy<Result<List<BillTemplate>>>(
      const Result.success(<BillTemplate>[]),
    );
    provideDummy<Result<String>>(const Result.success('template-id'));
  });

  setUp(() {
    mockRepo = MockIBillRepository();
    when(
      mockRepo.ensureSignedIn(),
    ).thenAnswer((_) async => const Result.success(null));
    when(mockRepo.listTemplates()).thenAnswer(
      (_) async => const Result.success(<BillTemplate>[]),
    );
    container = ProviderContainer(
      overrides: [billRepositoryProvider.overrideWithValue(mockRepo)],
    );
    final sub = container.listen(billTemplatesProvider, (_, _) {});
    addTearDown(sub.close);
  });

  tearDown(() {
    container.dispose();
  });

  BillTemplates notifier() =>
      container.read(billTemplatesProvider.notifier);

  group('BillTemplates.createFromBill session guard', () {
    test('ensures a session before the RPC', () async {
      when(
        mockRepo.createTemplateFromBill(
          billId: anyNamed('billId'),
          name: anyNamed('name'),
        ),
      ).thenAnswer((_) async => const Result.success('template-id'));

      final result = await notifier().createFromBill(
        billId: 'bill-1',
        name: 'Kos',
      );

      expect(result.ok, isTrue);
      verify(mockRepo.ensureSignedIn()).called(1);
      verify(
        mockRepo.createTemplateFromBill(
          billId: anyNamed('billId'),
          name: anyNamed('name'),
        ),
      ).called(1);
    });

    test('sign-in failure surfaces failed without RPC', () async {
      when(mockRepo.ensureSignedIn()).thenAnswer(
        (_) async => const Result.failure(Failure.auth('no session')),
      );

      final result = await notifier().createFromBill(
        billId: 'bill-1',
        name: 'Kos',
      );

      expect(result.ok, isFalse);
      expect(result.failed, isTrue);
      expect(result.limited, isFalse);
      verifyNever(
        mockRepo.createTemplateFromBill(
          billId: anyNamed('billId'),
          name: anyNamed('name'),
        ),
      );
    });

    test('limit failure still maps to limited', () async {
      when(
        mockRepo.createTemplateFromBill(
          billId: anyNamed('billId'),
          name: anyNamed('name'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          Failure.server(code: 400, message: 'template_limit: free cap'),
        ),
      );

      final result = await notifier().createFromBill(
        billId: 'bill-1',
        name: 'Kos',
      );

      expect(result.ok, isFalse);
      expect(result.limited, isTrue);
    });
  });

  group('BillTemplates.instantiate session guard', () {
    test('sign-in failure returns null without RPC', () async {
      when(mockRepo.ensureSignedIn()).thenAnswer(
        (_) async => const Result.failure(Failure.auth('no session')),
      );

      expect(await notifier().instantiate('template-id'), isNull);
      verifyNever(mockRepo.instantiateTemplate(any));
    });
  });
}
