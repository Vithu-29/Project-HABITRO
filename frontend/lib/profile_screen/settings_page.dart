import 'package:flutter/material.dart';
import 'account_security_page.dart';
import 'linked_accounts_page.dart';
import 'app_appearance_page.dart';
import 'notification_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      {'icon': Icons.shield, 'label': 'Account & Security'},
      {'icon': Icons.remove_red_eye, 'label': 'App Appearance'},
      {'icon': Icons.notifications_none, 'label': 'Notifications'},
      {'icon': Icons.link, 'label': 'Linked Accounts'},
      {'icon': Icons.support_agent, 'label': 'Help & Support'},
      {'icon': Icons.info_outline, 'label': 'About'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ...settings.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(232, 239, 255, 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['label'] as String),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    switch (item['label']) {
                      case 'Account & Security':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSecurityPage(),
                          ),
                        );
                        break;
                      case 'App Appearance':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppAppearancePage(),
                          ),
                        );
                        break;
                      case 'Notifications':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const NotificationSettingsPage(),
                          ),
                        );
                        break;
                      case 'Linked Accounts':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LinkedAccountsPage(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(232, 239, 255, 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color.fromRGBO(244, 67, 54, 1),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 56, 56, 1),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Are you sure want to logout?',
                    style: TextStyle(
                      color: Color.fromRGBO(40, 83, 175, 1),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                          foregroundColor: Color.fromRGBO(0, 0, 0, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(40, 83, 175, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out')),
                          );
                        },
                        child: const Text('Yes,Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
