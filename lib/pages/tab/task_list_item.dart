import 'package:family_tracker/core/theme/app_colors.dart';
import 'package:family_tracker/features/tasks/task_repository_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:family_tracker/model/task.dart';
import 'package:family_tracker/pages/tab/task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;
  final FamilyMember? creator;
  final Map<int, FamilyMember> membersMap;
  final int mySessionMemberId;
  final int memberId;
  final int familyId;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.creator,
    required this.membersMap,
    required this.mySessionMemberId,
    required this.memberId,
    required this.familyId,
  }) : super(key: key);

  bool get _isExpired {
    final due = task.dueDate?.toLocal();
    if (due == null) return false;
    final today = DateTime.now();
    return DateTime(due.year, due.month, due.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  bool get _canDelete {
    // Может удалить создатель или любой из исполнителей, имеющий роль родителя
    if (task.createdBy == mySessionMemberId) return true;
    
    for (int assigneeId in task.assignees) {
      final assignee = membersMap[assigneeId];
      if (assignee?.role == true) return true;
    }
    return false;
  }

  Future<void> _deleteTask(WidgetRef ref) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteTask(task.id);
    ref.invalidate(tasksProvider);
  }

  Future<void> _toggleTask(WidgetRef ref) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleTask(task.id, !task.completed);
    ref.invalidate(tasksProvider);
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить задачу?"),
        content: const Text("Это действие нельзя отменить."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Удалить"),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteTask(ref);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = _isExpired ? Colors.red : AppColors.primary;

    return Dismissible(
      key: ValueKey(task.id),
      direction: _canDelete ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        _showDeleteConfirm(context, ref);
        return false;
      },
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TaskDialog(
              task: task,
              memberId: memberId,
              familyId: familyId,
              mySessionMemberId: mySessionMemberId,
            ),
          );
        },
        leading: Tooltip(
            message: creator?.displayName ?? '',
            // default behavior shows on hover (web/desktop) and long press (mobile)
            child: CircleAvatar(
              backgroundImage: creator?.avatarUrl != null && creator!.avatarUrl.isNotEmpty
                  ? NetworkImage(creator!.avatarUrl)
                  : null,
              backgroundColor: AppColors.primary,
              child: (creator?.avatarUrl == null || creator!.avatarUrl.isEmpty)
                  ? Text(
                      creator?.displayName != null && creator!.displayName!.isNotEmpty
                          ? creator!.displayName!.substring(0,2).toUpperCase()
                          : '',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
          ),
        title: Text(
          '${task.title} - ${task.assignees.isNotEmpty ? task.assignees.map((id) => membersMap[id]?.displayName ?? '').join(', ') : 'Не назначено'}',
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(
          "До: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? ''}",
          style: TextStyle(color: textColor),
        ),
        trailing: Checkbox(
          value: task.completed,
          onChanged: (_) => _toggleTask(ref),
        ),
      ),
    );
  }
}
