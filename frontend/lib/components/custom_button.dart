import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon; // Optional icon parameter

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.icon, // Make the icon optional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0), // Add padding
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2853AF), // Button background color
          minimumSize: Size(double.infinity, 50), // Full width button
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            if (icon != null) Icon(icon, color: Colors.white), // Display icon if provided
            if (icon != null) SizedBox(width: 8), // Add spacing between icon and text
            Text(
              buttonText,
              style: TextStyle(color: Colors.white), // Button text style
            ),
          ],
        ),
      ),
    );
  }
}