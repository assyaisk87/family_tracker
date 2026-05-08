import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/presentation/cubit/calendar_cubit.dart';
import 'package:family_tracker/presentation/cubit/calendar_state.dart';
import 'package:family_tracker/presentation/cubit/profile_cubit.dart';
import 'package:family_tracker/presentation/cubit/profile_state.dart';
import 'package:family_tracker/presentation/cubit/task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:family_tracker/presentation/widgets/calendar_task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {    

    List<Task> selectedTasks(DateTime? selectedDate) {
      return selectedDate != null
          ? context.read<TaskCubit>().getTasksForDay(selectedDate)
          : [];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, state) {
              return TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: state.focusedDate ?? focusedDay,                

                selectedDayPredicate: (day) =>
                    isSameDay(state.selectedDate, day),

                onDaySelected: (selected, focused) {
                  context.read<CalendarCubit>().selectDay(selected);
                },

                eventLoader: (day) => context.read<TaskCubit>().getTasksForDay(day),
                calendarFormat: CalendarFormat.month,

                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
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
              );
            },
          ),

          const SizedBox(height: 16),

          BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, calendarState) {
              return BlocBuilder<TaskCubit, TaskState>(
                builder: (context, taskState) {
                  final tasks = calendarState.selectedDate != null
                      ? selectedTasks(calendarState.selectedDate)
                            .where(
                              (task) => isSameDay(
                                task.dueDate,
                                calendarState.selectedDate,
                              ),
                            )
                            .toList()
                      : [];

                  if (tasks.isEmpty) {
                    return const Center(child: Text("Нет задач на этот день"));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final due = task.dueDate?.toLocal();
                        final today = DateTime.now();

                        final isExpired =
                            due != null &&
                            DateTime(due.year, due.month, due.day).isBefore(
                              DateTime(today.year, today.month, today.day),
                            );

                        // calendar-specific presentation
                        return BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, profileState) {
                            final familyUsers = profileState.familyMembers;
                            return CalendarTaskItem(
                              task: task,
                              creator:  familyUsers.firstWhere(
                                (user) => user.id == task.createdBy,                                
                              ),
                              membersMap: familyUsers,
                              isExpired: isExpired,
                            );
                          }
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
