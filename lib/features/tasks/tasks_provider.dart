
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/features/tasks/task_repository_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tasksProvider = FutureProvider<List<Task>>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  final session = ref.watch(sessionProvider).value!;
  return repo.fetchTasks(session.member!.familyId);
});