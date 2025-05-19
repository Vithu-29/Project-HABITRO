// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/api_services/game_service.dart';
import 'package:frontend/components/game_constants.dart';
import 'package:frontend/reward_screen/game/game_board.dart';

class GameCard extends StatelessWidget {
  final VoidCallback? onGameCompleted;
  const GameCard({
    super.key, this.onGameCompleted,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9; // Keep width within screen limits

    final level = gameLevels[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habitro Quest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                'How to play?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            width: cardWidth,
            height: screenWidth * 0.45, // Make height proportional
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2853AF),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Game Banner (Top Section)
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      "assets/images/quest.png",
                      width: cardWidth,
                      height: screenWidth * 0.34,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Bottom Section (Rewards & Play Button)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: cardWidth,
                    height: screenWidth * 0.12, // Adjusted for better look
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Reward Text
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Text(
                                'Reward: 4',
                                style: TextStyle(
                                  color: Color(0xFF2853AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                "assets/icons/Diamond.png",
                                width: 18,
                                height: 18,
                              ),
                            ],
                          ),
                        ),

                        // Play Button
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Check and deduct gems
                                await GameApiService.startGame();

                                // If successful, start game
                                // ignore: unused_local_variable
                                final gameResult = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GameBoard(gameLevel: level['level'])),
                                );
                                onGameCompleted?.call();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Play: 2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  "assets/icons/Diamond.png",
                                  width: 18,
                                  height: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
