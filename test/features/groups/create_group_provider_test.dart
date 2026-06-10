import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gameior/features/groups/application/create_group_provider.dart';
import 'package:gameior/features/groups/data/groups_repository.dart';
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

  group('CreateGroupNotifier', () {
    test('initial state is correct', () {
      final state = container.read(createGroupNotifierProvider);
      expect(state.currentStep, 1);
      expect(state.name, '');
      expect(state.isSubmitting, false);
    });

    test('nextStep and prevStep navigate correctly within bounds', () {
      final notifier = container.read(createGroupNotifierProvider.notifier);

      notifier.nextStep();
      expect(container.read(createGroupNotifierProvider).currentStep, 2);

      notifier.nextStep();
      expect(container.read(createGroupNotifierProvider).currentStep, 3);

      notifier.nextStep();
      expect(container.read(createGroupNotifierProvider).currentStep, 4);

      notifier.nextStep(); // clamped
      expect(container.read(createGroupNotifierProvider).currentStep, 4);

      notifier.prevStep();
      expect(container.read(createGroupNotifierProvider).currentStep, 3);
    });

    test('update methods update form state successfully', () {
      final notifier = container.read(createGroupNotifierProvider.notifier);

      notifier.updateName('Slammers Badminton');
      notifier.updateSport(SportType.badminton);
      notifier.updateDescription('Weekly badminton session');

      final state = container.read(createGroupNotifierProvider);
      expect(state.name, 'Slammers Badminton');
      expect(state.sport, SportType.badminton);
      expect(state.description, 'Weekly badminton session');
    });

    test('submit returns group ID on success', () async {
      const expectedGroupId = 'new-group-uuid-123';
      registerFallbackValue(const CreateGroupFormState());
      
      when(() => mockRepo.createGroup(any())).thenAnswer((_) async => expectedGroupId);

      final notifier = container.read(createGroupNotifierProvider.notifier);
      final result = await notifier.submit();

      expect(result, expectedGroupId);
      expect(container.read(createGroupNotifierProvider).isSubmitting, false);
      expect(container.read(createGroupNotifierProvider).error, null);
    });

    test('submit sets error on repository exception', () async {
      registerFallbackValue(const CreateGroupFormState());
      
      when(() => mockRepo.createGroup(any())).thenThrow(Exception('DB error'));

      final notifier = container.read(createGroupNotifierProvider.notifier);
      final result = await notifier.submit();

      expect(result, null);
      expect(container.read(createGroupNotifierProvider).isSubmitting, false);
      expect(container.read(createGroupNotifierProvider).error, 'Failed to create group. Try again.');
    });
  });
}
