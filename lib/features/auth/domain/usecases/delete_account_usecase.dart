import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountUsecaseParams extends Equatable {
  final String userId;
  final String currentPassword;

  const DeleteAccountUsecaseParams({
    required this.userId,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [userId, currentPassword];
}

final deleteAccountUsecaseProvider = Provider<DeleteAccountUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return DeleteAccountUsecase(authRepository: authRepository);
});

class DeleteAccountUsecase
    implements UsecaseWithParams<bool, DeleteAccountUsecaseParams> {
  final IAuthRepository _authRepository;

  DeleteAccountUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteAccountUsecaseParams params) {
    return _authRepository.deleteAccount(params.userId, params.currentPassword);
  }
}
