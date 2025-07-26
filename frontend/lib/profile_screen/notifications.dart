import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _appNotifications = true;
  bool _emailNotifications = false;
  bool _newsletter = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          StandardAppBar(appBarTitle: 'Notifications', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("App Notifications"),
              subtitle: const Text(
                  "Notifications about daily tasks, challenges and rewards."),
              secondary: const Icon(Icons.notifications),
              tileColor: AppColors.secondary,
              value: _appNotifications,
              onChanged: (bool value) {
                setState(() {
                  _appNotifications = value;
                });
              },
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text("Email Notifications"),
              subtitle: const Text(
                  "Notifications about daily tasks, challenges and rewards."),
              secondary: const Icon(Icons.email_outlined),
              tileColor: AppColors.secondary,
              value: _emailNotifications,
              onChanged: (bool value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text("Newsletter"),
              subtitle: const Text(
                  "Be the first to know about new challenges, features, and rewards!"),
              secondary: const Icon(Icons.article),
              tileColor: AppColors.secondary,
              value: _newsletter,
              onChanged: (bool value) {
                setState(() {
                  _newsletter = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
