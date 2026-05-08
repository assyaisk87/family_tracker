// presentation/widgets/calendar_task_item.dart

import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:flutter/material.dart';

class CalendarTaskItem extends StatelessWidget {
  final Task task;
  final FamilyUser? creator;
  final List<FamilyUser> membersMap;
  final bool isExpired;

  const CalendarTaskItem({
    super.key,
    required this.task,
    required this.creator,
    required this.membersMap,
    required this.isExpired,
  });

  String get _assigneesText {
    if (task.assignees.isEmpty) return 'Нет исполнителей';
    if (task.assignees.length == 1) {
      return 'Исполнитель: ${task.assignees.first.displayName}';
    }
    return 'Исполнители: ${task.assignees.map((a) => a.displayName).join(', ')}';
  }

  String get _statusLabel => task.completed ? 'Выполнено' : 'В работе';

  // Цвет фона карточки: выполнена → зелёный, просрочена → красный, иначе белый
  Color _cardColor(BuildContext context) {
    if (task.completed) return Colors.green.shade50;
    if (isExpired) return Colors.red.shade50;
    return Theme.of(context).cardColor;
  }

  // Цвет текста зависит от фона
  Color _textColor(BuildContext context) {
    if (task.completed || isExpired) return Colors.black87;
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _textColor(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            color: _cardColor(context),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),

              // ── Аватар создателя (как было) ──────────────
              leading: Tooltip(
                message: creator?.displayName ?? '',
                child: CircleAvatar(
                  // ✅ цвет аватара отражает статус задачи
                  backgroundColor:
                      task.completed ? Colors.green : Colors.blue,
                  backgroundImage: creator?.avatarUrl != null &&
                          creator!.avatarUrl.isNotEmpty
                      ? NetworkImage(creator!.avatarUrl)
                      : null,
                  child: (creator?.avatarUrl == null ||
                          creator!.avatarUrl.isEmpty)
                      ? Text(
                          creator?.displayName != null &&
                                  creator!.displayName.isNotEmpty
                              ? creator!.displayName.substring(0, 2).toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
              ),

              // ── Заголовок ────────────────────────────────
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                 
                ),
              ),

              // ── Подзаголовок ─────────────────────────────
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.description != null &&
                      task.description!.trim().isNotEmpty)
                    Text(
                      task.description!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    _assigneesText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              // ── Статус справа ──────────────
              trailing: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: task.completed ? Colors.green : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // ── Приоритет ──────────────────────
        if (task.priority)
          const Positioned(
            top: 10,
            right: 16,
            child: Icon(Icons.priority_high, color: Colors.red, size: 18),
          ),
      ],
    );
  }
}