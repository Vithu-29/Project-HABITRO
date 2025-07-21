import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/ai_services.dart';

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
  bool isSaving = false;

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
    setState(() => isSaving = true);

    try {
      // 1. Schedule the notification locally
      await NotificationService.scheduleNotification(
        habitId: widget.habitId,
        habitName: widget.habitName,
        time: selectedTime!,
      );

      // 2. Save the reminder settings to backend
      final success = await AIService.updateReminderSettings(
        habitId: widget.habitId,
        wantsReminder: true,
        reminderTime: '${selectedTime!.hour}:${selectedTime!.minute}',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder set for ${widget.habitName} at ${selectedTime!.format(context)}',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        // If backend save failed, cancel the notification
        await NotificationService.cancelNotification(widget.habitId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save reminder settings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _skipReminder() async {
    setState(() => isSaving = true);
    
    try {
      // Update backend that user doesn't want reminders
      await AIService.updateReminderSettings(
        habitId: widget.habitId,
        wantsReminder: false,
        reminderTime: null,
      );
      
      Navigator.pop(context, false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isSaving = false);
    }
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
            if (isSaving)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  FilledButton(
                    onPressed: _scheduleNotification,
                    child: const Text('Schedule Reminder'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _skipReminder,
                    child: const Text('Skip Reminder'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}