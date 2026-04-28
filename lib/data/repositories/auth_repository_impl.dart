import 'package:family_tracker/domain/entities/auth_user.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:supabase/supabase.dart' hide AuthUser;

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<AuthUser?> getCurrentUserWithFamily() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('family_members')
          .select('id, family_id')
          .eq('user_id', user.id)
          .maybeSingle();

      return AuthUser(
        id: response?['id']?.toString() ?? user.id,
        email: user.email!,
        familyId: response?['family_id']?.toString(),
      );
    } catch (e) {
      // Если не удалось получить family_id, возвращаем пользователя без него
      return AuthUser(id: user.id, email: user.email!);
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

      try {
        final response = await _client
            .from('family_members')
            .select('id, family_id')
            .eq('user_id', user.id)
            .maybeSingle();

        return AuthUser(
          id: response?['id']?.toString() ?? user.id,
          email: user.email!,
          familyId: response?['family_id']?.toString(),
        );
      } catch (e) {
        return AuthUser(id: user.id, email: user.email!);
      }
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return AuthUser(id: user.id, email: user.email!);
  }
}