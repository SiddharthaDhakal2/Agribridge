import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:agribridge/core/constants/hive_table_constants.dart';
import 'package:agribridge/features/auth/data/models/auth_hive_model.dart';
import 'package:agribridge/features/dashboard/data/models/home_hive_model.dart';
import 'package:agribridge/features/dashboard/data/models/order_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  //init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  //Register Adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    // Register HomeHiveModelAdapter for products
    if (!Hive.isAdapterRegistered(HiveTableConstant.productTypeId)) {
      Hive.registerAdapter(HomeHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.orderTypeId)) {
      Hive.registerAdapter(OrderHiveModelAdapter());
    }
  }

  //Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<HomeHiveModel>(HiveTableConstant.productTable);
    await Hive.openBox<OrderHiveModel>(HiveTableConstant.orderTable);
  }

  //Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  //==========Auth queries==================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  //login
  Future<AuthHiveModel?> login(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  //logout
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //isEmailExists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
