import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/family_user.dart';

part 'family_user_model.freezed.dart';

@freezed
class FamilyUserModel with _$FamilyUserModel {
  const factory FamilyUserModel({
    required String id,
    required String familyId,
    required String userId,
    required bool role,
    required String displayName,
    required String avatarUrl,
  }) = _FamilyUserModel;

  const FamilyUserModel._();

  factory FamilyUserModel.fromDomain(FamilyUser user) {
    return FamilyUserModel(
      id: user.id,
      familyId: user.familyId,
      userId: user.userId,
      role: user.role,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );
  }

  FamilyUser toDomain() {
    return FamilyUser(
      id: id,
      familyId: familyId,
      userId: userId,
      role: role,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
