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
  String? _errorText;
  bool _isLoading = false;

  bool _isNonsense(String input, {String? field}) {
    input = input.trim();

    if (input.isEmpty) return true;

    // Handle duration separately (only 2-digit numbers allowed)
    if (field == "duration") {
      final num = int.tryParse(input);
      return num == null || num < 10 || num > 99;
    }
    // Only digits
    if (RegExp(r'^\d+$').hasMatch(input)) return true;

    // Reject pure emojis or emoji-heavy input
    final emojiRegex = RegExp(
      r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F|\p{Emoji_Modifier_Base})+$',
      unicode: true,
    );
    if (emojiRegex.hasMatch(input)) return true;

    // Reject if all characters are punctuation
    if (RegExp(r'^[^\w\s]+$').hasMatch(input)) return true;

    // Reject repeated characters (e.g., "aaaaaaa", "!!!!!!!")
    if (RegExp(r'^(.)\1{4,}$').hasMatch(input)) return true;

    // Reject too short or meaningless strings
    if (input.length < 4 && input.split(' ').length < 2) return true;

    return false;
  }

  void _sendHabit() async {
    final habit = _habitController.text.trim();
    if (habit.isEmpty || _isNonsense(habit)) {
      setState(() {
        _errorText = "Please enter a valid and meaningful habit.";
      });
      return;
    } else {
      setState(() {
        _errorText = null;
      });
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
          builder: (context) =>
              BuildScreen(habit: habit, classification: classification),
        ),
      );
    } else if (classification == "Bad") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
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
                      errorText: _errorText,
                    ),
                    onChanged: (text) {
                      // Only validate after minimum length to avoid annoying users
                      if (text.length > 3 || text.isEmpty) {
                        setState(() {
                          _errorText = _isNonsense(text)
                              ? "Please enter a valid habit"
                              : null;
                        });
                      }
                    },
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
            child: _isLoading
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