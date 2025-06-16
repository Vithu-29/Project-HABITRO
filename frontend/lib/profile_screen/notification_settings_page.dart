import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool appNotifications = true;
  bool emailNotifications = false;
  bool newsletter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNotificationTile(
              title: 'App Notifications',
              description:
                  'Notifications about daily tasks, challenges and rewards.',
              value: appNotifications,
              onChanged: (val) => setState(() => appNotifications = val),
              color: const Color.fromRGBO(232, 239, 255, 1),
            ),
            const SizedBox(height: 16),
            _buildNotificationTile(
              title: 'Email Notifications',
              description:
                  'Receive updates via email about new tasks and rewards.',
              value: emailNotifications,
              onChanged: (val) => setState(() => emailNotifications = val),
              color: const Color.fromRGBO(232, 239, 255, 1),
            ),
            const SizedBox(height: 16),
            _buildNotificationTile(
              title: 'Newsletter',
              description:
                  'Be the first to know about new challenges and features.',
              value: newsletter,
              onChanged: (val) => setState(() => newsletter = val),
              color: const Color.fromRGBO(232, 239, 255, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.lightGreenAccent,
            activeTrackColor: Colors.indigo,
            inactiveThumbColor: Colors.indigo,
            inactiveTrackColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
