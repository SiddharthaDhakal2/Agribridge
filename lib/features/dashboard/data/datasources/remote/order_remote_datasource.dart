import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';

import '../../models/order_hive_model.dart';
import '../order_datasource.dart';

class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final ApiClient _apiClient;

  OrderRemoteDatasourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<OrderHiveModel>> fetchMyOrders() async {
    final response = await _apiClient.get(ApiEndpoints.myOrders);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders');
    }

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid order response');
    }

    final payload = response.data as Map<String, dynamic>;
    if (payload['success'] == false) {
      throw Exception(payload['message'] ?? 'Failed to fetch orders');
    }
    final rawOrders = payload['data'];

    return OrderHiveModel.fromOrderResponse(rawOrders);
  }
}
