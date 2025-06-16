import "package:flutter/material.dart";
import "package:frontend/components/curved_nav_bar.dart";
import "package:frontend/explore_screen/explore_screen.dart";
import "package:frontend/home_screen/home_screen.dart";
import "package:frontend/profile_screen/menu.dart";
import "package:frontend/report_screen/report_screen.dart";
import "package:frontend/reward_screen/reward_screen.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ExploreScreen(),
    ReportScreen(),
    RewardScreen(),
    MenuPage(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}