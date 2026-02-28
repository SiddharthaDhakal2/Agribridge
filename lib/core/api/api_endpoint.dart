import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiEndpoints {
  ApiEndpoints._();

  // Override with --dart-define=API_BASE_URL=http://<host>:5000/api
  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  // Used for real Android/iOS devices when API_BASE_URL is not provided.
  static const String _physicalServerUrlFromEnv = String.fromEnvironment(
    'API_PHYSICAL_SERVER_URL',
  );
  // Enable only when you intentionally run `adb reverse tcp:5000 tcp:5000`.
  static const bool _useAdbReverseForAndroidPhysicalDebug =
      bool.fromEnvironment('USE_ADB_REVERSE', defaultValue: false);
  // Use your LAN/Wi-Fi adapter IP, not virtual adapter IPs (like Hyper-V/vEthernet).
  static const String _defaultPhysicalServerUrl = 'http://192.168.1.11:5000';

  static bool _isInitialized = false;
  static String? _resolvedServerUrl;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (_baseUrlFromEnv.trim().isNotEmpty) {
      _resolvedServerUrl = _extractServerUrl(_baseUrlFromEnv.trim());
      await _guardAgainstLoopbackOnPhysicalDevice();
      return;
    }

    if (kIsWeb) {
      _resolvedServerUrl = 'http://localhost:5000';
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _resolvedServerUrl = await _resolveAndroidServerUrl();
        return;
      case TargetPlatform.iOS:
        _resolvedServerUrl = await _resolveIosServerUrl();
        return;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        _resolvedServerUrl = 'http://localhost:5000';
        return;
      default:
        _resolvedServerUrl = 'http://localhost:5000';
    }
  }

  // API base URL (must include /api).
  static String get baseUrl {
    if (_resolvedServerUrl != null) {
      return '${_resolvedServerUrl!}/api';
    }
    if (_baseUrlFromEnv.trim().isNotEmpty) {
      final extracted = _extractServerUrl(_baseUrlFromEnv.trim());
      if (extracted != null) {
        return '$extracted/api';
      }
      return _normalizeBaseUrl(_baseUrlFromEnv);
    }
    return '$serverUrl/api';
  }

  // Backend origin without /api, useful for image/media paths.
  static String get serverUrl {
    if (_resolvedServerUrl != null) {
      return _resolvedServerUrl!;
    }
    if (_baseUrlFromEnv.trim().isNotEmpty) {
      final envServerUrl = _extractServerUrl(_baseUrlFromEnv.trim());
      if (envServerUrl != null) {
        return envServerUrl;
      }
    }
    return _resolvedServerUrl ?? _fallbackServerUrl();
  }

  static String _fallbackServerUrl() {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator loopback alias.
        // For a physical device, pass your LAN host with --dart-define.
        return 'http://10.0.2.2:5000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  static Future<String> _resolveAndroidServerUrl() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.isPhysicalDevice) {
        if (kDebugMode && _useAdbReverseForAndroidPhysicalDebug) {
          // Physical Android debug via USB when adb reverse is enabled.
          const reverseServerUrl = 'http://127.0.0.1:5000';
          final canReachReverse = await _isServerReachable(reverseServerUrl);
          if (canReachReverse) {
            return reverseServerUrl;
          }
        }
        return _physicalServerUrl;
      }
    } catch (_) {}

    // Android emulator loopback alias.
    return 'http://10.0.2.2:5000';
  }

  static Future<String> _resolveIosServerUrl() async {
    try {
      final info = await DeviceInfoPlugin().iosInfo;
      if (info.isPhysicalDevice) {
        return _physicalServerUrl;
      }
    } catch (_) {}

    // iOS simulator can use localhost.
    return 'http://localhost:5000';
  }

  static String get _physicalServerUrl {
    final envValue = _physicalServerUrlFromEnv.trim();
    if (envValue.isNotEmpty) {
      return _normalizeUrl(envValue);
    }
    return _defaultPhysicalServerUrl;
  }

  static Future<bool> _isServerReachable(String originUrl) async {
    try {
      final response = await http
          .head(Uri.parse(originUrl))
          .timeout(const Duration(milliseconds: 1200));
      return response.statusCode >= 100 && response.statusCode < 600;
    } catch (_) {
      return false;
    }
  }

  static String? _extractServerUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  static String _normalizeUrl(String rawUrl) {
    return rawUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String _normalizeBaseUrl(String rawUrl) {
    final trimmed = _normalizeUrl(rawUrl);
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

  static bool _isLoopbackHost(String host) {
    final normalized = host.toLowerCase().trim();
    return normalized == '127.0.0.1' ||
        normalized == 'localhost' ||
        normalized == '::1';
  }

  static Future<void> _guardAgainstLoopbackOnPhysicalDevice() async {
    final resolved = _resolvedServerUrl;
    if (resolved == null || kIsWeb) return;

    final uri = Uri.tryParse(resolved);
    if (uri == null || !_isLoopbackHost(uri.host)) return;

    bool isPhysicalDevice = false;

    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await DeviceInfoPlugin().androidInfo;
          isPhysicalDevice = info.isPhysicalDevice;
          break;
        case TargetPlatform.iOS:
          final info = await DeviceInfoPlugin().iosInfo;
          isPhysicalDevice = info.isPhysicalDevice;
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.fuchsia:
          isPhysicalDevice = false;
          break;
      }
    } catch (_) {
      isPhysicalDevice = false;
    }

    if (!isPhysicalDevice) return;

    final canUseReverse =
        defaultTargetPlatform == TargetPlatform.android &&
        kDebugMode &&
        _useAdbReverseForAndroidPhysicalDebug;
    if (canUseReverse) {
      final canReachLoopback = await _isServerReachable(resolved);
      if (canReachLoopback) return;
    }

    _resolvedServerUrl = _physicalServerUrl;
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Customer Endpoints
  static const String customers = '/customers';
  static const String customerLogin = '/auth/login';
  static const String customerRegister = '/auth/register';
  static const String forgotPasswordSendOtp = '/auth/forgot-password/send-otp';
  static const String forgotPasswordVerifyOtp =
      '/auth/forgot-password/verify-otp';
  static const String forgotPasswordResetPassword =
      '/auth/forgot-password/reset-password';
  static String changePasswordById(String id) => '/auth/change-password/$id';
  static String deleteAccountById(String id) => '/auth/delete-account/$id';

  // Order endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static const String ordersByStatus = '/orders/status';
  static String orderById(String id) => '/orders/$id';
  static String updateOrderStatusById(String id) => '/orders/$id/status';
  static const String khaltiInitiatePayment = '/payments/khalti/initiate';
  static const String khaltiVerifyPayment = '/payments/khalti/verify';

  // Profile
  static String profileById(String id) => '/auth/profile/$id';

  // for images and videos :
  // static String itemPicture(String filename) =>
  //     '$mediaServerUrl/profile_photos/$filename';
  // static String itemVideo(String filename) =>
  //     '$mediaServerUrl/profile_videos/$filename';

  static String resolveMediaUrl(String path) {
    var trimmed = path.trim();
    if (trimmed.isEmpty) return trimmed;
    trimmed = trimmed.replaceAll('\\', '/');
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final uploadsIndex = trimmed.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      trimmed = trimmed.substring(uploadsIndex);
    } else if (trimmed.startsWith('uploads/')) {
      trimmed = '/$trimmed';
    }

    if (trimmed.startsWith('/')) {
      return '$serverUrl$trimmed';
    }
    return '$serverUrl/$trimmed';
  }
}
