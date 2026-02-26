import 'package:agribridge/core/services/storage/user_session_service.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;
  final OrderLocalDatasource localDatasource;
  final UserSessionService userSessionService;

  OrderRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.userSessionService,
  });

  void _sortNewestFirst(List<OrderEntity> orders) {
    orders.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
  }

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    final userId = userSessionService.getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      return [];
    }

    try {
      final remoteOrders = await remoteDatasource.fetchMyOrders();
      final filteredRemoteOrders = remoteOrders.where((order) {
        final orderUserId = order.userId?.trim() ?? '';
        if (orderUserId.isEmpty) return true;
        return orderUserId == userId.trim();
      }).toList();

      await localDatasource.cacheOrders(userId, filteredRemoteOrders);
      final remoteEntities = filteredRemoteOrders
          .map((model) => model.toEntity())
          .toList();
      _sortNewestFirst(remoteEntities);
      return remoteEntities;
    } catch (_) {
      final cachedOrders = localDatasource.getCachedOrders(userId);
      final cachedEntities = cachedOrders
          .map((model) => model.toEntity())
          .toList();
      _sortNewestFirst(cachedEntities);
      return cachedEntities;
    }
  }
}
