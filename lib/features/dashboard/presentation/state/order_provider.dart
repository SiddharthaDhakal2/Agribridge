import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/order_local_datasource.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecase.dart';
import '../view_model/order_view_model.dart';

final orderViewModelProvider =
    StateNotifierProvider.autoDispose<
      OrderViewModel,
      AsyncValue<List<OrderEntity>>
    >((ref) {
      final apiClient = ref.read(apiClientProvider);
      final userSessionService = ref.read(userSessionServiceProvider);

      final remoteDatasource = OrderRemoteDatasourceImpl(apiClient: apiClient);
      final localDatasource = OrderLocalDatasourceImpl();

      final repository = OrderRepositoryImpl(
        remoteDatasource: remoteDatasource,
        localDatasource: localDatasource,
        userSessionService: userSessionService,
      );

      final useCase = GetMyOrdersUseCase(repository);
      return OrderViewModel(getMyOrdersUseCase: useCase);
    });
