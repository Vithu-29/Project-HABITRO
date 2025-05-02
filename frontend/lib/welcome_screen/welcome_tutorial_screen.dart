import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class WelcomeTutorialScreen extends StatefulWidget {
  const WelcomeTutorialScreen({super.key});

  @override
  WelcomeTutorialScreenState createState() => WelcomeTutorialScreenState();
}

class WelcomeTutorialScreenState extends State<WelcomeTutorialScreen> {
  final PageController _pageController = PageController();
  
  bool _isLastPage = false;

  final List<Map<String, String>> _tutorialData = [
    {
      "title": "Track your habits effortlessly!",
      "description": "Add habits you want to build or break,\nset daily goals and reminders,and \nwatch your progress grow!",
      "image": "assets/images/tutorial1.png"
    },
    {
      "title": "Stay consistent and unlock streaks!",
      "description": "Complete habits daily \nto keep your streak alive and \ntrack your progress.",
      "image": "assets/images/tutorial2.png"
    },
    {
      "title": "Make habit-building fun!",
      "description": "Earn rewards,unlock \nachievements,and level up as you \nreach your goals.",
      "image": "assets/images/tutorial3.png"
    },
    {
      "title": "See your success at a glance!",
      "description": "Check your daily,weekly, \nand monthly progress with insightful \ncharts and stats.",
      "image": "assets/images/tutorial4.png"
    },
    {
      "title": "Share Your Progress with Friends!",
      "description": "Stay motivated and accountable by \nsharing your achievements.Let your friends \ncheer you on as you build better habits!",
      "image": "assets/images/tutorial5.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _markTutorialAsSeen();
  }

  Future<void> _markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);
  }

  void _onPageChanged(int index) {
    setState(() {
      _isLastPage = index == _tutorialData.length - 1;
    });
  }

  void _navigateToSignup() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'assets/images/habitro_logo.png',
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _tutorialData.length,
                    itemBuilder: (context, index) {
                      final data = _tutorialData[index];
                      return _buildTutorialPage(data, screenHeight);
                    },
                  ),
                ),
              ],
            ),
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(Map<String, String> data, double screenHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Image.asset(
              data["image"]!,
              height: screenHeight * 0.5,
            ),
            const SizedBox(height: 12),
            Text(
              data["title"]!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2853AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              data["description"]!,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Positioned(
      bottom: 48,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          if (!_isLastPage)
            TextButton(
              onPressed: _navigateToSignup,
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(), 
          if (_isLastPage)
            GestureDetector(
              onTap: _navigateToSignup,
              child: const Text(
                "Finish",
                style: TextStyle(
                  color: Color(0xFF2853AF), 
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}