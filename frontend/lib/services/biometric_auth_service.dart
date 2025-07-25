// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../api_config.dart';

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
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      if (kIsWeb) {
        return false; // Biometrics not supported on web
      }

      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (kIsWeb) {
        return [];
      }
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Check if fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    try {
      if (kIsWeb) {
        return false;
      }

      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      print('Error checking fingerprint availability: $e');
      return false;
    }
  }

  // Check if face recognition is available
  static Future<bool> isFaceIdAvailable() async {
    try {
      if (kIsWeb) {
        return false;
      }

      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak);
    } catch (e) {
      print('Error checking face ID availability: $e');
      return false;
    }
  }

  // Save credentials securely with expiration
  static Future<void> saveCredentialsForBiometric(
      String email, String password) async {
    try {
      // Hash the password for additional security
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();

      // Set expiration (30 days from now)
      final expirationTime =
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;

      // Store in secure storage
      await _secureStorage.write(key: 'biometric_email', value: email);
      await _secureStorage.write(
          key: 'biometric_password_hash', value: hashedPassword);
      await _secureStorage.write(
          key: 'biometric_expiration', value: expirationTime.toString());
      await _secureStorage.write(
          key: 'biometric_original_password', value: password);

      // Update SharedPreferences flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', true);

      print('Biometric credentials saved securely');
    } catch (e) {
      print('Error saving biometric credentials: $e');
    }
  }

  // Check if saved credentials are valid and not expired
  static Future<bool> areSavedCredentialsValid() async {
    try {
      final email = await _secureStorage.read(key: 'biometric_email');
      final passwordHash =
          await _secureStorage.read(key: 'biometric_password_hash');
      final expirationStr =
          await _secureStorage.read(key: 'biometric_expiration');

      if (email == null || passwordHash == null || expirationStr == null) {
        return false;
      }

      // Check expiration
      final expiration = int.tryParse(expirationStr);
      if (expiration == null ||
          DateTime.now().millisecondsSinceEpoch > expiration) {
        await clearSavedCredentials();
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking credential validity: $e');
      return false;
    }
  }

  // Check if saved credentials are available (legacy support)
  static Future<bool> areSavedCredentialsAvailable() async {
    return await areSavedCredentialsValid();
  }

  // Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('biometric_enabled') ?? false;

      if (isEnabled) {
        // Double-check if credentials are still valid
        return await areSavedCredentialsValid();
      }

      return false;
    } catch (e) {
      print('Error checking biometric enabled status: $e');
      return false;
    }
  }

  // Clear all saved credentials
  static Future<void> clearSavedCredentials() async {
    try {
      await _secureStorage.delete(key: 'biometric_email');
      await _secureStorage.delete(key: 'biometric_password_hash');
      await _secureStorage.delete(key: 'biometric_expiration');
      await _secureStorage.delete(key: 'biometric_original_password');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);

      // Also clear legacy credentials
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');

      print('Biometric credentials cleared');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  // Enhanced biometric authentication
  static Future<BiometricAuthResult> authenticateWithBiometrics({
    required bool isFingerprint,
    required BuildContext context,
  }) async {
    try {
      if (kIsWeb) {
        return BiometricAuthResult(
          success: false,
          message: 'Biometric authentication not supported on web',
        );
      }

      // Check if biometrics are available on device
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          message: 'This device does not support biometric authentication',
        );
      }

      // Get available biometric types
      final availableBiometrics = await getAvailableBiometrics();
      final hasFaceId = availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak);
      final hasFingerprint =
          availableBiometrics.contains(BiometricType.fingerprint) ||
              availableBiometrics.contains(BiometricType.strong);

      // Check if the requested biometric type is available and show specific error messages
      if (isFingerprint && !hasFingerprint) {
        return BiometricAuthResult(
          success: false,
          message: 'This phone does not have fingerprint biometric',
        );
      } else if (!isFingerprint && !hasFaceId) {
        return BiometricAuthResult(
          success: false,
          message: 'This phone does not have face biometric',
        );
      }

      // Check if credentials are valid
      if (!await areSavedCredentialsValid()) {
        return BiometricAuthResult(
          success: false,
          message:
              'Please sign in manually with "Remember Me" to enable biometric authentication.',
        );
      }

      // Set the authentication reason based on the biometric type
      final authReason = isFingerprint
          ? 'Use your fingerprint to sign in'
          : 'Use face recognition to sign in';

      // Perform biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: authReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        return BiometricAuthResult(
          success: false,
          message: 'Biometric authentication cancelled',
        );
      }

      // Get saved credentials
      final email = await _secureStorage.read(key: 'biometric_email');
      final originalPassword =
          await _secureStorage.read(key: 'biometric_original_password');

      if (email == null || originalPassword == null) {
        await clearSavedCredentials();
        return BiometricAuthResult(
          success: false,
          message:
              'Credentials not found. Please sign in again with "Remember Me".',
        );
      }

      // Authenticate with backend using standard login flow
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": originalPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Save token in multiple locations to ensure availability
        await _saveTokenToMultipleStorages(token);

        // Update session flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_signed_in', true);

        // Refresh credential expiration
        final newExpiration =
            DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
        await _secureStorage.write(
            key: 'biometric_expiration', value: newExpiration.toString());

        return BiometricAuthResult(
          success: true,
          message: 'Biometric authentication successful',
          token: token,
        );
      } else {
        final errorData = jsonDecode(response.body);

        // If credentials are invalid, clear them
        if (response.statusCode == 401 || response.statusCode == 400) {
          await clearSavedCredentials();
          return BiometricAuthResult(
            success: false,
            message:
                'Credentials invalid. Please sign in again with "Remember Me".',
          );
        }

        return BiometricAuthResult(
          success: false,
          message: errorData['error'] ?? 'Authentication failed',
        );
      }
    } on PlatformException catch (e) {
      String message;
      switch (e.code) {
        case auth_error.notAvailable:
          message = isFingerprint
              ? 'This phone does not have fingerprint biometric'
              : 'This phone does not have face biometric';
          break;
        case auth_error.notEnrolled:
          message = isFingerprint
              ? 'No fingerprint enrolled on this device'
              : 'No face biometric enrolled on this device';
          break;
        case auth_error.lockedOut:
          message = 'Biometric authentication locked due to too many attempts';
          break;
        case auth_error.permanentlyLockedOut:
          message = 'Biometric authentication permanently locked';
          break;
        default:
          message = 'Biometric authentication error: ${e.message}';
      }
      return BiometricAuthResult(success: false, message: message);
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        message: 'Authentication error: $e',
      );
    }
  }

  // Add a helper method to save tokens consistently
  static Future<void> _saveTokenToMultipleStorages(String token) async {
    try {
      // 1. Save in secure storage
      await _secureStorage.write(key: 'authToken', value: token);

      // 2. Also save in SharedPreferences for better compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      print('Token saved to multiple storage locations');
    } catch (e) {
      print('Error saving token to multiple storages: $e');
    }
  }

  // Disable biometric authentication
  static Future<void> disableBiometricAuth() async {
    await clearSavedCredentials();
  }
}
