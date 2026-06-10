import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/models/enums.dart';

class MockPaymentsRepository extends Mock implements PaymentsRepository {}

void main() {
  late MockPaymentsRepository mockRepo;
  late ProviderContainer container;
  const groupId = 'group-123';

  final sampleDues = [
    PaymentDue(
      id: 'due-1',
      gameId: 'game-1',
      groupId: groupId,
      playerId: 'player-1',
      paymentOwnerId: 'owner-1',
      amountPaise: 50000,
      status: DueStatus.unpaid,
      rejectionCount: 0,
      createdAt: DateTime.now(),
      profiles: const {
        'display_name': 'Alice',
        'emoji': '🏸',
      },
      games: {
        'title': 'Saturday Smash',
        'scheduled_at': DateTime.now().toUtc().toIso8601String(),
      },
    ),
    PaymentDue(
      id: 'due-2',
      gameId: 'game-1',
      groupId: groupId,
      playerId: 'player-2',
      paymentOwnerId: 'owner-1',
      amountPaise: 50000,
      status: DueStatus.pendingVerification,
      utrReference: '123456789012',
      submittedAt: DateTime.now(),
      rejectionCount: 0,
      createdAt: DateTime.now(),
      profiles: const {
        'display_name': 'Bob',
        'emoji': '🏀',
      },
      games: {
        'title': 'Saturday Smash',
        'scheduled_at': DateTime.now().toUtc().toIso8601String(),
      },
    ),
  ];

  setUp(() {
    mockRepo = MockPaymentsRepository();
    container = ProviderContainer(
      overrides: [
        paymentsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AdminDuesNotifier', () {
    test('fetches dues for group successfully', () async {
      when(() => mockRepo.fetchDuesAsOwner(groupId: groupId))
          .thenAnswer((_) async => sampleDues);

      final subscription = container.listen(
        adminDuesNotifierProvider(groupId),
        (previous, next) {},
      );

      expect(container.read(adminDuesNotifierProvider(groupId)), const AsyncLoading<List<PaymentDue>>());

      final dues = await container.read(adminDuesNotifierProvider(groupId).future);
      expect(dues, sampleDues);

      subscription.close();
    });

    test('approve calls repository and invalidates provider', () async {
      when(() => mockRepo.fetchDuesAsOwner(groupId: groupId))
          .thenAnswer((_) async => sampleDues);
      when(() => mockRepo.approveDue('due-2')).thenAnswer((_) async {});

      final notifier = container.read(adminDuesNotifierProvider(groupId).notifier);
      await container.read(adminDuesNotifierProvider(groupId).future);

      await notifier.approve('due-2');

      verify(() => mockRepo.approveDue('due-2')).called(1);
    });

    test('reject calls repository and invalidates provider', () async {
      when(() => mockRepo.fetchDuesAsOwner(groupId: groupId))
          .thenAnswer((_) async => sampleDues);
      when(() => mockRepo.rejectDue('due-2')).thenAnswer((_) async {});

      final notifier = container.read(adminDuesNotifierProvider(groupId).notifier);
      await container.read(adminDuesNotifierProvider(groupId).future);

      await notifier.reject('due-2');

      verify(() => mockRepo.rejectDue('due-2')).called(1);
    });
  });

  group('adminDuesByPlayer and adminDuesByGame', () {
    test('groups dues by player correctly', () async {
      when(() => mockRepo.fetchDuesAsOwner(groupId: groupId))
          .thenAnswer((_) async => sampleDues);

      final summaries = await container.read(adminDuesByPlayerProvider(groupId).future);

      expect(summaries.length, 2);
      expect(summaries[0].playerName, 'Alice');
      expect(summaries[0].totalPendingPaise, 50000);
      expect(summaries[1].playerName, 'Bob');
      expect(summaries[1].totalPendingPaise, 50000);
    });

    test('groups dues by game correctly', () async {
      when(() => mockRepo.fetchDuesAsOwner(groupId: groupId))
          .thenAnswer((_) async => sampleDues);

      final summaries = await container.read(adminDuesByGameProvider(groupId).future);

      expect(summaries.length, 1);
      expect(summaries[0].gameTitle, 'Saturday Smash');
      expect(summaries[0].totalPendingPaise, 100000);
      expect(summaries[0].playerDues.length, 2);
    });
  });
}
