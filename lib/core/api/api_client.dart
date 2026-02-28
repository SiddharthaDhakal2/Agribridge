// Provider for ApiClient
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);
  return ApiClient(
    userSessionService: userSessionService,
    onUnauthorized: () {
      // Example: redirect to login or show dialog
      debugPrint('Session expired! Redirect to login.');
    },
  );
});

class ApiClient {
  final Dio _dio;
  final UserSessionService _userSessionService;
  final void Function()? onUnauthorized;

  ApiClient({
    required UserSessionService userSessionService,
    this.onUnauthorized,
  }) : _userSessionService = userSessionService,
       _dio = Dio(
         BaseOptions(
           baseUrl: ApiEndpoints.baseUrl,
           connectTimeout: ApiEndpoints.connectionTimeout,
           receiveTimeout: ApiEndpoints.receiveTimeout,
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    // Add Auth Interceptor
    _dio.interceptors.add(
      _AuthInterceptor(
        userSessionService: _userSessionService,
        onUnauthorized: onUnauthorized,
      ),
    );

    // Retry interceptor with exponential backoff
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
        retryEvaluator: (error, attempt) {
          final path = error.requestOptions.path;
          final isAuthRequest =
              path.contains(ApiEndpoints.customerLogin) ||
              path.contains(ApiEndpoints.customerRegister);
          if (isAuthRequest) {
            // Fail fast for login/register so UI doesn't hang for retry cycles.
            return false;
          }
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) => _dio.post(
    path,
    data: formData,
    options: options,
    onSendProgress: onSendProgress,
  );
}

// Auth Interceptor
class _AuthInterceptor extends Interceptor {
  final UserSessionService _userSessionService;
  final void Function()? onUnauthorized;

  _AuthInterceptor({
    required UserSessionService userSessionService,
    this.onUnauthorized,
  }) : _userSessionService = userSessionService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // List of public endpoints
    const publicEndpoints = {
      ApiEndpoints.customerLogin,
      ApiEndpoints.customerRegister,
      ApiEndpoints.forgotPasswordSendOtp,
      ApiEndpoints.forgotPasswordVerifyOtp,
      ApiEndpoints.forgotPasswordResetPassword,
    };

    // Check if this is a POST to signup or POST to login
    final isPublic = publicEndpoints.any(
      (endpoint) =>
          options.path.contains(endpoint) && (options.method == 'POST'),
    );

    // Skip adding token only for public endpoints
    if (!isPublic) {
      try {
        final token = await _userSessionService.getToken();
        if (token != null) {
          print('Adding Bearer token to request: ${options.path}');
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('No token found for request: ${options.path}');
        }
      } catch (e) {
        print('Error getting token: $e');
      }
    } else {
      print('Skipping auth for public endpoint: ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Optional: try refresh token
      // final newToken = await _userSessionService.refreshToken();
      // if (newToken != null) {
      //   final options = err.requestOptions;
      //   options.headers['Authorization'] = 'Bearer $newToken';
      //   final response = await _userSessionService.dio.fetch(options);
      //   return handler.resolve(response);
      // }

      // Clear session and trigger callback
      await _userSessionService.clearSession();
      if (onUnauthorized != null) onUnauthorized!();
    }

    handler.next(err);
  }
}
