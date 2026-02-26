import '../models/order_hive_model.dart';

abstract class OrderRemoteDatasource {
  Future<List<OrderHiveModel>> fetchMyOrders();
}

abstract class OrderLocalDatasource {
  Future<void> cacheOrders(String userId, List<OrderHiveModel> orders);
  List<OrderHiveModel> getCachedOrders(String userId);
}
