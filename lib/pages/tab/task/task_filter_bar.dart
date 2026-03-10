import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/tasks/filter/task_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final membersAsync = ref.watch(familyMembersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: membersAsync.when(
              data: (members) {
                return DropdownButton<int?>(
                  isExpanded: true,
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
                    ref.read(taskFilterProvider.notifier).state =
                        filter.copyWith(assigneeId: value);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text("Ошибка"),
            ),
          ),
          IconButton(
            icon: Icon(
              filter.hideOverdue ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: filter.hideOverdue ? 'Показать просроченные' : 'Скрыть просроченные',
            onPressed: () {
              ref.read(taskFilterProvider.notifier).state =
                  filter.copyWith(hideOverdue: !filter.hideOverdue);
            },
          ),
          IconButton(
            icon: Icon(
              filter.sortByDateAsc ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              ref.read(taskFilterProvider.notifier).state =
                  filter.copyWith(sortByDateAsc: !filter.sortByDateAsc);
            },
          ),
        ],
      ),
    );
  }
}
