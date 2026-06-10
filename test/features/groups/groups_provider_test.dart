import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/data/groups_repository.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/shared/models/enums.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late MockGroupsRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockGroupsRepository();
    container = ProviderContainer(
      overrides: [
        groupsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MyGroupsNotifier', () {
    test('fetches my groups successfully', () async {
      final mockGroups = [
        const GroupSummary(
          id: 'group-1',
          name: 'Badminton Club',
          sport: SportType.badminton,
          myRole: MemberRole.host,
          myStatus: MembershipStatus.active,
          memberCount: 15,
          pendingDuesPaise: 0,
          pendingFromPlayersPaise: 50000,
          hasUpcomingSessions: true,
        ),
      ];

      when(() => mockRepo.fetchMyGroups()).thenAnswer((_) async => mockGroups);

      // Trigger build
      final subscription = container.listen(
        myGroupsNotifierProvider,
        (previous, next) {},
      );

      // Verify initial loading state
      expect(container.read(myGroupsNotifierProvider), const AsyncLoading<List<GroupSummary>>());

      // Wait for fetch
      await container.read(myGroupsNotifierProvider.future);

      // Verify loaded data
      expect(
        container.read(myGroupsNotifierProvider),
        AsyncData<List<GroupSummary>>(mockGroups),
      );
      
      subscription.close();
    });

    test('exposes AsyncError when fetch fails', () async {
      final exception = Exception('Connection failed');
      when(() => mockRepo.fetchMyGroups()).thenThrow(exception);

      // Trigger build
      final subscription = container.listen(
        myGroupsNotifierProvider,
        (previous, next) {},
      );

      // Wait for completion (which fails)
      try {
        await container.read(myGroupsNotifierProvider.future);
      } catch (_) {}

      // Verify error state
      expect(
        container.read(myGroupsNotifierProvider).hasError,
        true,
      );
      expect(
        container.read(myGroupsNotifierProvider).error,
        exception,
      );

      subscription.close();
    });
  });
}
