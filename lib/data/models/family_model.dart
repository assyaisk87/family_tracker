import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/family.dart';

part 'family_model.freezed.dart';

@freezed
class FamilyModel with _$FamilyModel {
  const factory FamilyModel({
    required String id,
    required String name,
    required String inviteCode,
    required DateTime createdAt,
  }) = _FamilyModel;

  const FamilyModel._();

  factory FamilyModel.fromDomain(Family family) {
    return FamilyModel(
      id: family.id,
      name: family.name,
      inviteCode: family.inviteCode,
      createdAt: family.createdAt,
    );
  }

  Family toDomain() {
    return Family(
      id: id,
      name: name,
      inviteCode: inviteCode,
      createdAt: createdAt,
    );
  }
}