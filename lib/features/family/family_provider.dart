import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/model/family.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyProvider = FutureProvider.family<FamilyModel, int>((ref, familyId) async {
  final repo = ref.read(familyRepositoryProvider);
  return repo.fetchFamily(familyId);
});