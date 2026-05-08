// presentation/cubit/edit_family_member_state.dart

import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member_state.freezed.dart';

enum EditFamilyMemberStatus {initial, loading, success, error}

@freezed
abstract class EditFamilyMemberState with _$EditFamilyMemberState {

  const factory EditFamilyMemberState({
    @Default(EditFamilyMemberStatus.initial)  EditFamilyMemberStatus status,
   FamilyUser? updatedUser,
   String? errorMessage,
  }) = _EditFamilyMemberState;


}