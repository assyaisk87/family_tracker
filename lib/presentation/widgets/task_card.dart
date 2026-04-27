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
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: task.completed ? Colors.green : Colors.blue,
          child: Icon(task.completed ? Icons.check : Icons.assignment),
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null)
              Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(assigneesText),
            if (task.dueDate != null)
              Text('Срок: ${task.dueDate!.day}.${task.dueDate!.month}.${task.dueDate!.year}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(statusLabel, style: TextStyle(color: task.completed ? Colors.green : Colors.black54)),
            const SizedBox(height: 8),
            IconButton(
              icon: Icon(task.completed ? Icons.check_box : Icons.check_box_outline_blank),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
