import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/cnav_bar.dart';
import './habit_input_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Add With AI',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content
              children: [
                Image.asset(
                  'assets/images/chat_bot.png', 
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Let’s get started by\nsetting your first habit and let AI\nguide you towards success!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            buttonText: "Let's Get Start",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HabitInputScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
