import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
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
  bool _isLoading = false;

  final String apiUrl = 'http://127.0.0.1:8000/api/profile/me/';
  final logger = Logger();

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
        if (!mounted) return;
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _dobController.text = profile['date_of_birth'] ?? '';
          _phoneController.text = profile['phone_number'] ?? '';
          isPrivate = profile['is_private'] ?? false;
          selectedGender = _capitalize(profile['gender'] ?? 'Male');
          _avatarUrl =
              profile['avatar'] != null
                  ? 'http://127.0.0.1:8000${profile['avatar']}'
                  : null;
        });
      } else {
        if (!mounted) return;
        logger.e("❌ Error fetching profile: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      logger.e("❌ Exception: $e");
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    final uri = Uri.parse(apiUrl);
    final request =
        http.MultipartRequest('PUT', uri)
          ..headers['Authorization'] = 'Bearer ${AuthService.token}'
          ..fields['username'] = _usernameController.text.trim()
          ..fields['profile.name'] = _nameController.text.trim()
          ..fields['profile.email'] = _emailController.text.trim()
          ..fields['profile.gender'] = selectedGender
          ..fields['profile.date_of_birth'] = _dobController.text.trim()
          ..fields['profile.phone_number'] = _phoneController.text.trim()
          ..fields['profile.is_private'] = isPrivate.toString();
    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile.avatar', _imageFile!.path),
      );
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Profile updated!")));
        fetchUserProfile();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${response.body}")));
      }
    } catch (e) {
      if (!mounted) return;
      logger.e('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  String? _validateEmail(String? value) {
    const emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|net|edu|gov|co|info|io|[a-z]{2,})$';
    final regExp = RegExp(emailPattern);
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email (e.g., gmail.com, yahoo.com)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateProfile();
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
            onPressed: _isLoading ? null : _submitForm,
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
                    backgroundImage:
                        _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_avatarUrl != null
                                    ? NetworkImage(_avatarUrl!)
                                    : const AssetImage(
                                      'assets/default_avatar.png',
                                    ))
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      "Name",
                      _nameController,
                      "User Example",
                      validator: _validateName,
                    ),
                    _buildTextField(
                      "User name",
                      _usernameController,
                      "Username",
                      validator: _validateUsername,
                    ),
                    _buildDatePickerField("Date of birth"),
                    _buildDropdownField("Gender"),
                    _buildTextField(
                      "Email",
                      _emailController,
                      "example@gmail.com",
                      validator: _validateEmail,
                    ),
                    _buildTextField(
                      "Phone number",
                      _phoneController,
                      "Add number",
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 20),
                    _buildSwitchField(),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
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
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Color.fromRGBO(40, 83, 175, 1)
                : Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey,
            ),
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
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Color.fromRGBO(40, 83, 175, 1)
                : Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
          border: InputBorder.none,
        ),
        value: selectedGender,
        items:
            ['Male', 'Female', 'Other']
                .map(
                  (gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value!;
          });
        },
        style: TextStyle(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSwitchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Color.fromRGBO(40, 83, 175, 1)
                : Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Switch to private",
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
          ),
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
