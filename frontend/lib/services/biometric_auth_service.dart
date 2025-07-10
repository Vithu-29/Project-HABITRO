import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BiometricAuthResult {
  final bool success;
  final String message;
  final String? token;

  BiometricAuthResult({
    required this.success,
    required this.message,
    this.token,
  });
}

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final _storage = FlutterSecureStorage();

  // Check if biometric auth is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Check if fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    try {
      // For web platform, check if window.isFingerprintAvailable is true
      if (kIsWeb) {
        // This is a placeholder for JavaScript interop in Flutter web
        // You'd need to use js package to properly check this
        return false; // For now, assume false for web
      }

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      return false;
    }
  }

  // Check if face recognition is available
  static Future<bool> isFaceIdAvailable() async {
    try {
      // For web platform, check if window.isFaceIdAvailable is true
      if (kIsWeb) {
        // This is a placeholder for JavaScript interop in Flutter web
        // You'd need to use js package to properly check this
        return false; // For now, assume false for web
      }

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak);
    } catch (e) {
      return false;
    }
  }

  // Check if credentials are saved
  static Future<bool> areSavedCredentialsAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    return email != null && password != null;
  }

  // Authenticate with biometrics and get saved credentials
  static Future<BiometricAuthResult> authenticateWithBiometrics({
    required bool isFingerprint,
    required BuildContext context,
  }) async {
    try {
      // Check if biometrics are available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          message: 'Biometric authentication not available on this device',
        );
      }

      // Get available biometric types
      final availableBiometrics = await getAvailableBiometrics();
      final hasFaceId = availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak);
      final hasFingerprint = availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong);

      // Check if the requested biometric type is available
      if (isFingerprint && !hasFingerprint) {
        return BiometricAuthResult(
          success: false,
          message: 'Fingerprint authentication not available on this device',
        );
      } else if (!isFingerprint && !hasFaceId) {
        return BiometricAuthResult(
          success: false,
          message: 'Face authentication not available on this device',
        );
      }

      // Check if we have saved credentials
      final hasSavedCredentials = await areSavedCredentialsAvailable();
      if (!hasSavedCredentials) {
        return BiometricAuthResult(
          success: false,
          message: 'You need to sign in with "Remember Me" checked first',
        );
      }

      // Set the authentication reason based on the biometric type
      final authReason = isFingerprint
          ? 'Scan your fingerprint to sign in'
          : 'Scan your face to sign in';

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: authReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return BiometricAuthResult(
          success: false,
          message: 'Authentication failed',
        );
      }

      // Get saved credentials
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email')!;
      final password = prefs.getString('saved_password')!;

      // Send login request to backend
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "biometric_auth": true,
          "biometric_type": isFingerprint ? "fingerprint" : "face",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Save token securely
        await _storage.write(key: 'authToken', value: token);

        // Set is_signed_in flag to true
        await prefs.setBool('is_signed_in', true);

        return BiometricAuthResult(
          success: true,
          message: 'Biometric login successful',
          token: token,
        );
      } else {
        final error = jsonDecode(response.body);
        return BiometricAuthResult(
          success: false,
          message: error['error'] ?? 'Login failed',
        );
      }
    } on PlatformException catch (e) {
      String message;
      switch (e.code) {
        case auth_error.notAvailable:
          message = 'Biometrics not available on this device';
          break;
        case auth_error.notEnrolled:
          message = 'No biometrics enrolled on this device';
          break;
        case auth_error.lockedOut:
          message = 'Biometrics locked out due to too many attempts';
          break;
        case auth_error.permanentlyLockedOut:
          message = 'Biometrics permanently locked. Please use another method';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return BiometricAuthResult(success: false, message: message);
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }
}
