import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final sessionAsync = ref.watch(sessionProvider);

  return sessionAsync.when(
    data: (session) async {
      if (session == null || session.family == null) {
        return [];
      }

      final repo = ref.read(familyRepositoryProvider);
      return repo.fetchFamilyMembers(session.family!.id);
    },
    loading: () async => [],
    error: (_, _) async => [],
  );
});
