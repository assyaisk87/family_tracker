import 'package:family_tracker/features/family/family_map_provider.dart';
import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/features/tasks/filter/filtered_tasks_provider.dart';
import 'package:family_tracker/features/tasks/filter/task_filter_provider.dart';
import 'package:family_tracker/features/tasks/task_repository_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tasks extends ConsumerWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final session = ref.watch(sessionProvider).value!;
    final memberId = session.member!.id;
    final familyId = session.member!.familyId;
    final repo = ref.read(taskRepositoryProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final filter = ref.watch(taskFilterProvider);

    Future<void> createTask(
      String title,
      String? description,
      DateTime date,
      int assignedMemberId,
    ) async {
      await repo.createTask(
        familyId: familyId,
        createdBy: memberId,
        title: title,
        description: description,
        dueDate: date,
        memberIds: [assignedMemberId],
      );

      ref.invalidate(tasksProvider);
    }

    Future<void> updateTask(
      Task task,
      String title,
      String? description,
      DateTime date,
      int assignedMemberId,
    ) async {
      await repo.updateTask(
        taskId: task.id,
        title: title,
        description: description,
        dueDate: date,
        memberIds: [assignedMemberId],
      );

      ref.invalidate(tasksProvider);
    }

    Future<void> deleteTask(int id) async {
      await repo.deleteTask(id);
      ref.invalidate(tasksProvider);
    }

    Future<void> toggleTask(Task task) async {
      await repo.toggleTask(task.id, !task.completed);
      ref.invalidate(tasksProvider);
    }

    void showTaskDialog({Task? task}) {
      final titleController = TextEditingController(text: task?.title ?? '');
      final descController = TextEditingController(
        text: task?.description ?? '',
      );

      DateTime selectedDate = task?.dueDate ?? DateTime.now();

      int? assignedTo = task?.assignees.isNotEmpty == true
          ? task!.assignees.first
          : null;

      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                task == null ? "Создать задачу" : "Редактировать задачу",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Название:"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Описание:"),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      "Срок до: ${selectedDate.toLocal().toString().split(' ')[0]}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final membersAsync = ref.watch(familyMembersProvider);

                      return membersAsync.when(
                        data: (members) {
                          return DropdownButton<int>(
                            isExpanded: true,
                            value: assignedTo,
                            hint: const Text("Назначить участнику"),
                            items: members
                                .map(
                                  (m) => DropdownMenuItem<int>(
                                    value: m.id, // bigint → int
                                    child: Text(m.displayName ?? ""),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                assignedTo = val;
                              });
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, _) => const Text("Ошибка"),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (assignedTo == null || titleController.text.isEmpty) {
                      return;
                    }

                    if (task == null) {
                      await createTask(
                        titleController.text,
                        descController.text,
                        selectedDate,
                        assignedTo!,
                      );
                    } else {
                      await updateTask(
                        task,
                        titleController.text,
                        descController.text,
                        selectedDate,
                        assignedTo!,
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Сохранить"),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Задачи')),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text("Нет задач"));
          }
final membersMap = ref.watch(familyMembersMapProvider);
          return Column(
            children: [
              // фильтр
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  membersAsync.when(
                    data: (members) {
                      return DropdownButton<int?>(
                        value: filter.assigneeId,
                        hint: const Text("Все исполнители"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: 0,
                            child: Text("Все"),
                          ),
                          ...members.map((member) {
                            return DropdownMenuItem<int?>(
                              value: member.id,
                              child: Text(member.displayName ?? '-'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          ref.read(taskFilterProvider.notifier).state = filter
                              .copyWith(assigneeId: value);
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => const Text("Ошибка"),
                  ),
                  IconButton(
                    icon: Icon(
                      filter.sortByDateAsc
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      ref.read(taskFilterProvider.notifier).state = filter
                          .copyWith(sortByDateAsc: !filter.sortByDateAsc);
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final due = task.dueDate?.toLocal();
                    final today = DateTime.now();
                    final creator = membersMap[task.createdBy];
          final assignee =
              membersMap[task.assignees.first];

                    final isExpired =
                        due != null &&
                        DateTime(due.year, due.month, due.day).isBefore(
                          DateTime(today.year, today.month, today.day),
                        );
                   

                                   
                        final canDelete =
                            task.createdBy == session.myMemberId ||
                            assignee?.role == true;
                        // удаление по свайпу
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: canDelete
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Удалить задачу?"),
                                content: const Text(
                                  "Это действие нельзя отменить.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Отмена"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Удалить"),
                                  ),
                                ],
                              ),
                            );

                            if (result == true) {
                              await deleteTask(task.id);
                            }

                            return result ?? false;
                          },
                          child: ListTile(
                            // редактирование
                            onTap: () {
                              showTaskDialog(task: task);
                            },
                            leading: CircleAvatar(
                              backgroundImage: creator?.avatarUrl != null &&
                                creator!.avatarUrl.isNotEmpty ? NetworkImage(creator.avatarUrl): null,
                            ),
                            title: Text(
                              '${task.title} - ${assignee?.displayName}',
                              style: TextStyle(
                                color: isExpired
                                    ? Colors.red
                                    : Colors.black, // или AppColors.text
                              ),
                            ),
                            subtitle: Text(
                              "До: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? ''}",
                              style: TextStyle(
                                color: isExpired
                                    ? Colors.red
                                    : Colors.black, // или AppColors.text
                              ),
                            ),
                            trailing: Checkbox(
                              value: task.completed,
                              onChanged: (_) async {
                                await toggleTask(task);
                              },
                            ),
                          ),
                        );
                     
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Ошибка: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
