
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:agribridge/core/constants/hive_table_constants.dart';
import 'package:agribridge/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});
class HiveService {

//init
  Future<void> init() async{
    final directory = await getApplicationDocumentsDirectory();
    final path  = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
  }
//Register Adapters
  void _registerAdapter(){
    if(!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)){
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }
//Open Boxes
  Future<void> openBoxes() async{
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }
//Close Boxes
  Future<void> close() async{
    await Hive.close();
  }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
  //==========Auth queries==================

  Box<AuthHiveModel> get _authBox => 
  Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async{
    await _authBox.put(model.authId, model);
    return model;
  }

  //login
  Future<AuthHiveModel?> loginUser(String email, String password) async{
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if(users.isNotEmpty){
      return users.first;
    }
    return null;
  }

  //logout
  Future<void> logoutUser() async{
    
  }

  //get current user
  AuthHiveModel? getCurrentUser(String authId){
    return _authBox.get(authId);
  }

  //isEmailExists
  bool isEmailExists(String email){
    final users = _authBox.values.where((user)=>user.email == email);
    return users.isNotEmpty;
  }
}