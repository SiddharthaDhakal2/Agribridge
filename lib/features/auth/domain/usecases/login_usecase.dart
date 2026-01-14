import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/core/usecases/app_usecase.dart';
import 'package:agribridge/features/auth/data/repositories/auth_repository.dart';
import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecaseParams extends Equatable{
  final String username;
  final String password;

  const LoginUsecaseParams({required this.username, required this.password});
  
  @override

  List<Object?> get props => [username, password];
  
}

//provider for Loginusecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
  
});
class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams>{ 
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
  :_authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.username, params.password);
  }
  
 }