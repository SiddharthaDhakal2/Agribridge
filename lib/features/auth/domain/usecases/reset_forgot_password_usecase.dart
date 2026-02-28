import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetForgotPasswordUsecaseParams extends Equatable {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ResetForgotPasswordUsecaseParams({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword, confirmPassword];
}

final resetForgotPasswordUsecaseProvider = Provider<ResetForgotPasswordUsecase>(
  (ref) {
    final authRepository = ref.read(authRepositoryProvider);
    return ResetForgotPasswordUsecase(authRepository: authRepository);
  },
);

class ResetForgotPasswordUsecase
    implements UsecaseWithParams<bool, ResetForgotPasswordUsecaseParams> {
  final IAuthRepository _authRepository;

  ResetForgotPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ResetForgotPasswordUsecaseParams params) {
    return _authRepository.resetForgotPassword(
      params.email,
      params.otp,
      params.newPassword,
      params.confirmPassword,
    );
  }
}
