import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<void> uploadProfileImage(String imagePath, String customerId);
  Future<String?> fetchProfileImageUrl();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<void> uploadProfileImage(String imagePath, String customerId) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
      'customerId': customerId,
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.profileUploadPhoto,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to upload profile image');
    }
  }

  @override
  Future<String?> fetchProfileImageUrl() async {
    final response = await _apiClient.dio.get(ApiEndpoints.image);
    if (response.statusCode == 200 && response.data != null) {
      // Assuming API returns { "imageUrl": "..." }
      return response.data['imageUrl'] as String?;
    }
    return null;
  }
}
