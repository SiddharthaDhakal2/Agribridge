import 'package:agribridge/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/features/auth/domain/usecases/login_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/register_usecase.dart';
import 'package:agribridge/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final loginUsecase = ref.read(loginUsecaseProvider);
  final registerUsecase = ref.read(registerUsecaseProvider);
  final changePasswordUsecase = ref.read(changePasswordUsecaseProvider);
  return AuthViewModel(
    loginUsecase: loginUsecase,
    registerUsecase: registerUsecase,
    changePasswordUsecase: changePasswordUsecase,
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final ChangePasswordUsecase _changePasswordUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required ChangePasswordUsecase changePasswordUsecase,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _changePasswordUsecase = changePasswordUsecase,
       super(const AuthState());

  // Login method
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
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
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unable to complete login. Please try again.',
      );
    }
  }

  // Register method
  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
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
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unable to complete registration. Please try again.',
      );
    }
  }

  // Reset error state
  void resetError() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }

  // Logout
  void logout() {
    state = const AuthState();
  }

  Future<String?> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final params = ChangePasswordUsecaseParams(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final result = await _changePasswordUsecase.call(params);
      return result.fold((failure) => failure.message, (_) => null);
    } catch (error) {
      return error.toString();
    }
  }
}
