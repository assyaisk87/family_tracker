import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { initial, loading, loaded, error }

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    User? user,
    @Default([]) List<FamilyUser> familyMembers,
    String? currentUserId,
    @Default(false) bool currentUserIsParent,
    String? errorMessage,
  }) = _ProfileState;
}
