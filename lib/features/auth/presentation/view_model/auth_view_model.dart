import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/features/auth/domain/usecases/login_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/register_usecase.dart';
import 'package:agribridge/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final loginUsecase = ref.read(loginUsecaseProvider);
  final registerUsecase = ref.read(registerUsecaseProvider);
  return AuthViewModel(
    loginUsecase: loginUsecase,
    registerUsecase: registerUsecase,
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        super(const AuthState());

  // Login method
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(username: email, password: password);
    final result = await _loginUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // Register method
  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
    );

    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }
      },
    );
  }

  // Reset error state
  void resetError() {
    state = state.copyWith(
      status: AuthStatus.initial,
      errorMessage: null,
    );
  }

  // Logout
  void logout() {
    state = const AuthState();
  }
}