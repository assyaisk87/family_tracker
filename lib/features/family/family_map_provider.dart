import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyMembersMapProvider =
    Provider<Map<int, FamilyMember>>((ref) {
  final membersAsync = ref.watch(familyMembersProvider);

  return membersAsync.maybeWhen(
    data: (members) {
      return {
        for (final m in members) m.id: m,
      };
    },
    orElse: () => {},
  );
});
