import 'package:flutter/material.dart';
import 'package:frontend/components/menu_button.dart';
import 'package:frontend/profile_screen/appearance_page.dart';
import 'package:frontend/profile_screen/security_page.dart';
import 'package:frontend/profile_screen/notifications.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/welcome_screen/signin_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text(
            'Welcome to HABITRO Help & Support!\n\n'
            'If you are facing any issues with the app or need assistance with any features, please refer to the following support options:\n\n'
            '1. Visit our FAQ section: Find answers to common questions about using HABITRO.\n'
            '2. Contact Support: Reach out to our support team via email for further assistance.\n'
            '3. Tutorials: Explore step-by-step guides for getting the most out of HABITRO.\n\n'
            'If you need any additional support, feel free to contact us directly. We are here to help you achieve your goals!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text(
            'HABITRO is a comprehensive habit management platform designed to help individuals build positive habits, minimize negative ones, and maintain discipline through habit tracking, personalized analytics, and gamification.\n\n'
            'Key Features:\n'
            '1. Habit Tracking: Track your habits and set goals for daily progress.\n'
            '2. Gamification: Earn rewards, badges, and maintain streaks to stay motivated.\n'
            '3. Personalized Feedback: Receive actionable insights to improve your habits.\n'
            '4. Admin Portal: For managing user data and configuring system settings.\n\n'
            'Our goal is to empower users to make lasting, positive changes in their lives by bridging the gap between habit intention and action. With real-time insights and engaging elements, HABITRO motivates users to stay consistent and achieve personal growth.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignInScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.blackText)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const StandardAppBar(appBarTitle: 'Settings', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            MenuButton(
              icon: Icons.shield,
              title: "Account & Security",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecurityPage(),
                ),
              ),
            ),
            MenuButton(
              icon: Icons.remove_red_eye,
              title: "App Appearance",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearancePage(),
                ),
              ),
            ),
            MenuButton(
              icon: Icons.notifications_none,
              title: "Notifications",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              ),
            ),
            MenuButton(
              icon: Icons.support_agent,
              title: "Help & Support",
              onTap: () => _showHelpDialog(context),
            ),
            MenuButton(
              icon: Icons.info_outline,
              title: "About",
              onTap: () => _showAboutDialog(context),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
