import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getMyOrders();
}
