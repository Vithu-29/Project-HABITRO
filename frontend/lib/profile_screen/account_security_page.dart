import 'package:flutter/material.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Account & Security',
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOptionTile(Icons.fingerprint, 'Biometric ID'),
          _buildOptionTile(Icons.face, 'Face ID'),
          _buildOptionTile(Icons.lock_outline, 'Change Password'),
          const SizedBox(height: 20),
          _buildDeleteTile(),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildDeleteTile() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const ListTile(
        leading: Icon(
          Icons.person_remove_alt_1_outlined,
          color: Color.fromRGBO(0, 0, 0, 1),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
        ),
        subtitle: Text(
          'Permanently delete your account and data.',
          style: TextStyle(color: Color.fromRGBO(40, 83, 175, 1)),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
