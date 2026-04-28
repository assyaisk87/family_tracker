import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_user_model.freezed.dart';

@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String email,
    String? familyId,
  }) = _AuthUserModel;

  const AuthUserModel._();

  factory AuthUserModel.fromDomain(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      email: user.email,
      familyId: user.familyId,
    );
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      familyId: familyId,
    );
  }
}