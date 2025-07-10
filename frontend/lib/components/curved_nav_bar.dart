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
    final Color inactiveColor = Colors
        .black; // Changed from Colors.grey to Colors.black for all unselected icons

    // During onboarding (when disabled), all icons should have the same color
    final Color homeColor = isDisabled
        ? inactiveColor
        : (selectedIndex == 0 ? activeColor : inactiveColor);
    final Color exploreColor = isDisabled
        ? inactiveColor
        : (selectedIndex == 1 ? activeColor : inactiveColor);
    final Color analyticsColor = isDisabled
        ? inactiveColor
        : (selectedIndex == 2 ? activeColor : inactiveColor);
    final Color rewardsColor = isDisabled
        ? inactiveColor
        : (selectedIndex == 3 ? activeColor : inactiveColor);
    final Color profileColor = isDisabled
        ? inactiveColor
        : (selectedIndex == 4 ? activeColor : inactiveColor);

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
          color: homeColor,
        ),
        Icon(
          Icons.explore_outlined,
          size: 30,
          color: exploreColor,
        ),
        Icon(
          Icons.analytics_outlined,
          size: 30,
          color: analyticsColor,
        ),
        SvgPicture.asset(
          'assets/icons/ex1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            rewardsColor,
            BlendMode.srcIn,
          ),
        ),
        SvgPicture.asset(
          'assets/icons/menu1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            profileColor,
            BlendMode.srcIn,
          ),
        ),
      ],
      onTap: isDisabled
          ? (_) {}
          : onTap, // Disable navigation when onboarding is active
    );
  }
}
