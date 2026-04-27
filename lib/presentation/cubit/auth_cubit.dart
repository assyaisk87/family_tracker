import 'dart:async';

import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  late final StreamSubscription<dynamic> _subscription;

  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges.listen((user) {
      if (user == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            errorMessage: null,
          ),
        );
      }
    });
  }

  void checkAuth() {
    final user = _repository.currentUser;
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await _repository.signUp(email, password);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Ошибка при регистрации',
          status: AuthStatus.error,
        ),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await _repository.signIn(email, password);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Ошибка при регистрации',
          status: AuthStatus.error,
        ),
      );
    }
  }

  Future<void> signOut() => _repository.signOut();
}