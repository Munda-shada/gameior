import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockFunctionsClient extends Mock implements FunctionsClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  final T Function() getValue;
  FakePostgrestFilterBuilder(this.getValue);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(onValue(getValue()));
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockFunctionsClient mockFunctions;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late ProfileRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockFunctions = MockFunctionsClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    repository = ProfileRepository(mockClient);

    when(() => mockClient.functions).thenReturn(mockFunctions);
  });

  group('ProfileRepository', () {
    test('deleteAccount invokes delete_account edge function', () async {
      when(() => mockFunctions.invoke('delete_account'))
          .thenAnswer((_) async => FunctionResponse(data: {'deleted': true}, status: 200));

      await repository.deleteAccount();

      verify(() => mockFunctions.invoke('delete_account')).called(1);
    });

    test('fetchHostedGroupsWithCoHosts queries groups and group_members', () async {
      final sampleGroups = [
        {'id': 'g1', 'name': 'Badminton Club'},
      ];
      final sampleCoHosts = [
        {
          'id': 'm1',
          'user_id': 'cohost-123',
          'profiles': {'display_name': 'CoHost User'}
        }
      ];

      var callCount = 0;
      final fakeFilterBuilder = FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(() {
        if (callCount == 0) {
          callCount++;
          return sampleGroups;
        } else {
          return sampleCoHosts;
        }
      });

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => fakeFilterBuilder);

      final result = await repository.fetchHostedGroupsWithCoHosts('user-123');

      expect(result.length, 1);
      expect(result[0]['id'], 'g1');
      expect(result[0]['name'], 'Badminton Club');
      expect(result[0]['co_hosts'].length, 1);
      expect(result[0]['co_hosts'][0]['user_id'], 'cohost-123');
      expect(result[0]['co_hosts'][0]['display_name'], 'CoHost User');
    });
  });
}
