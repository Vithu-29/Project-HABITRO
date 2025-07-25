// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/api_services/profile_service.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String profilePicUrl;

  const EditProfilePage({
    super.key,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.dob,
    this.gender,
    required this.profilePicUrl,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late String _gender;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    _dobController = TextEditingController();
    if (widget.dob != null) {
      try {
        final parts = widget.dob!.split('-');
        if (parts.length == 3) {
          _dobController.text = "${parts[2]}/${parts[1]}/${parts[0]}";
        } else {
          _dobController.text = widget.dob!;
        }
      } catch (e) {
        _dobController.text = widget.dob!;
      }
    } else {
      _dobController.text = '';
    }
    _gender = widget.gender ?? 'none';
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      // CONVERT DATE BACK TO BACKEND FORMAT (YYYY-MM-DD)
      String? formattedDob;
      if (_dobController.text.isNotEmpty) {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          formattedDob = "${parts[2]}-${parts[1]}-${parts[0]}";
        } else {
          formattedDob = _dobController.text;
        }
      }

      final profileData = {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'phone_number':
            _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'dob': formattedDob,
        'gender': _gender,
      };

      await _profileService.updateProfile(profileData, imageFile: _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: 'Edit Profile',
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  //child: CircularProgressIndicator(),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Color.fromRGBO(40, 83, 175, 1)),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : NetworkImage(widget.profilePicUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    _pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    _pickImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Name Field
            _ProfileTile(
              label: 'Name',
              value: _nameController.text,
              onTap: () {
                _showEditDialog(
                  context: context,
                  title: 'Edit Name',
                  controller: _nameController,
                );
              },
            ),

            /// DOB Field
            _ProfileTile(
              label: 'Date of birth',
              value: _dobController.text.isEmpty
                  ? 'DD/MM/YYYY'
                  : _dobController.text,
              icon: Icons.calendar_today_outlined,
              onTap: _selectDate,
            ),

            /// Gender Field
            _ProfileTile(
              label: 'Gender',
              value: _gender == 'male'
                  ? 'Male'
                  : _gender == 'female'
                      ? 'Female'
                      : 'None',
              icon: Icons.arrow_drop_down,
              onTap: () {
                _showGenderPicker();
              },
            ),

            /// Email Field
            _ProfileTile(
              label: 'Email',
              value: _emailController.text,
              actionText: 'Change',
              onActionTap: () {
                _showEditDialog(
                  context: context,
                  title: 'Edit Email',
                  controller: _emailController,
                );
              },
            ),

            /// Phone Field
            _ProfileTile(
              label: 'Phone number',
              value: _phoneController.text.isEmpty
                  ? 'Add phone number'
                  : _phoneController.text,
              actionText: _phoneController.text.isEmpty ? 'Add' : 'Change',
              onActionTap: () {
                _showEditDialog(
                  context: context,
                  title: _phoneController.text.isEmpty
                      ? 'Add Phone Number'
                      : 'Edit Phone Number',
                  controller: _phoneController,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        String tempValue = controller.text;
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: TextEditingController(text: tempValue),
            onChanged: (value) => tempValue = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => controller.text = tempValue);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('None'),
                value: 'none',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Male'),
                value: 'male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Female'),
                value: 'female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const _ProfileTile({
    required this.label,
    required this.value,
    this.icon,
    this.actionText,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(232, 239, 255, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color.fromRGBO(40, 83, 175, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: Colors.black54,
              ),
            if (actionText != null)
              GestureDetector(
                onTap: onActionTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      color: Color.fromRGBO(40, 83, 175, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
