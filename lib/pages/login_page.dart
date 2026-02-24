import 'package:family_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_tracker/features/auth/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Авторизация', 
              style: TextStyle(fontWeight: FontWeight(600), color: AppColors.primary, fontSize: 18),),
              const SizedBox(height: 20),
              const Text('Почта:'),
              const SizedBox(height: 5),
              TextFormField(controller: _emailController),
              const SizedBox(height: 15),
              const Text('Пароль:'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final error = await ref
                      .read(authProvider.notifier)
                      .signInEmail(_emailController.text, _passwordController.text);
                       ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Успешный вход')),
                    );
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                },
                child: const Text('Войти'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final error = await ref
                      .read(authProvider.notifier)
                      .signUpEmail(_emailController.text, _passwordController.text);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                },
                child: const Text('Зарегистрироваться'),
              ),
              const SizedBox(height: 20),
              // OutlinedButton(
              //   onPressed: () async {
              //     await ref.read(authProvider.notifier).signOut();
              //   },
              //   child: const Text('Выйти'),
              // ),
              // const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      ),
    );
  }
}
