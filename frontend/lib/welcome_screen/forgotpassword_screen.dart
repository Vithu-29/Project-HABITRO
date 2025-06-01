// ignore_for_file: sort_child_properties_last, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api_config.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;

  // Helper method to validate if input is email or phone
  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(input);
  }

  bool _isValidPhone(String input) {
  final phoneRegex = RegExp(r'^(\+947\d{8}|07\d{8})$');
  return phoneRegex.hasMatch(input);
}


  Future<void> _sendForgotPasswordOTP() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email or phone number')),
      );
      return;
    }

    // Validate input format
    final isEmail = _isValidEmail(identifier);
    final isPhone = _isValidPhone(identifier);

    if (!isEmail && !isPhone) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid email or phone number (e.g., +947XXXXXXXX or 07XXXXXXXX)')),
    );
    return;
  }

    setState(() => _isLoading = true);

    try {
    String normalizedIdentifier = identifier;
    if (isPhone) {
      // Normalize to +947 format
      if (identifier.startsWith('07')) {
        normalizedIdentifier = '+94${identifier.substring(1)}';
      }
      // If it's already +947 format, use as-is
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}forgot-password/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": normalizedIdentifier,
      }),
    );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'OTP sent successfully';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        // Navigate to OTP verification with appropriate identifier
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: isEmail ? identifier : null,
              phone: isPhone ? identifier : null,
              isForgotPassword: true,
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Forgot Password?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2853AF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "No worries, we will send you reset instructions.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Email/Phone Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email or phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFE8EFFF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendForgotPasswordOTP,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Code',
                                style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2853AF),
                          minimumSize: const Size.fromHeight(60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Back to'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signin');
                            },
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }
}