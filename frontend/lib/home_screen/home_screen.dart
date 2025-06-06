// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:frontend/home_screen/home_app_bar.dart';
import 'package:frontend/onboarding_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int onboardingStep = 0;
  bool showOnboarding = true;
  bool onboardingCompleted = false;
  final GlobalKey fabKey = GlobalKey();
  final GlobalKey dateKey = GlobalKey();

  // For navigation bar item positions
  final GlobalKey exploreKey = GlobalKey();
  final GlobalKey reportKey = GlobalKey();
  final GlobalKey rewardKey = GlobalKey();
  final GlobalKey profileKey = GlobalKey();

  void handleDateSelection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _nextOnboardingStep() {
    setState(() {
      if (onboardingStep < onboardingItems.length - 1) {
        onboardingStep++;
        // Auto-switch navigation tab for nav steps
        final navTargets = {
          'explore': 1,
          'report': 2,
          'reward': 3,
          'profile': 4,
        };
        final target = onboardingItems[onboardingStep].targetElement;
        if (navTargets.containsKey(target)) {
          selectedIndex = navTargets[target]!;
        }
      } else {
        showOnboarding = false;
        
      }
    });
  }

  Offset? _getTargetOffset(String? target) {
    RenderBox? box;
    switch (target) {
      case 'fab':
        box = fabKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'date':
        box = dateKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'explore':
        box = exploreKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'report':
        box = reportKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'reward':
        box = rewardKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'profile':
        box = profileKey.currentContext?.findRenderObject() as RenderBox?;
        break;
    }
    return box?.localToGlobal(Offset.zero);
  }

  Widget _buildFingerIcon({required String target}) {
    String assetPath = 'assets/icons/finger_down.png';
    switch (target) {
      case 'fab':
        assetPath = 'assets/icons/finger_right.png';
        break;
      case 'date':
        assetPath = 'assets/icons/finger_up.png';
        break;
      case 'explore':
      case 'report':
      case 'reward':
      case 'profile':
        assetPath = 'assets/icons/finger_down.png';
        break;
      default:
        assetPath = 'assets/icons/finger_down.png';
    }
    return Image.asset(
      assetPath,
      width: 32,
      height: 32,
    );
  }

  Widget _buildOnboardingOverlay() {
    if (!showOnboarding) return const SizedBox();
    final item = onboardingItems[onboardingStep];
    final target = item.targetElement;

    // Next/Finish button styled as in the screenshots, inside the message box, right-aligned
    Widget nextButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, right: 8, bottom: 4),
          child: ElevatedButton(
            onPressed: _nextOnboardingStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2853AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              item.buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );

  
    Widget messageBoxWithButton = Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 16), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Centered content
        children: [
          if (item.title.isNotEmpty) ...[
            Image.asset(
              'assets/images/welcome.png', 
              height: 100, // height
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22, //  size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16, //  size
              color: Color(0xFF2853AF),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          nextButton,
        ],
      ),
    );

    // FAB step: finger points right, overlays + icon, finger at right center of box
    if (target == 'fab') {
      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Align(
            alignment: const Alignment(0.85, 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                messageBoxWithButton,
                const SizedBox(height: 1),
                _buildFingerIcon(target: 'fab'),
              ],
            ),
          ),
        ],
      );
    }
    // Date step: finger points up, overlays today's date, finger at top center of box
    if (target == 'date') {
      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            children: [
              const SizedBox(height: 30), // AppBar height
              _buildFingerIcon(target: 'date'),
              const SizedBox(
                  height: 1), // Reduced space between finger and message
              Align(
                alignment: const Alignment(
                    0.0, -0.3), // Positioned slightly above center
                child: messageBoxWithButton,
              ),
            ],
          ),
        ],
      );
    }

    if (target == 'explore' ||
        target == 'report' ||
        target == 'reward' ||
        target == 'profile') {
      double horizontalOffset = 0.0;
      if (target == 'explore') horizontalOffset = -0.5; // 2nd nav item
      if (target == 'report') horizontalOffset = -0.05; // 3rd nav item
      if (target == 'reward') horizontalOffset = 0.4; // 4th nav item
      if (target == 'profile') horizontalOffset = 0.8; // 5th nav item

      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 40), // Added space to push messages down
              Align(
                alignment: Alignment(horizontalOffset, 0),
                child: Container(
                  width: 280, // Slightly narrower than welcome message
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2853AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      nextButton,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3), // Space between message and finger
              Align(
                alignment: Alignment(horizontalOffset, 0),
                child: _buildFingerIcon(target: target!),
              ),
              const SizedBox(height: 60), // Space for navigation bar
            ],
          ),
        ],
      );
    }
    // Default (centered welcome)
    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.5)),
        Align(
          alignment: Alignment.center,
          child: messageBoxWithButton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBar(
        selectedIndex: selectedIndex,
        onDateSelected: handleDateSelection,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/home_img.png',
                  width: screenWidth * 0.9,
                ),
                const Text(
                  "You have no habits",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const Text(
                  "Add a habit by clicking (+) icon below.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          _buildOnboardingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: fabKey,
        onPressed: null,
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
