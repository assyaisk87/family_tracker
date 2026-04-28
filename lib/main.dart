import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/auth_cubit.dart';
import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_cubit.dart';
import 'package:family_tracker/presentation/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['EXPO_PUBLIC_SUPABASE_URL']!,
    anonKey: dotenv.env['EXPO_PUBLIC_SUPABASE_KEY']!,
  );

  await setupDependencies();

  runApp(const  FamilyTrackerApp());
}

class FamilyTrackerApp extends StatelessWidget {
  const FamilyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {

    return  MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(locator<AuthRepository>())),
          BlocProvider(create: (_) => TaskCubit(
            locator<TaskRepository>(),
            locator<AuthRepository>(),
            locator<FamilyUsersRepository>(),
          )),
          BlocProvider(create: (_) => CreateTaskCubit(locator<TaskRepository>(), locator<AuthRepository>())),
        ],
        child: MaterialApp(
          title: 'Family Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
        home: const AuthWrapper(),
        ),      
    );
  }
}
