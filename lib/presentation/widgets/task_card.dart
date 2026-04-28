import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onTap, required this.onToggle});

  String get assigneesText {
    if (task.assignees.isEmpty) return 'Нет исполнителей';
    if (task.assignees.length == 1) return 'Исполнитель: ${task.assignees.first.displayName}';
    return 'Исполнители: ${task.assignees.map((a) => a.displayName).join(', ')}';
  }

  String get statusLabel => task.completed ? 'Выполнено' : 'В работе';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: task.completed ? Colors.green : Colors.blue,
          child: Icon(task.completed ? Icons.check : Icons.assignment, color: Colors.white,),
        ),
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null)
              Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(assigneesText, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (task.dueDate != null)
              Text('Срок до: ${task.dueDate!.day}.${task.dueDate!.month}.${task.dueDate!.year}'),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(statusLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: task.completed ? Colors.green : Colors.black54)),
            const SizedBox(height: 4),
            SizedBox(
              height: 32,
              width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                iconSize: 20,
                icon: Icon(task.completed ? Icons.check_box : Icons.check_box_outline_blank),
                onPressed: onToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
