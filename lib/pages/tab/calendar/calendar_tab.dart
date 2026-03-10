import 'package:family_tracker/core/theme/app_colors.dart';
import 'package:family_tracker/features/calendar/calendar_provider.dart';
import 'package:family_tracker/features/family/family_map_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_task_item.dart';

class CalendarTab extends ConsumerWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = ref.watch(focusedDayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final membersMap = ref.watch(familyMembersMapProvider);

    return tasksAsync.when(
      data: (tasks) {
        List<Task> getTasksForDay(DateTime day) {
          return tasks.where((task) => isSameDay(task.dueDate, day)).toList();
        }

        final selectedTasks = selectedDay != null
            ? getTasksForDay(selectedDay)
            : [];

        return Scaffold(
          appBar: AppBar(title: const Text('Календарь')),
          body: Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: focusedDay,

                selectedDayPredicate: (day) => isSameDay(selectedDay, day),

                onDaySelected: (selected, focused) {
                  ref.read(selectedDayProvider.notifier).state = selected;
                  ref.read(focusedDayProvider.notifier).state = focused;
                },

                eventLoader: getTasksForDay,

                calendarFormat: CalendarFormat.month,

                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: selectedTasks.isEmpty
                    ? const Center(child: Text("Нет задач на этот день"))
                    : ListView.builder(
                        itemCount: selectedTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedTasks[index];
                          final due = task.dueDate?.toLocal();
                          final today = DateTime.now();

                          final isExpired =
                              due != null &&
                              DateTime(due.year, due.month, due.day).isBefore(
                                DateTime(today.year, today.month, today.day),
                              );

                        // calendar-specific presentation
                        return CalendarTaskItem(
                          task: task,
                          creator: membersMap[task.createdBy],
                          membersMap: membersMap,
                          isExpired: isExpired,
                        );
                        },
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Ошибка: $e")),
    );
  }
}
