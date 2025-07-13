import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Init timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    // Request permissions
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Initialize plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    // ✅ Create notification channel explicitly
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'habit_channel_id',
      'Habit Reminders',
      description: 'Reminders for daily habit tasks',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ✅ Fire one test notification (so Android lists the app)
    await showTestNotification();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
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
      payload: 'habit_notification',
      matchDateTimeComponents: DateTimeComponents.time, // ✅ Repeat daily
      
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<bool> checkNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // ✅ Used only once during app init to register the app with system
  static Future<void> showTestNotification() async {
    await _plugin.show(
      9999,
      '🔔 Setup Complete',
      'Notifications are ready and registered.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel_id',
          'Habit Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
