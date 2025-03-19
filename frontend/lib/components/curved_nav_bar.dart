import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
        Icon(Icons.home,
            size: 30, color: selectedIndex == 0 ? Colors.white : Colors.black,),
        Icon(Icons.explore_outlined,
            size: 30, color: selectedIndex == 1 ? Colors.white : Colors.black),
        Icon(Icons.analytics_outlined,
            size: 30, color: selectedIndex == 2 ? Colors.white : Colors.black),
        Icon(Icons.attach_money_rounded,
            size: 30, color: selectedIndex == 3 ? Colors.white : Colors.black),
        Icon(Icons.pending_outlined,
            size: 30, color: selectedIndex == 4 ? Colors.white : Colors.black),
      ],
      onTap: onTap,
    );
  } 
}
