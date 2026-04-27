import 'package:family_tracker/presentation/cubit/auth_cubit.dart';
import 'package:family_tracker/presentation/cubit/auth_state.dart';
import 'package:family_tracker/presentation/screens/auth_screen.dart';
import 'package:family_tracker/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.status == AuthStatus.authenticated) return const HomePage();

        return const AuthScreen();
      },
    );
  }
}