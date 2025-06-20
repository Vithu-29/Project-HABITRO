import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import '../components/cnav_bar.dart';
import '../components/custom_button.dart';
import '../services/reminder_service.dart';  // Added import
import 'reminder_setup.dart';  // Added import

class TasksCardView extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> responses;

  const TasksCardView({
    required this.tasks,
    required this.responses,
    super.key,
  });

  @override
  _TaskCardScreenState createState() => _TaskCardScreenState();
}

class _TaskCardScreenState extends State<TasksCardView> {
  int regenerateCount = 0;
  List<Map<String, dynamic>> displayedTasks = [];

  @override
  void initState() {
    super.initState();
    displayedTasks = widget.tasks.take(30).toList();
  }

  Future<void> _confirmTasks() async {
    try {
      final habitName = widget.responses['responses']?['habit_name'] as String? ?? 
                       'default_habit_name';
      final habitType = widget.responses['responses']?['habit_type'] as String? ?? 
                       'default_habit_type';
      final durationStr = widget.responses['responses']?['duration'] as String?;
      final duration = int.tryParse(durationStr ?? '') ?? 30;

      print('Extracted habitDuration: $duration');
      print('Extracted habitName: $habitName');
      print('Extracted habitType: $habitType');

      final success = await AIService.saveTasks(
        habitName: habitName,
        habitType: habitType,
        tasks: widget.tasks,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks saved successfully!')),
        );
        final habitId = habitName;
        final habitDurationDays = duration;
        await _showReminderPopup(habitId, habitDurationDays);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save tasks')),
        );
      }
    } catch (e) {
      print('Error in _confirmTasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving tasks: ${e.toString()}')),
      );
    }
  }

  Future<void> _regenerateTasks() async {
    if (regenerateCount >= 3) {
      await _confirmTasks();
      return;
    }
    print('Sending responses for regeneration: ${widget.responses}');

    final payload = {
      ...widget.responses,
    };

    regenerateCount += 1;
    final newTasks = await AIService.sendToAI(payload, regenerate: true);
    if (newTasks.isNotEmpty) {
      setState(() {
        widget.tasks.clear();
        widget.tasks.addAll(newTasks);
        displayedTasks = newTasks.take(30).toList();
      });
    }
  }

  Future<void> _saveReminderPreference(bool wantsReminder, String habitId) async {
    // Implement your save logic here
    print('Reminder preference saved: $wantsReminder for habit $habitId');
  }

  Future<void> _showReminderPopup(String habitId, int habitDurationDays) async {
    final shouldSetReminder = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Daily Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get daily reminders to track your habit progress?'),
            const SizedBox(height: 16),
            Text(
              'Habit: ${widget.responses['responses']?['habit_name'] ?? 'Your habit'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: $habitDurationDays days',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );

    if (shouldSetReminder == true) {
      final bool notificationsEnabled = await ReminderService.checkNotificationsEnabled();
      
      if (!notificationsEnabled) {
        if (mounted) {
          await _showNotificationsDisabledDialog(context);
        }
        return;
      }

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ReminderSetupScreen(
            habitId: habitId,
            habitName: widget.responses['responses']?['habit_name'] ?? 'Your Habit',
            trackingDurationDays: habitDurationDays,
          ),
        ),
      );

      if (result == true && mounted) {
        await _saveReminderPreference(true, habitId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily reminder set!')),
        );
      }
    }
  }

  Future<void> _showNotificationsDisabledDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'Please enable notifications to receive habit reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // AppSettings.openNotificationSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Your Tasks',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView.builder(
        itemCount: displayedTasks.length,
        itemBuilder: (context, index) {
          final task = displayedTasks[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text(
                task['task'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                onPressed: _confirmTasks,
                buttonText: 'Confirm',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                onPressed: _regenerateTasks,
                buttonText: 'Regenerate\n (${3 - regenerateCount} left)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}