import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyForgotPasswordOtpUsecaseParams extends Equatable {
  final String email;
  final String otp;

  const VerifyForgotPasswordOtpUsecaseParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

final verifyForgotPasswordOtpUsecaseProvider =
    Provider<VerifyForgotPasswordOtpUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return VerifyForgotPasswordOtpUsecase(authRepository: authRepository);
    });

class VerifyForgotPasswordOtpUsecase
    implements UsecaseWithParams<bool, VerifyForgotPasswordOtpUsecaseParams> {
  final IAuthRepository _authRepository;

  VerifyForgotPasswordOtpUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(
    VerifyForgotPasswordOtpUsecaseParams params,
  ) {
    return _authRepository.verifyForgotPasswordOtp(params.email, params.otp);
  }
}
