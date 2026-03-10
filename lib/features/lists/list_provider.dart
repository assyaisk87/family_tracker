
import 'package:family_tracker/features/lists/list_repository_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/model/list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listsProvider = FutureProvider<List<Lists>>((ref) {
  final repo = ref.read(listRepositoryProvider);
  final session = ref.watch(sessionProvider).value!;
  return repo.fetchLists(session.member!.familyId);
});