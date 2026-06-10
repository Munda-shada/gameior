import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/features/groups/data/groups_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'create_group_provider.freezed.dart';
part 'create_group_provider.g.dart';

@freezed
abstract class CreateGroupFormState with _$CreateGroupFormState {
  const factory CreateGroupFormState({
    @Default(1) int currentStep,
    // Step 1
    @Default('') String name,
    SportType? sport,
    @Default('') String description,
    // Step 2
    @Default('') String defaultVenue,
    @Default('') String mapsLink,
    // Step 3
    @Default(20) int maxCapacity,
    @Default(PaymentModel.prepaid) PaymentModel paymentModel,
    @Default(0) int defaultCostPaise,
    @Default('') String defaultUpiId,
    @Default('') String clubRules,
    // Step 4
    @Default(true)  bool requireApproval,
    @Default(true)  bool allowMemberInvites,
    @Default(true)  bool allowGuests,
    // Submission
    @Default(false) bool isSubmitting,
    String? error,
  }) = _CreateGroupFormState;
}

@riverpod
class CreateGroupNotifier extends _$CreateGroupNotifier {
  @override
  CreateGroupFormState build() => const CreateGroupFormState();

  void nextStep() => state = state.copyWith(
    currentStep: (state.currentStep + 1).clamp(1, 4));
  void prevStep() => state = state.copyWith(
    currentStep: (state.currentStep - 1).clamp(1, 4));

  void updateName(String v)         => state = state.copyWith(name: v);
  void updateSport(SportType v)     => state = state.copyWith(sport: v);
  void updateDescription(String v)  => state = state.copyWith(description: v);
  void updateDefaultVenue(String v) => state = state.copyWith(defaultVenue: v);
  void updateMapsLink(String v)     => state = state.copyWith(mapsLink: v);
  void updateMaxCapacity(int v)     => state = state.copyWith(maxCapacity: v);
  void updatePaymentModel(PaymentModel v) => state = state.copyWith(paymentModel: v);
  void updateDefaultCost(int v)     => state = state.copyWith(defaultCostPaise: v);
  void updateDefaultUpiId(String v) => state = state.copyWith(defaultUpiId: v);
  void updateClubRules(String v)    => state = state.copyWith(clubRules: v);
  void updateRequireApproval(bool v)=> state = state.copyWith(requireApproval: v);
  void updateAllowMemberInvites(bool v) => state = state.copyWith(allowMemberInvites: v);
  void updateAllowGuests(bool v)    => state = state.copyWith(allowGuests: v);

  Future<String?> submit() async {
    // Returns group ID on success, null on failure
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final groupId = await ref
          .read(groupsRepositoryProvider)
          .createGroup(state);
      return groupId;
    } catch (e) {
      state = state.copyWith(isSubmitting: false,
          error: 'Failed to create group. Try again.');
      return null;
    }
  }
}
