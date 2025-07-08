import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool isDisabled; // Add the isDisabled parameter

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.isDisabled = false, // Define the parameter with a default value
  });

  @override
  Widget build(BuildContext context) {
    // Define colors for consistent appearance
    final Color activeColor = Colors.white;
    final Color inactiveColor = isDisabled ? Colors.grey : Colors.black;

    return CurvedNavigationBar(
      buttonBackgroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      color: Colors.white,
      animationDuration: const Duration(milliseconds: 350),
      animationCurve: Curves.linear,
      height: 75,
      index: selectedIndex, // Ensure the selected index is properly set
      items: [
        Icon(
          Icons.home_outlined,
          size: 30,
          color: selectedIndex == 0 ? activeColor : inactiveColor,
        ),
        Icon(
          Icons.explore_outlined,
          size: 30,
          color: selectedIndex == 1 ? activeColor : inactiveColor,
        ),
        Icon(
          Icons.analytics_outlined,
          size: 30,
          color: selectedIndex == 2 ? activeColor : inactiveColor,
        ),
        SvgPicture.asset(
          'assets/icons/ex1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            selectedIndex == 3 ? activeColor : inactiveColor,
            BlendMode.srcIn,
          ),
        ),
        SvgPicture.asset(
          'assets/icons/menu1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            selectedIndex == 4 ? activeColor : inactiveColor,
            BlendMode.srcIn,
          ),
        ),
      ],
      onTap: isDisabled ? (_) {} : onTap, // Disable navigation when onboarding is active
    );
  }
}