import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/tasks/task_repository_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDialog extends ConsumerStatefulWidget {
  final Task? task;
  final int memberId;
  final int familyId;
  final int mySessionMemberId;

  const TaskDialog({
    super.key,
    this.task,
    required this.memberId,
    required this.familyId,
    required this.mySessionMemberId,
  });

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  int? _assignedTo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _assignedTo =
        widget.task?.assignees.isNotEmpty == true ? widget.task!.assignees.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_assignedTo == null || _titleController.text.isEmpty) {
      return;
    }

    final repo = ref.read(taskRepositoryProvider);

    if (widget.task == null) {
      await repo.createTask(
        familyId: widget.familyId,
        createdBy: widget.memberId,
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        memberIds: [_assignedTo!],
      );
    } else {
      await repo.updateTask(
        taskId: widget.task!.id,
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        memberIds: [_assignedTo!],
      );
    }

    ref.invalidate(tasksProvider);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);

    return AlertDialog(
      title: Text(
        widget.task == null ? "Создать задачу" : "Редактировать задачу",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Название:"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Описание:"),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Срок до: ${_selectedDate.toLocal().toString().split(' ')[0]}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            membersAsync.when(
              data: (members) {
                return DropdownButton<int>(
                  isExpanded: true,
                  value: _assignedTo,
                  hint: const Text("Назначить участнику"),
                  items: members
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m.id,
                          child: Text(m.displayName ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _assignedTo = val;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text("Ошибка загрузки"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Отмена"),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text("Сохранить"),
        ),
      ],
    );
  }
}
