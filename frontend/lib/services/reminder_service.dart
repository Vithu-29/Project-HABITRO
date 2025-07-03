import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<bool> checkNotificationsEnabled() async {
    return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
  }

  static Future<void> scheduleHabitReminders(Reminder reminder) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminder_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for habit tracking reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final location = tz.local;

    try {
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
          'Track your habit: ${reminder.habitName}',
          'Time to log your progress for today!',
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      throw Exception('Failed to schedule reminders: $e');
    }
  }

  static Future<void> cancelHabitReminders(String habitId) async {
    // Implementation depends on how you track notification IDs
    // Example: Cancel all notifications up to trackingDurationDays
    // for (int i = 0; i < maxDuration; i++) {
    //   await _notificationsPlugin.cancel(i);
    // }
  }

  static Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}