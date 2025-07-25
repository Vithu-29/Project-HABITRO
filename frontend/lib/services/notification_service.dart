// services/notification_services.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'habit_channel_id',
      'Habit Reminders',
      description: 'Reminders for daily habit tasks',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // await showTestNotification();
  }

  static Future<void> scheduleNotification({
    required String habitId,
    required String habitName,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      habitId.hashCode, // Use habitId hash as notification ID
      '⏰ $habitName Reminder',
      'Don\'t forget to work on "$habitName" today!)',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel_id',
          'Habit Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: 'habit_notification|$habitId',
      matchDateTimeComponents: DateTimeComponents.time,
    
    );
  }

  static Future<void> cancelNotification(String habitId) async {
    await _plugin.cancel(habitId.hashCode);
  }

  static Future<bool> checkNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Future<void> _requestNotificationPermission() async {
  //   final status = await Permission.notification.request();

  //   if (status.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }

  // static Future<void> showTestNotification() async {
  //   await _plugin.show(
  //     9999,
  //     '🔔 Setup Complete',
  //     'Notifications are ready and registered.',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'habit_channel_id',
  //         'Habit Reminders',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //   );
  // }
}