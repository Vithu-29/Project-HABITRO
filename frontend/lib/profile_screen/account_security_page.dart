import 'package:flutter/material.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Account & Security',
          style: TextStyle(
            color:
                theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOptionTile(context, Icons.fingerprint, 'Biometric ID'),
          _buildOptionTile(context, Icons.face, 'Face ID'),
          _buildOptionTile(context, Icons.lock_outline, 'Change Password'),
          const SizedBox(height: 20),
          _buildDeleteTile(context),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(
          title,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
      ),
    );
  }

  Widget _buildDeleteTile(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
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
