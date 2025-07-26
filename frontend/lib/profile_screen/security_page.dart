import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/welcome_screen/signin_screen.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  // Confirmation dialog for the "Delete Account" action
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Add actual account deletion logic here
              // For now, navigate back to sign-in screen after deletion
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignInScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
          appBarTitle: 'Account & Security', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            // Biometric ID option
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: AppColors.secondary,
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biometric ID'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () {
                // TODO: Implement Biometric ID settings (e.g., enable/disable biometrics)
              },
            ),
            const SizedBox(height: 15),
            // Face ID option
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: AppColors.secondary,
              leading: const Icon(Icons.face),
              title: const Text('Face ID'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () {
                // TODO: Implement Face ID settings
              },
            ),
            const SizedBox(height: 15),
            // Change Password option
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: AppColors.secondary,
              leading: const Icon(Icons.lock_reset),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () {
                // TODO: Navigate to Change Password screen
              },
            ),
            const SizedBox(height: 15),
            // Delete Account option (destructive action)
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: AppColors.secondary,
              leading: const Icon(Icons.person_remove, color: Colors.redAccent),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.redAccent),
              ),
              subtitle: const Text('Permanently delete your account and data.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}
