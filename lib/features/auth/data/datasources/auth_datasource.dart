// import 'package:agribridge/features/auth/data/models/auth_api_model.dart';
import 'package:agribridge/features/auth/data/models/auth_api_model.dart' show AuthApiModel;
import 'package:agribridge/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource{
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();

  //get email exists
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}



// abstract interface class IAuthLocalDataSource {
//   Future<AuthHiveModel> register(AuthHiveModel user);
//   Future<AuthHiveModel?> login(String email, String password);
//   Future<AuthHiveModel?> getCurrentUser();
//   Future<bool> logout();
//   //get email existence
//   Future<AuthHiveModel?> getUserByEmail(String email);
// }

// abstract interface class IAuthRemoteDataSource {
//   Future<AuthApiModel> register(AuthApiModel user);
//   Future<AuthApiModel?> login(String email, String password);
//   Future<AuthApiModel?> getUserById(String authId);
  
// }