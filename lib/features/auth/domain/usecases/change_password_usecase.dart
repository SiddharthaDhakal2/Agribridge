import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordUsecaseParams extends Equatable {
  final String userId;
  final String currentPassword;
  final String newPassword;

  const ChangePasswordUsecaseParams({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, currentPassword, newPassword];
}

final changePasswordUsecaseProvider = Provider<ChangePasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ChangePasswordUsecase(authRepository: authRepository);
});

class ChangePasswordUsecase
    implements UsecaseWithParams<bool, ChangePasswordUsecaseParams> {
  final IAuthRepository _authRepository;

  ChangePasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ChangePasswordUsecaseParams params) {
    return _authRepository.changePassword(
      params.userId,
      params.currentPassword,
      params.newPassword,
    );
  }
}
