import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/data/datasources/auth_datasource.dart';
import 'package:agribridge/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    // Fetch user by ID from backend
    final response = await _apiClient.get("${ApiEndpoints.customers}/$authId");
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    // Call backend login endpoint
    final response = await _apiClient.post(
      ApiEndpoints.customerLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.data['success'] == true) {
      final token = response.data['token'] as String?;
      if (token != null) {
        // Save JWT token
        await _userSessionService.saveToken(token);

        // Decode token to get user ID
        final decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['id'] as String;

        // Fetch full user data from backend
        final userResponse = await getUserById(userId);
        if (userResponse != null) {
          // Update session locally
          await _userSessionService.saveUserSession(
            userId: userResponse.id!,
            email: userResponse.email,
            fullName: userResponse.fullName,
            username: userResponse.username,
            profilePicture: userResponse.profilePicture ?? '',
          );

          return userResponse;
        }
      }
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    // Call backend register endpoint
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
        username: registeredUser.username,
        profilePicture: registeredUser.profilePicture ?? '',
      );

      return registeredUser;
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }
}
