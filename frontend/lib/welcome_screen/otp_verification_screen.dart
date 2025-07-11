// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/api_config.dart';
import 'package:frontend/welcome_screen/resetpassword_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? email;
  final String? phone;
  final bool
      isForgotPassword; // Determines the flow (signup or forgot password)

  const OTPVerificationScreen({
    super.key,
    this.email,
    required this.isForgotPassword,
    this.phone,
  });

  @override
  OTPVerificationScreenState createState() => OTPVerificationScreenState();
}

class OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    final body = {
      if (widget.email != null && widget.email!.isNotEmpty)
        'email': widget.email!,
      if (widget.phone != null && widget.phone!.isNotEmpty)
        'phone_number': widget.phone!,
      'otp': _otpController.text.trim(),
    };

    print(
        'Sending OTP verification for: ${widget.email}, Code: ${_otpController.text.trim()}, Forgot Password: ${widget.isForgotPassword}');

    try {
      // Determine the endpoint based on the flow
      final endpoint = widget.isForgotPassword
          ? "${ApiConfig.baseUrl}verify-forgot-password-otp/"
          : "${ApiConfig.baseUrl}verify-otp/";

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification successful!')),
        );

        // Navigate based on the flow
        if (widget.isForgotPassword) {
          // Navigate to ResetPasswordScreen for forgot password flow
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: widget.email ?? '',
                phone: widget.phone ?? '',
              ),
            ),
          );
        } else {
          // Navigate to SignInScreen for signup flow
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'OTP verification failed')),
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

  Future<void> _resendOtp() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      final body = {
        if (widget.email != null && widget.email!.isNotEmpty)
          'email': widget.email!,
        if (widget.phone != null && widget.phone!.isNotEmpty)
          'phone_number': widget.phone!,
        'is_forgot_password': widget.isForgotPassword,
      };

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}resend-otp/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP resent successfully')),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Failed to resend OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Enter Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a code to ${widget.email != null && widget.email!.isNotEmpty ? widget.email : (widget.phone ?? '')}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2853AF),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isResending ? null : _resendOtp,
              child: _isResending
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Resending...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : const Text(
                      'Didn’t receive the code yet? Resend code',
                      style: TextStyle(color: Colors.blue),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
