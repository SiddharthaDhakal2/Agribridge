import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendForgotPasswordOtpUsecaseParams extends Equatable {
  final String email;

  const SendForgotPasswordOtpUsecaseParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final sendForgotPasswordOtpUsecaseProvider =
    Provider<SendForgotPasswordOtpUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return SendForgotPasswordOtpUsecase(authRepository: authRepository);
    });

class SendForgotPasswordOtpUsecase
    implements UsecaseWithParams<bool, SendForgotPasswordOtpUsecaseParams> {
  final IAuthRepository _authRepository;

  SendForgotPasswordOtpUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(
    SendForgotPasswordOtpUsecaseParams params,
  ) {
    return _authRepository.sendForgotPasswordOtp(params.email);
  }
}
