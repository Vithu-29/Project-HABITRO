import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import '../components/cnav_bar.dart';
import '../components/custom_button.dart';
import 'first.dart';

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
    // Display first 30 tasks
    displayedTasks = widget.tasks.take(30).toList();
  }

  Future<void> _confirmTasks() async {
  try {
    // Safely extract habit name and type from nested structure
    final habitName = widget.responses['responses']?['habit_name'] as String? ?? 
                     'default_habit_name';
    final habitType = widget.responses['responses']?['habit_type'] as String? ?? 
                     'default_habit_type';

    print('Extracted habitName: $habitName');  // Debug print
    print('Extracted habitType: $habitType');  // Debug print

    final success = await AIService.saveTasks(
      habitName: habitName,
      habitType: habitType,
      tasks: widget.tasks,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tasks saved successfully!')),
      );
      //Navigator.pop(context);
      final habitId = habitName; // You can replace this with real habit ID if available
      final habitDurationDays = widget.tasks.length; // or fixed value like 30
      await _showReminderPopup(habitId, habitDurationDays);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save tasks')),
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
      // Automatically save the last generated tasks
      await _confirmTasks();
      return;
    }
  print('Sending responses for regeneration: ${widget.responses}'); // Add this line

  final payload = {
    ...widget.responses,
    
  };

    regenerateCount += 1;
    final newTasks = await AIService.sendToAI(payload,regenerate: true,);
    if (newTasks.isNotEmpty) {
      setState(() {
        widget.tasks.clear();
        widget.tasks.addAll(newTasks);
        displayedTasks = newTasks.take(30).toList();
      });
    } else {
      // Show error message
    }
  }

Future<void> _showReminderPopup(String habitId, int habitDurationDays) async {
  final shouldSetReminder = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Set Reminder'),
      content: const Text('Do you want to set a reminder for this habit?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Set Reminder'),
        ),
      ],
    ),
  );

  if (shouldSetReminder == true) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirstScreen(),
      ),
    );
  } else {
    Navigator.popUntil(context, (route) => route.isFirst); // Or go back
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Your Tasks',
        onBackPressed: () => {
          Navigator.pop(context)
        },
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
        boxShadow: [
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
