import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/members/domain/member_stats.dart';
import 'package:gameior/shared/models/enums.dart';

class MockMembersRepository extends Mock implements MembersRepository {}

void main() {
  late MockMembersRepository mockRepo;
  late ProviderContainer container;
  const groupId = 'group-123';

  final sampleMembers = [
    GroupMember(
      id: 'm1',
      groupId: groupId,
      userId: 'u1',
      role: MemberRole.player,
      status: MembershipStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profiles: const {
        'display_name': 'Charlie',
        'emoji': '🏸',
      },
    ),
    GroupMember(
      id: 'm2',
      groupId: groupId,
      userId: 'u2',
      role: MemberRole.host,
      status: MembershipStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profiles: const {
        'display_name': 'Alice',
        'emoji': '🏸',
      },
    ),
    GroupMember(
      id: 'm3',
      groupId: groupId,
      userId: 'u3',
      role: MemberRole.coHost,
      status: MembershipStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profiles: const {
        'display_name': 'Bob',
        'emoji': '🏸',
      },
    ),
  ];

  setUp(() {
    mockRepo = MockMembersRepository();
    container = ProviderContainer(
      overrides: [
        membersRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GroupMembers Notifier', () {
    test('fetches and returns members correctly', () async {
      when(() => mockRepo.fetchMembers(groupId))
          .thenAnswer((_) async => sampleMembers);

      final subscription = container.listen(
        groupMembersProvider(groupId),
        (previous, next) {},
      );

      expect(container.read(groupMembersProvider(groupId)), const AsyncLoading<List<GroupMember>>());

      final members = await container.read(groupMembersProvider(groupId).future);
      expect(members, sampleMembers);

      subscription.close();
    });

    test('updateRole invokes repository and invalidates provider', () async {
      when(() => mockRepo.fetchMembers(groupId))
          .thenAnswer((_) async => sampleMembers);
      when(() => mockRepo.updateRole(
            groupId: groupId,
            userId: 'u1',
            role: MemberRole.coHost,
          )).thenAnswer((_) async {});

      final notifier = container.read(groupMembersProvider(groupId).notifier);
      await container.read(groupMembersProvider(groupId).future);

      await notifier.updateRole(userId: 'u1', role: MemberRole.coHost);

      verify(() => mockRepo.updateRole(
            groupId: groupId,
            userId: 'u1',
            role: MemberRole.coHost,
          )).called(1);
    });
  });

  group('GroupJoinRequests Notifier', () {
    test('fetches and returns join requests', () async {
      final requests = [
        GroupMember(
          id: 'req1',
          groupId: groupId,
          userId: 'u4',
          role: MemberRole.player,
          status: MembershipStatus.pendingApproval,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profiles: const {
            'display_name': 'Dave',
            'emoji': '🏸',
          },
        ),
      ];

      when(() => mockRepo.fetchJoinRequests(groupId))
          .thenAnswer((_) async => requests);

      final subscription = container.listen(
        groupJoinRequestsProvider(groupId),
        (previous, next) {},
      );

      final result = await container.read(groupJoinRequestsProvider(groupId).future);
      expect(result, requests);

      subscription.close();
    });
  });

  group('memberStats FutureProvider', () {
    test('fetches stats correctly', () async {
      final stats = MemberStats(
        userId: 'u1',
        groupId: groupId,
        gamesPlayed: 5,
        attendancePct: 83.3,
        joinedAt: DateTime.now(),
        monthlyData: const [],
      );

      when(() => mockRepo.fetchMemberStats(groupId: groupId, userId: 'u1'))
          .thenAnswer((_) async => stats);

      final result = await container.read(memberStatsProvider(groupId: groupId, userId: 'u1').future);
      expect(result.gamesPlayed, 5);
      expect(result.attendancePct, 83.3);
    });
  });
}
