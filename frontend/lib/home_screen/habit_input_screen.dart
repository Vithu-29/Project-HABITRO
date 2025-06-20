import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import 'quit_screen.dart';
import 'track_screen.dart';
import '../components/cnav_bar.dart';
import '../components/custom_button.dart';

class HabitInputScreen extends StatefulWidget {
  const HabitInputScreen({super.key});

  @override
  _HabitInputScreenState createState() => _HabitInputScreenState();
}

class _HabitInputScreenState extends State<HabitInputScreen> {
  final _habitController = TextEditingController();

  bool _isLoading = false;

  void _sendHabit() async {
    final habit = _habitController.text.trim();
    if (habit.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter a Habit before proceeding."),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

    setState(() {
      _isLoading = true;
    });

    final classification = await AIService.analyzeHabit(habit);

    setState(() {
      _isLoading = false;
    });

    if (classification == "Good") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  BuildScreen(habit: habit, classification: classification),
        ),
      );
    } else if (classification == "Bad") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  QuitScreen(habit: habit, classification: classification),
        ),
      );
    } else {
      print(classification);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error analyzing habit.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Made With AI',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
    
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "What habit would you like\nto track or quit?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 227, 235, 252),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _habitController,
                    decoration: InputDecoration(
                      hintText: "Enter here",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //motivation quote
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '"Remember,\n taking breaks isn\'t a setback—it\'s a\nway to recharge and improve focus.\nBalancing work and rest helps\nyou stay productive and energized.\nYou\'ve got this!"',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator()) // Show spinner
                    : CustomButton(
                      buttonText: 'Continue',
                      onPressed: _sendHabit,
                    ),
          ),
        ],
      ),
    );
  }
}
