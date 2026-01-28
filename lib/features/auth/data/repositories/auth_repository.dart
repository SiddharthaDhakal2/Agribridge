import 'package:agribridge/features/auth/data/datasources/auth_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:agribridge/features/auth/data/models/auth_api_model.dart';
import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';


//provider

final authRepositoryProvider = Provider<IAuthRepository>((ref){
  return AuthRepository(remoteDatasouce: ref.read(authRemoteDatasourceProvider));
});
class AuthRepository implements IAuthRepository{

final IAuthRemoteDataSource _remoteDatasouce;

AuthRepository({required IAuthRemoteDataSource remoteDatasouce})
:_remoteDatasouce = remoteDatasouce;


  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async{
    try{
      // This would require API implementation or local storage
      return Left(LocalDatabaseFailure(message: 'Not implemented'));
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async{
   try{
    final user = await _remoteDatasouce.login(email, password);
    if(user != null){
      final entity = user.toEntity();
      return Right(entity);
    }
    return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
   }on Exception catch(e){
    return Left(LocalDatabaseFailure(message: e.toString()));
   }
  }

  @override
  Future<Either<Failure, bool>> logout()async {
    try{
      // TODO: Implement logout in remote datasource if needed
      return Right(true);
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity)async {
    try{
      // Convert entity to API model for registration
      final model = AuthApiModel.fromEntity(entity);
      await _remoteDatasouce.register(model);
      return Right(true);
    }on Exception catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

}