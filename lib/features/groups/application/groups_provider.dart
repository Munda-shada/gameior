import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/features/groups/data/groups_repository.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'groups_provider.g.dart';

@riverpod
class MyGroupsNotifier extends _$MyGroupsNotifier {
  @override
  Future<List<GroupSummary>> build() async {
    return ref.watch(groupsRepositoryProvider).fetchMyGroups();
  }
}