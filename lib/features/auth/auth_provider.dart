import 'package:family_tracker/features/auth/auth_repository.dart';
import 'package:family_tracker/features/auth/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepo);
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(false);

  bool get isLoading => state;

  Future<String?> signUpEmail(String email, String password) async {
    try {
      state = true;
      await _authRepository.signUpEmail(email, password);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = false;
    }
  }

  Future<String?> signInEmail(String email, String password) async {
    try {
      state = true;
      await _authRepository.signInEmail(email, password);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = false;
    }
  }

  Future<void> signInAnon() async {
    await _authRepository.signInAnonymously();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.onAuthStateChange();
});
