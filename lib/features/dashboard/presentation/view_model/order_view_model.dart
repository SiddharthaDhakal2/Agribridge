import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecase.dart';

class OrderViewModel extends StateNotifier<AsyncValue<List<OrderEntity>>> {
  final GetMyOrdersUseCase _getMyOrdersUseCase;

  OrderViewModel({required GetMyOrdersUseCase getMyOrdersUseCase})
    : _getMyOrdersUseCase = getMyOrdersUseCase,
      super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _getMyOrdersUseCase();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshOrders() async {
    try {
      final orders = await _getMyOrdersUseCase();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
