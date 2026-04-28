

import 'package:family_tracker/domain/entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  Future<AuthUser?> getCurrentUserWithFamily();
  Stream<AuthUser?> get authStateChanges;

  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}