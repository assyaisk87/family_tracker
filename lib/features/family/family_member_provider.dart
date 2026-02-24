import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyMemberProvider =
    FutureProvider.family<FamilyMember, int>((ref, memberId) async {
  final repo = ref.read(familyRepositoryProvider);
  return repo.getFamilyMember(memberId);
});