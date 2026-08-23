import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  static BiometricService get instance => _instance;

  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device hardware supports biometrics or device credentials
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric sensors (Fingerprint, Face ID, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Perform biometric authentication with native Android / iOS prompt
  Future<Map<String, dynamic>> authenticate({
    String localizedReason =
        'Pindai sidik jari atau Face ID Anda untuk mengamankan data MindCare',
  }) async {
    try {
      final bool isSupported = await isDeviceSupported();
      if (!isSupported) {
        return {
          'success': false,
          'message':
              'Perangkat Anda belum memiliki sensor biometrik atau proteksi PIN yang aktif.',
        };
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Fallback to PIN / Pattern / Password if biometrics fail
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        return {
          'success': true,
          'message': 'Otentikasi biometrik berhasil! Akses diberikan. 🔒',
        };
      } else {
        return {
          'success': false,
          'message': 'Otentikasi biometrik dibatalkan atau gagal.',
        };
      }
    } on PlatformException catch (e) {
      return {
        'success': false,
        'message': 'Gagal melakukan verifikasi biometrik: ${e.message ?? e.code}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan sistem pada sensor biometrik.',
      };
    }
  }
}
