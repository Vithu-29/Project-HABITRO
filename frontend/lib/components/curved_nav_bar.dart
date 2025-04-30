import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar(
      {super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      buttonBackgroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      color: Colors.white,
      animationDuration: Duration(milliseconds: 350),
      animationCurve: Curves.linear,
      height: 75,
      items: [
        Icon(
          Icons.home_outlined,
          size: 30,
          color: selectedIndex == 0 ? Colors.white : Colors.black,
        ),
        Icon(Icons.explore_outlined,
            size: 30, color: selectedIndex == 1 ? Colors.white : Colors.black),
        Icon(Icons.analytics_outlined,
            size: 30, color: selectedIndex == 2 ? Colors.white : Colors.black),
        SvgPicture.asset(
          'assets/icons/ex1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            selectedIndex == 3 ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
        ),
        SvgPicture.asset(
          'assets/icons/menu1.svg',
          height: 30,
          colorFilter: ColorFilter.mode(
            selectedIndex == 4 ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ],
      onTap: onTap,
    );
  }
}
