import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(localAuthentication: LocalAuthentication());
});

class BiometricAuthService {
  final LocalAuthentication _localAuthentication;

  BiometricAuthService({required LocalAuthentication localAuthentication})
    : _localAuthentication = localAuthentication;

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> hasFingerprintSensor() async {
    try {
      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak);
    } on PlatformException {
      return false;
    }
  }

  Future<bool> canUseBiometricLogin() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      return false;
    }
    return hasFingerprintSensor();
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
