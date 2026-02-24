import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  final _client = Supabase.instance.client;

  bool get isLoading => state;

  Future<String?> signUpEmail(String email, String password) async {
    try {
      state = true;
      await _client.auth.signUp(email: email, password: password);
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
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = false;
    }
  }

  Future<void> signInAnon() async {
    await _client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});
