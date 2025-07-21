import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ai_services.dart';
import '../services/notification_service.dart';

class EditHabitScreen extends StatefulWidget {
  final Map<String, dynamic> habit;

  const EditHabitScreen({required this.habit, super.key});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TimeOfDay selectedTime;
  bool isChanged = false;
  late bool notificationStatus;

  @override
  void initState() {
    super.initState();

    notificationStatus = widget.habit['notification_status'] ?? false;

    final reminderTimeStr = widget.habit['reminder_time'];
    if (notificationStatus && reminderTimeStr != null) {
      final parts = reminderTimeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      selectedTime = TimeOfDay(hour: hour, minute: minute);
    } else {
      selectedTime = TimeOfDay.now();
    }
  }

  void _showDeleteConfirmationDialog(String habitId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: const Text('Are you sure you want to delete this habit and all its tasks?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final currentContext = context;

                try {
                  await AIService().deleteHabit(habitId);
                  if (mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(content: Text('Habit deleted successfully')),
                    );
                  }
                  Navigator.of(context).pop(true);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(content: Text('Failed to delete habit: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        isChanged = true;
      });
    }
  }

  Widget _readonlyField(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Future<void> _handleSave() async {
    // Check notification permission before scheduling
    if (notificationStatus) {
      final isGranted = await NotificationService.checkNotificationsEnabled();
      if (!isGranted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Notification Permission Disabled'),
            content: const Text(
                'Notifications are disabled. To receive reminders, please enable notifications in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        // Exit early if user doesn't want to open settings
        if (result != true) return;
      }
    }

    final habit = widget.habit;

    await AIService.updateReminderSettings(
      habitId: habit['id'],
      wantsReminder: notificationStatus,
      reminderTime: notificationStatus
          ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
          : null,
    );

    if (notificationStatus) {
      await NotificationService.scheduleNotification(
        habitId: habit['id'],
        habitName: habit['name'],
        time: selectedTime,
      );
    } else {
      await NotificationService.cancelNotification(habit['id']);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _readonlyField('Habit Name', habit['name']),
            if (habit['start_date'] != null && habit['end_date'] != null)
              _readonlyField('Tracking Duration', "${habit['start_date']} to ${habit['end_date']}"),
            _readonlyField('Type', habit['type']),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: Text(notificationStatus ? 'Enabled' : 'Disabled'),
              value: notificationStatus,
              onChanged: (bool newValue) {
                setState(() {
                  notificationStatus = newValue;
                  isChanged = true;
                });
              },
            ),

            if (notificationStatus)
              ListTile(
                title: const Text('Reminder Time', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(selectedTime.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _pickTime,
                ),
              ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isChanged ? const Color(0xFF2853AF) : Colors.grey,
                    foregroundColor: Colors.white,
                    elevation: isChanged ? 4 : 0,
                  ),
                  onPressed: isChanged ? _handleSave : null,
                  child: Text(isChanged ? 'Save Changes' : 'Saved'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => _showDeleteConfirmationDialog(habit['id']),
              child: const Text(
                "Delete Habit",
                style: TextStyle(color: Color(0xFFF44336)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
