import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetMyOrdersUseCase {
  final OrderRepository repository;

  GetMyOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call() async {
    return repository.getMyOrders();
  }
}
