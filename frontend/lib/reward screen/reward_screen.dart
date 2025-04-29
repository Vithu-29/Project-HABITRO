import 'package:flutter/material.dart';
import 'package:frontend/reward%20screen/achievements.dart';
import 'package:frontend/reward%20screen/game_card.dart';
import 'package:frontend/reward%20screen/quiz_card.dart';
import 'package:frontend/theme.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 110, // Set total height of AppBar
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Pushes buttons down
          children: [
            const Text(
              "Rewards",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _RewardsSection(),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: Column(
        children: [
          QuizCard(),
          Divider(
            height: 50,
            indent: 25,
            endIndent: 25,
            color: AppColors.greyText,
          ),
          Achievements(),
          Divider(
            height: 50,
            indent: 25,
            endIndent: 25,
            color: AppColors.greyText,
          ),
          GameCard()
        ],
      ), // Empty body or add other content
    );
  }
}

class _RewardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardButton(icon: "🏅", text: "100", extraIcon: Icons.info_outline),
        const SizedBox(width: 8),
        _RewardButton(icon: "💎", text: "0.1", extraIcon: Icons.add),
        const SizedBox(width: 8),
        _RewardButton(icon: "🔥", text: "1 day"),
      ],
    );
  }
}

class _RewardButton extends StatelessWidget {
  final String icon;
  final String text;
  final IconData? extraIcon;

  const _RewardButton({required this.icon, required this.text, this.extraIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary , width: 0.1),
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100), // Shadow color
            spreadRadius: -5, // Negative spread to keep it inside
            blurRadius: 10,
            offset: Offset(0, 4), // Position
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (extraIcon != null) ...[
            const SizedBox(width: 4),
            Icon(extraIcon, size: 16, color: Colors.black),
          ],
        ],
      ),
    );
  }
}