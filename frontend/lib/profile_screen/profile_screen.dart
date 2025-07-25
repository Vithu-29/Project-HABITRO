// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/api_services/profile_service.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/home_screen/mychallenges_screen.dart';
import 'package:frontend/profile_screen/all_chat.dart';
import 'package:frontend/profile_screen/edit_profile_page.dart';
import 'package:frontend/profile_screen/leaderboard_page.dart';
import 'package:frontend/profile_screen/settings_page.dart';
import 'package:frontend/reward_screen/achievements.dart';
import 'package:frontend/theme.dart';
import '../components/menu_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<Map<String, dynamic>> _profileData;
  String _fullName = "Name";
  String _profilePicUrl = "https://placehold.jp/2853af/ffffff/150x150.png?text=Habitro";
  int _habitFollowing = 0;
  double _completionRate = 0.0;
  String? _email;
  String? _phoneNumber;
  String? _dob;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _profileData = _profileService.getProfileData();
    _loadProfileData();
    _loadFullProfile();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await _profileData;
      setState(() {
        _fullName = data['full_name'] ?? "Name";
        _profilePicUrl =
            data['profile_pic_url'] ?? "https://placehold.jp/2853af/ffffff/150x150.png?text=Habitro";
        _habitFollowing = data['habit_following_count'] ?? 0;
        _completionRate = data['completion_rate']?.toDouble() ?? 0.0;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _loadFullProfile() async {
    try {
      final fullProfile = await _profileService.getFullProfile();
      setState(() {
        _email = fullProfile['email'];
        _phoneNumber = fullProfile['phone_number'];
        _dob = fullProfile['dob'];
        _gender = fullProfile['gender'];
      });
    } catch (e) {
      debugPrint('Error loading full profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Menu",
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllChat()),
              );
            },
            icon: const Icon(Icons.message_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Remove horizontal padding here
        padding: const EdgeInsets.only(top: 20, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wrap profile card with horizontal padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(_profilePicUrl),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(40, 83, 175, 1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _habitFollowing.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(40, 83, 175, 1),
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text("Habit Following"),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey.shade400,
                                  thickness: 1,
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_completionRate.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(40, 83, 175, 1),
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text("Completion Rate"),
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
                  Positioned(
                    top: 20,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              fullName: _fullName,
                              email: _email,
                              phoneNumber: _phoneNumber,
                              dob: _dob,
                              gender: _gender,
                              profilePicUrl: _profilePicUrl,
                            ),
                          ),
                        ).then((updated) {
                          if (updated == true) {
                            _loadProfileData();
                            _loadFullProfile();
                          }
                        });
                      },
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Achievements(showViewAll: false),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuButton(
                    icon: Icons.leaderboard,
                    title: "Leader Board",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaderboardPage(),
                      ),
                    ),
                  ),
                  MenuButton(
                    icon: Icons.flag,
                    title: "Challenges",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyChallengesScreen(),
                      ),
                    ),
                  ),
                  MenuButton(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
