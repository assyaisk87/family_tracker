import 'package:family_tracker/pages/family_choice_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../session/session_provider.dart';
import '../../pages/login_page.dart';
import '../../pages/home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) return const LoginPage();

        if (session.family != null) {
          return const HomePage(); // уже есть семья
        }

        // нет семьи → показываем создание или присоединение
        return const FamilyChoicePage();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Ошибка: $e')),
      ),
    );
   
  }
}
