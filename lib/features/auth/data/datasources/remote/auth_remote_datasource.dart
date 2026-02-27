import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/token_service.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/data/datasources/auth_datasource.dart';
import 'package:agribridge/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';

// Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  String? _extractImagePath(Map<String, dynamic> data) {
    final candidates = [
      data['profilePicture'],
      data['image'],
      data['avatar'],
      data['photo'],
    ];

    for (final value in candidates) {
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final nested = value['url'] ?? value['path'] ?? value['src'];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested;
        }
      }
    }
    return null;
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.customerLogin,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'];
        await _tokenService.saveToken(token);
        await _userSessionService.saveToken(token);

        final data = response.data['data'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(data);
        final profilePicture =
            _extractImagePath(data) ?? user.profilePicture ?? '';

        // Save user session
        await _userSessionService.saveUserSession(
          userId: user.id!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: (data['phone'] as String?)?.trim(),
          address: (data['address'] as String?)?.trim(),
          username: user.username,
          profilePicture: profilePicture,
        );

        return user;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Cannot reach server at ${ApiEndpoints.serverUrl}. Check Wi-Fi and firewall (port 5000).',
        );
      }
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.customerRegister,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);

        // Save user data locally for session
        await _userSessionService.saveUserSession(
          userId: registeredUser.id!,
          email: registeredUser.email,
          fullName: registeredUser.fullName,
          phoneNumber: (data['phone'] as String?)?.trim(),
          address: (data['address'] as String?)?.trim(),
          username: registeredUser.username,
          profilePicture: registeredUser.profilePicture ?? '',
        );
        return registeredUser;
      }
      return user;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Cannot reach server at ${ApiEndpoints.serverUrl}. Check Wi-Fi and firewall (port 5000).',
        );
      }
      rethrow;
    }
  }

  @override
  Future<String> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.changePasswordById(userId),
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        return 'Password updated successfully';
      }

      throw Exception('Failed to change password');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Failed to change password');
    }
  }
}
