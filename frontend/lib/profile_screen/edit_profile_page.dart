import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'dart:developer';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isPrivate = false;
  String selectedGender = 'Male';
  File? _imageFile;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  //  Updated IP address for emulator
  final String apiUrl = 'http://10.0.2.2:8000/api/profile/me/';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = data['profile'] ?? {};
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _dobController.text = profile['date_of_birth'] ?? '';
          _phoneController.text = profile['phone_number'] ?? '';
          isPrivate = profile['is_private'] ?? false;
          selectedGender = _capitalize(profile['gender'] ?? 'Male');
          _avatarUrl = profile['avatar'] != null
              ? 'http://10.0.2.2:8000${profile['avatar']}'
              : null;
        });
      } else {
        log(" Error fetching profile: ${response.body}");
      }
    } catch (e) {
      log(" Exception: $e");
    }
  }

  Future<void> updateProfile() async {
    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer ${AuthService.token}'
      ..fields['username'] = _usernameController.text.trim()
      ..fields['name'] = _nameController.text.trim()
      ..fields['email'] = _emailController.text.trim()
      ..fields['gender'] = selectedGender
      ..fields['date_of_birth'] = _dobController.text.trim()
      ..fields['phone_number'] = _phoneController.text.trim()
      ..fields['is_private'] = isPrivate.toString();

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', _imageFile!.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Profile updated!")),
      );
      fetchUserProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Failed: ${response.body}")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final initialDate =
        DateTime.tryParse(_dobController.text) ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Edit profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: updateProfile,
            child: const Text(
              "Save",
              style: TextStyle(color: Color.fromRGBO(40, 83, 175, 1)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_avatarUrl != null
                            ? NetworkImage(_avatarUrl!)
                            : const AssetImage('assets/default_avatar.png'))
                            as ImageProvider,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField("Name", _nameController, "User Example"),
              _buildTextField("User name", _usernameController, "Username"),
              _buildDatePickerField("Date of birth"),
              _buildDropdownField("Gender"),
              _buildTextField("Email", _emailController, "example@gmail.com"),
              _buildTextField("Phone number", _phoneController, "Add number"),
              const SizedBox(height: 20),
              _buildSwitchField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF2853AF))),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (icon != null) Icon(icon, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label) {
    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: AbsorbPointer(
        child: _buildTextField(
          label,
          _dobController,
          "YYYY-MM-DD",
          icon: Icons.calendar_today,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF2853AF)),
          border: InputBorder.none,
        ),
        value: selectedGender,
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value!;
          });
        },
      ),
    );
  }

  Widget _buildSwitchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Switch to private", style: TextStyle(fontSize: 16)),
          Switch(
            value: isPrivate,
            onChanged: (value) {
              setState(() {
                isPrivate = value;
              });
            },
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
