import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ReminderSetupScreen extends StatefulWidget {
  final String habitId;
  final String habitName;
  final int trackingDurationDays;

  const ReminderSetupScreen({
    Key? key,
    required this.habitId,
    required this.habitName,
    required this.trackingDurationDays,
  }) : super(key: key);

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  TimeOfDay? selectedTime;

  Future<void> _pickTime() async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? now,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleNotification() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time first')),
      );
      return;
    }

    await NotificationService.scheduleNotification(
      id: widget.habitId.hashCode, // unique ID based on habit
      title: '⏰ ${widget.habitName} Reminder',
      body:
          'Don\'t forget to work on "${widget.habitName}" today! (${widget.trackingDurationDays} day plan)',
      hour: selectedTime!.hour,
      minute: selectedTime!.minute,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for ${widget.habitName} at ${selectedTime!.format(context)}',
        ),
      ),
    );

    // Return to previous screen with success result
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Habit Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Habit: ${widget.habitName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${widget.trackingDurationDays} days',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              selectedTime == null
                  ? 'No time selected'
                  : 'Selected time: ${selectedTime!.format(context)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pickTime,
              child: const Text('Pick Time'),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _scheduleNotification,
              child: const Text('Schedule Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
