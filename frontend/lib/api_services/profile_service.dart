// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static final String baseUrl = dotenv.get('BASE_URL');
  final _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getProfileData() async {
    final token = await _storage.read(key: 'authToken');
    final response = await http.get(
      Uri.parse('$baseUrl/api/stats/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<Map<String, dynamic>> getFullProfile() async {
    final token = await _storage.read(key: 'authToken');
    final response = await http.get(
      Uri.parse('$baseUrl/profile/get-profile/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load full profile data');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data,
      {File? imageFile}) async {
    final token = await _storage.read(key: 'authToken');
    final url = Uri.parse('$baseUrl/profile/update-profile/');

    var request = http.MultipartRequest('PATCH', url);
    request.headers['Authorization'] = 'Token $token';
    // This is important for Django REST Framework to recognize the request as multipart
    request.headers['Accept'] = 'application/json';

    // Add text fields
    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add image file if exists
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_pic',
        imageFile.path,
      ));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile: $responseData');
    }
  }
}
