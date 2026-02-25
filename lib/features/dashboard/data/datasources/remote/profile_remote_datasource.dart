import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<String?> uploadProfileImage(String imagePath, String customerId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<String?> uploadProfileImage(String imagePath, String customerId) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    final response = await _apiClient.dio.put(
      ApiEndpoints.profileById(customerId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return data['image'] as String?;
      }
      return null;
    }

    throw Exception('Failed to upload profile image');
  }
}
