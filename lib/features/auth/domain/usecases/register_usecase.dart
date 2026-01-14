import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;


  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    username,
    password,
  ];
}


//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams>{

  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
  : _authRepository=authRepository;
  
  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    
  final entity = AuthEntity(
    fullName: params.fullName,
    email: params.email,
    username: params.username,
    password: params.password,
  );
  return _authRepository.register(entity);
  }

}