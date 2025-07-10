import "package:flutter/material.dart";
import "package:frontend/components/curved_nav_bar.dart";
import "package:frontend/explore_screen/explore_screen.dart";
import "package:frontend/home_screen/home_screen.dart";
import "package:frontend/profile_screen/profile_screen.dart";
import "package:frontend/report_screen/report_screen.dart";
import "package:frontend/reward_screen/reward_screen.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget>? _pages; // Make nullable instead of late
  bool _isOnboardingActive = false;
  int _preOnboardingIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedIn = prefs.getBool('is_signed_in') ?? false;

    setState(() {
      _pages = [
        HomeScreen(
          isNewSignIn: isSignedIn,
          onOnboardingStateChanged: _handleOnboardingStateChanged,
          isOnboardingActive: _isOnboardingActive, // Pass the onboarding state
        ),
        const ExploreScreen(),
        const ReportScreen(),
        const RewardScreen(),
        const ProfileScreen(),
      ];
    });
  }

  void _handleOnboardingStateChanged(bool isActive) {
    if (isActive && !_isOnboardingActive) {
      // Starting onboarding
      setState(() {
        _preOnboardingIndex = _selectedIndex;
        _selectedIndex = 0; // Force home during onboarding
        _isOnboardingActive = true;
      });

      // Rebuild pages with updated onboarding state
      _initializePages();
    } else if (!isActive && _isOnboardingActive) {
      // Finishing onboarding - ensure proper state update sequence
      setState(() {
        _isOnboardingActive = false;
      });

      // Force a complete rebuild of pages with updated state
      _initializePages().then((_) {
        // Use a slight delay to ensure state has propagated
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              // This additional setState ensures the UI is fully refreshed
              _selectedIndex = 0;
            });
          }
        });
      });
    }
  }

  void _onNavBarTap(int index) {
    if (!_isOnboardingActive) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _pages![_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
        isDisabled: _isOnboardingActive,
      ),
    );
  }
}
