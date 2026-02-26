import 'package:family_tracker/features/auth/auth_repository_provider.dart';
import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/features/session/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionProvider = StreamProvider<SessionData?>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final familyRepo = ref.read(familyRepositoryProvider);

  return authRepo.onAuthStateChange().asyncMap((user) async {
    if (user == null) return null;

    try {
      // Получаем member по user_id через репозиторий
      final member = await familyRepo.fetchFamilyMemberByUserId(user.id);

      if (member == null) {
        return SessionData(user: user);
      }

      // Загружаем семью через репозиторий
      final family = await familyRepo.fetchFamily(member.familyId);

      return SessionData(
        user: user,
        member: member,
        family: family,
        myMemberId: member.id,
      );
    } catch (e) {
      return null;
    }
  });
});
