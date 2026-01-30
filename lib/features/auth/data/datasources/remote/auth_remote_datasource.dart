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
    try {
      final url = "${ApiEndpoints.customers}/$authId";
      print('Calling: GET $url');
      final response = await _apiClient.get(url);
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        print('User data: $data');
        final user = AuthApiModel.fromJson(data);
        print('Parsed user: id=${user.id}, name="${user.fullName}", email=${user.email}');
        return user;
      } else {
        print('Invalid response: statusCode=${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserById: $e');
    }
    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.customerLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('LOGIN RESPONSE: Status=${response.statusCode}, Success=${response.data['success']}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'] as String?;
        if (token != null) {
          // Save JWT token
          await _userSessionService.saveToken(token);
          print('Token saved');

          // Decode token to get user ID
          final decodedToken = JwtDecoder.decode(token);
          final userId = decodedToken['id'] as String;
          print('Decoded userId: $userId');

          // Try to fetch the full user data from backend
          try {
            print('Calling getUserById($userId)...');
            final user = await getUserById(userId);
            
            if (user != null) {
              print('getUserById returned: name="${user.fullName}"');
              // Update session with actual user data
              await _userSessionService.saveUserSession(
                userId: user.id!,
                email: user.email,
                fullName: user.fullName,
                username: user.username,
                profilePicture: user.profilePicture ?? '',
              );
              print('Saved to session');
              _userSessionService.debugPrintUserData();

              return user;
            } else {
              print('getUserById returned null');
            }
          } catch (e) {
            print('Error in getUserById: $e');
          }

          return null;
        }
      } else {
        print('Login failed: ${response.data['message']}');
      }
    } catch (e) {
      print('Login exception: $e');
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.customerRegister,
        data: user.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
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
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }
}
