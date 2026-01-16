import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/services/hive/hive_service.dart';
import 'package:agribridge/features/auth/data/datasources/auth_datasource.dart';
import 'package:agribridge/features/auth/data/models/auth_hive_model.dart';


//provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref){
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService:hiveService,
    userSessionService: userSessionService,
  );
});
class AuthLocalDatasource implements IAuthDatasource{
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;
  
  @override
  Future<AuthHiveModel?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email)async {
    try{
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password)async {
    try{
      final user = await _hiveService.login(email, password);
      // user ko details lai shared pref ma save garne
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!, 
          email: user.email, 
          username: user.username, 
          fullName: user.fullName, 
          //phoneNumber: user.phoneNumber, 
          //batchId: user.batchId,
          profilePicture: user.profilePicture ?? '',
        );
      }
      return user;
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async{
    try{
    await  _hiveService.logoutUser();
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model)async {
    try{
     await _hiveService.registerUser(model);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }
}