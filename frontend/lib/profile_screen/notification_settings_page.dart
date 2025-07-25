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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: true,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  'Notifications about daily tasks, challenges, and rewards.',
              value: appNotifications,
              onChanged: (val) => setState(() => appNotifications = val),
              activeColor: Color.fromRGBO(5, 240, 83, 1),
            ),
            const SizedBox(height: 16),
            _buildNotificationTile(
              title: 'Email Notifications',
              description:
                  'Receive updates via email about new tasks and rewards.',
              value: emailNotifications,
              onChanged: (val) => setState(() => emailNotifications = val),
              activeColor: Color.fromRGBO(5, 240, 83, 1),
            ),
            const SizedBox(height: 16),
            _buildNotificationTile(
              title: 'Newsletter',
              description:
                  'Be the first to know about new challenges and features.',
              value: newsletter,
              onChanged: (val) => setState(() => newsletter = val),
              activeColor: Color.fromRGBO(5, 240, 83, 1),
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
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
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
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Color.fromARGB(100, 0, 0, 0),
          ),
        ],
      ),
    );
  }
}
