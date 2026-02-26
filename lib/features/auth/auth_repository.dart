import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient client;

  AuthRepository(this.client);

  Future<void> signUpEmail(String email, String password) async {
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signInEmail(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInAnonymously() async {
    await client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  Stream<User?> onAuthStateChange() {
    return client.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}
