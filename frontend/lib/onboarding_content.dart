import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String buttonText;
  final String? targetElement;
  final Alignment? messagePosition;
  final IconData? pointerIcon;
  final Alignment? pointerAlignment;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.buttonText,
    this.targetElement,
    this.messagePosition = Alignment.center,
    this.pointerIcon = Icons.arrow_upward,
    this.pointerAlignment = Alignment.bottomCenter,
  });
}

List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: "Welcome to HABITRO",
    description: "Your journey to better habits starts \nhere. Track, plan, and grow—one step at a time. Let's build the best version of you together!",
    buttonText: "Let's Build",
    messagePosition: Alignment.center,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can add habits with AI & join challenges.",
    buttonText: "Next",
    targetElement: "fab",
    messagePosition: Alignment.bottomCenter,
    pointerIcon: Icons.arrow_upward,
    pointerAlignment: Alignment.bottomCenter,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can see your daily and weekly completion rate.",
    buttonText: "Next",
    targetElement: "date",
    messagePosition: Alignment.topCenter,
    pointerIcon: Icons.arrow_downward,
    pointerAlignment: Alignment.topCenter,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can explore articles based on category.",
    buttonText: "Next",
    targetElement: "explore",
    messagePosition: Alignment.bottomCenter,
    pointerIcon: Icons.arrow_upward,
    pointerAlignment: Alignment.bottomCenter,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can see your progress in charts.",
    buttonText: "Next",
    targetElement: "report",
    messagePosition: Alignment.bottomCenter,
    pointerIcon: Icons.arrow_upward,
    pointerAlignment: Alignment.bottomCenter,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can earn rewards & play games.",
    buttonText: "Next",
    targetElement: "reward",
    messagePosition: Alignment.bottomCenter,
    pointerIcon: Icons.arrow_upward,
    pointerAlignment: Alignment.bottomCenter,
  ),
  OnboardingItem(
    title: "",
    description: "Here you can see your profile.",
    buttonText: "Finish",
    targetElement: "profile",
    messagePosition: Alignment.bottomCenter,
    pointerIcon: Icons.arrow_upward,
    pointerAlignment: Alignment.bottomCenter,
  ),
];