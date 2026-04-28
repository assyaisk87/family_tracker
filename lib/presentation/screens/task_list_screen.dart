import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:family_tracker/presentation/screens/create_task_screen.dart';
import 'package:family_tracker/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
   @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            onPressed: () {
            
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CreateTaskCubit(
                      locator<TaskRepository>(),
                      locator<AuthRepository>(),
                    ),
                    child: CreateTaskScreen(),
                  ),
                ),
              ).then((_) {
                if(context.mounted){
                  context.read<TaskCubit>().loadTasks();
                }
              });
            },
            icon: Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.tasks.isEmpty) {
            return Text('Список пуст');
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return TaskCard(task: task, onTap: () => {},onToggle: () => {},);
            },
            separatorBuilder: (_, _) => Divider(height: 1),
            itemCount: state.tasks.length,
          );
        },
      ),      
    );
  }
}