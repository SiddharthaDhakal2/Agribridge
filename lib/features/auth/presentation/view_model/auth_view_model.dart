import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/reset_forgot_password_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/send_forgot_password_otp_usecase.dart';
import 'package:agribridge/features/auth/domain/usecases/verify_forgot_password_otp_usecase.dart';
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
  final deleteAccountUsecase = ref.read(deleteAccountUsecaseProvider);
  final sendForgotPasswordOtpUsecase = ref.read(
    sendForgotPasswordOtpUsecaseProvider,
  );
  final verifyForgotPasswordOtpUsecase = ref.read(
    verifyForgotPasswordOtpUsecaseProvider,
  );
  final resetForgotPasswordUsecase = ref.read(
    resetForgotPasswordUsecaseProvider,
  );
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthViewModel(
    loginUsecase: loginUsecase,
    registerUsecase: registerUsecase,
    changePasswordUsecase: changePasswordUsecase,
    deleteAccountUsecase: deleteAccountUsecase,
    sendForgotPasswordOtpUsecase: sendForgotPasswordOtpUsecase,
    verifyForgotPasswordOtpUsecase: verifyForgotPasswordOtpUsecase,
    resetForgotPasswordUsecase: resetForgotPasswordUsecase,
    userSessionService: userSessionService,
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final ChangePasswordUsecase _changePasswordUsecase;
  final DeleteAccountUsecase _deleteAccountUsecase;
  final SendForgotPasswordOtpUsecase _sendForgotPasswordOtpUsecase;
  final VerifyForgotPasswordOtpUsecase _verifyForgotPasswordOtpUsecase;
  final ResetForgotPasswordUsecase _resetForgotPasswordUsecase;
  final UserSessionService _userSessionService;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required ChangePasswordUsecase changePasswordUsecase,
    required DeleteAccountUsecase deleteAccountUsecase,
    required SendForgotPasswordOtpUsecase sendForgotPasswordOtpUsecase,
    required VerifyForgotPasswordOtpUsecase verifyForgotPasswordOtpUsecase,
    required ResetForgotPasswordUsecase resetForgotPasswordUsecase,
    required UserSessionService userSessionService,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _changePasswordUsecase = changePasswordUsecase,
       _deleteAccountUsecase = deleteAccountUsecase,
       _sendForgotPasswordOtpUsecase = sendForgotPasswordOtpUsecase,
       _verifyForgotPasswordOtpUsecase = verifyForgotPasswordOtpUsecase,
       _resetForgotPasswordUsecase = resetForgotPasswordUsecase,
       _userSessionService = userSessionService,
       super(const AuthState());

  String _sanitizeErrorMessage(String message) {
    const exceptionPrefix = 'Exception: ';
    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length).trim();
    }
    return message.trim();
  }

  // Login method
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final params = LoginUsecaseParams(username: email, password: password);
      final result = await _loginUsecase.call(params);

      String? failureMessage;
      var authenticatedUser = state.authEntity;

      result.fold(
        (failure) {
          failureMessage = failure.message;
        },
        (authEntity) {
          authenticatedUser = authEntity;
        },
      );

      if (failureMessage != null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failureMessage,
        );
        return;
      }

      final loggedInUserId = _userSessionService.getCurrentUserId();
      if (loggedInUserId != null && loggedInUserId.trim().isNotEmpty) {
        await _userSessionService.syncBiometricStateAfterLogin(
          loggedInUserId: loggedInUserId,
        );
      }

      try {
        await _userSessionService.saveBiometricCredentials(
          email: email,
          password: password,
        );
      } catch (_) {
        // Keep login successful even if secure storage write fails.
      }

      if (authenticatedUser == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Unable to complete login. Please try again.',
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authenticatedUser,
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
      return result.fold(
        (failure) => _sanitizeErrorMessage(failure.message),
        (_) => null,
      );
    } catch (error) {
      return _sanitizeErrorMessage(error.toString());
    }
  }

  Future<String?> deleteAccount({
    required String userId,
    required String currentPassword,
  }) async {
    try {
      final params = DeleteAccountUsecaseParams(
        userId: userId,
        currentPassword: currentPassword,
      );

      final result = await _deleteAccountUsecase.call(params);
      return result.fold(
        (failure) => _sanitizeErrorMessage(failure.message),
        (_) => null,
      );
    } catch (error) {
      return _sanitizeErrorMessage(error.toString());
    }
  }

  Future<String?> sendForgotPasswordOtp({required String email}) async {
    try {
      final params = SendForgotPasswordOtpUsecaseParams(email: email);
      final result = await _sendForgotPasswordOtpUsecase.call(params);
      return result.fold(
        (failure) => _sanitizeErrorMessage(failure.message),
        (_) => null,
      );
    } catch (error) {
      return _sanitizeErrorMessage(error.toString());
    }
  }

  Future<String?> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final params = VerifyForgotPasswordOtpUsecaseParams(
        email: email,
        otp: otp,
      );
      final result = await _verifyForgotPasswordOtpUsecase.call(params);
      return result.fold(
        (failure) => _sanitizeErrorMessage(failure.message),
        (_) => null,
      );
    } catch (error) {
      return _sanitizeErrorMessage(error.toString());
    }
  }

  Future<String?> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final params = ResetForgotPasswordUsecaseParams(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      final result = await _resetForgotPasswordUsecase.call(params);
      return result.fold(
        (failure) => _sanitizeErrorMessage(failure.message),
        (_) => null,
      );
    } catch (error) {
      return _sanitizeErrorMessage(error.toString());
    }
  }
}
