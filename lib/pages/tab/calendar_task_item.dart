import 'package:family_tracker/core/theme/app_colors.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter/material.dart';

/// Simple task tile used in calendar view.
/// Does not show due date nor completion checkbox, just title/description and assignees.
class CalendarTaskItem extends StatelessWidget {
  final Task task;
  final FamilyMember? creator;
  final Map<int, FamilyMember> membersMap;
  final bool isExpired;

  const CalendarTaskItem({
    Key? key,
    required this.task,
    required this.creator,
    required this.membersMap,
    required this.isExpired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assignees = task.assignees
        .map((id) => membersMap[id]?.displayName ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: isExpired ? Colors.red : Colors.white,
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              color: isExpired ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(
                  task.description!,
                  style: TextStyle(
                    color: isExpired ? Colors.white : Colors.black,
                  ),
                ),
              if (assignees.isNotEmpty)
                Text(
                  'Исполнители: $assignees',
                  style: TextStyle(
                    color: isExpired ? Colors.white : Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
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
        ),
      ),
    );
  }
}
