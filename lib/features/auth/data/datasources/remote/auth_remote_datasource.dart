import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/token_service.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/data/datasources/auth_datasource.dart';
import 'package:agribridge/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.data['success'] == true) {
      final token = response.data['token'];
      await _tokenService.saveToken(token);

      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save user session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        profilePicture: user.profilePicture ?? '',
      );

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
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
    }
    return user;
  }
}
