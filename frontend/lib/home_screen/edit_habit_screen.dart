import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import '../models/habit.dart';

class EditHabitScreen extends StatefulWidget {
  final Map<String, dynamic> habit;

  const EditHabitScreen({required this.habit, super.key});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TimeOfDay selectedTime;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();

    // Initialize with current time, since no reminder_time is saved yet
    selectedTime = TimeOfDay.now();
  }

  void _showDeleteConfirmationDialog(String habitId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: const Text(
              'Are you sure you want to delete this habit and all its tasks?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog first

                final currentContext = context; // capture context early

                try {
                  await AIService().deleteHabit(habitId);
                  if (mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                          content: Text('Habit deleted successfully')),
                    );
                  }
                   Navigator.of(context).pop(true); // <--- Trigger refresh in HomeScreen
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
              _readonlyField(
                'Tracking Duration',
                "${habit['start_date']} to ${habit['end_date']}",
              ),
            _readonlyField('Type', habit['type']),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Reminder Time',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: isChanged
                      ? () {
                          // Will add saving logic later
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _showDeleteConfirmationDialog(widget.habit['id']);
              },
              child: const Text(
                "Delete Habit",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
