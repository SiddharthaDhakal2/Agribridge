import 'package:agribridge/core/constants/hive_table_constants.dart';
import 'package:hive/hive.dart';

import '../order_datasource.dart';
import '../../models/order_hive_model.dart';

class OrderLocalDatasourceImpl implements OrderLocalDatasource {
  Box<OrderHiveModel> get _orderBox =>
      Hive.box<OrderHiveModel>(HiveTableConstant.orderTable);

  @override
  Future<void> cacheOrders(String userId, List<OrderHiveModel> orders) async {
    if (userId.trim().isEmpty) return;

    final userPrefix = '${userId}_';
    final keysToDelete = _orderBox.keys
        .whereType<String>()
        .where((key) => key.startsWith(userPrefix))
        .toList();
    await _orderBox.deleteAll(keysToDelete);

    for (var index = 0; index < orders.length; index++) {
      final order = orders[index];
      final cacheKey = '${userId}_${order.orderId}_${order.productId}_$index';
      await _orderBox.put(cacheKey, order);
    }
  }

  @override
  List<OrderHiveModel> getCachedOrders(String userId) {
    if (userId.trim().isEmpty) return [];

    final userPrefix = '${userId}_';
    return _orderBox
        .toMap()
        .entries
        .where((entry) {
          final key = entry.key;
          return key is String && key.startsWith(userPrefix);
        })
        .map((entry) => entry.value)
        .whereType<OrderHiveModel>()
        .toList();
  }
}
