import 'package:family_tracker/features/tasks/filter/task_filter_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredTasksProvider = FutureProvider<List<Task>>((ref) async {
  final tasks = await ref.watch(tasksProvider.future);
  final filter = ref.watch(taskFilterProvider);

  var result = tasks;

  if (filter.assigneeId != 0) {
    result = result
        .where((task) =>
            task.assignees.contains(filter.assigneeId))
        .toList();
  }

  result.sort((a, b) {
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;

    return filter.sortByDateAsc
        ? a.dueDate!.compareTo(b.dueDate!)
        : b.dueDate!.compareTo(a.dueDate!);
  });

  return result;
});
