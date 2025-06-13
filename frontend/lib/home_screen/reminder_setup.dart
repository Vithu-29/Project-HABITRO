import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';

class ReminderSetupScreen extends StatefulWidget {
  final String habitId;
  final String habitName;
  final int trackingDurationDays;

  const ReminderSetupScreen({
    required this.habitId,
    required this.habitName,
    required this.trackingDurationDays,
    Key? key,
  }) : super(key: key);

  @override
  _ReminderSetupScreenState createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _notificationsEnabled = true;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _checkNotificationPermissions();
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _checkNotificationPermissions() async {
    final bool? granted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    
    setState(() {
      _notificationsEnabled = granted ?? false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_notificationsEnabled) {
      await _showNotificationsDisabledWarning();
      return;
    }

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: widget.habitId,
      habitName: widget.habitName,
      time: _selectedTime,
      trackingDurationDays: widget.trackingDurationDays,
    );

    // Save reminder to database
    // await ReminderService.saveReminder(reminder);

    // Schedule notifications
    await _scheduleDailyNotification(reminder);

    Navigator.pop(context, true);
  }

  Future<void> _scheduleDailyNotification(Reminder reminder) async {
  // Android notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'habit_reminder_channel',
    'Habit Reminders',
    channelDescription: 'Notifications for habit tracking reminders',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );

  // Notification details for all platforms
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  // Get local timezone
  final location = tz.local;

  try {
    // Schedule notification for each day of the tracking period
    for (int day = 0; day < reminder.trackingDurationDays; day++) {
      final scheduledDate = tz.TZDateTime.from(
        DateTime.now().add(Duration(days: day)),
        location,
      ).add(Duration(
        hours: reminder.time.hour,
        minutes: reminder.time.minute,
      ));

      await _notificationsPlugin.zonedSchedule(
        day, // Unique ID for each notification
        'Habit Reminder: ${reminder.habitName}',
        'Time to track your habit progress!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  } catch (e) {
    print('Error scheduling notifications: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to schedule notifications'),
      ),
    );
  }
}

  Future<void> _showNotificationsDisabledWarning() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'Please enable notifications in your device settings to set reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    // This requires the app_settings package
    // await AppSettings.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Daily Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit: ${widget.habitName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking Duration: ${widget.trackingDurationDays} days',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Daily Reminder Time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            if (!_notificationsEnabled)
              const Text(
                'Notifications are disabled. Please enable them in your device settings.',
                style: TextStyle(color: Colors.red),
              ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Save Daily Reminder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}