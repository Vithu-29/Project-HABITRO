import 'package:flutter/material.dart';
import 'package:frontend/home_screen/home_screen.dart';
import '../services/notification_service.dart';
import '../services/ai_services.dart';

class ReminderSetupScreen extends StatefulWidget {
  final String habitId;
  final String habitName;
  final int trackingDurationDays;

  const ReminderSetupScreen({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.trackingDurationDays,
  });

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
      await NotificationService.scheduleNotification(
        habitId: widget.habitId,
        habitName: widget.habitName,
        time: selectedTime!,
      );

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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Habit Reminder')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_alarm, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              Text(
                widget.habitName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tracking for ${widget.trackingDurationDays} days',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              Text(
                selectedTime == null
                    ? 'No time selected'
                    : 'Selected time: ${selectedTime!.format(context)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: const Text('Pick Time'),
              ),
              const SizedBox(height: 36),
              if (isSaving)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    FilledButton.icon(
                      onPressed: _scheduleNotification,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Schedule Reminder'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}