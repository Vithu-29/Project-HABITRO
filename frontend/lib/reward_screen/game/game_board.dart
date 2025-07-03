// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/reward_screen/game/card_item.dart';
import 'package:frontend/reward_screen/game/game.dart';
import 'package:confetti/confetti.dart';
import 'package:frontend/api_services/game_service.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    required this.gameLevel,
    super.key,
  });

  final int gameLevel;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late Timer timer;
  late Game game;
  Duration remainingTime = const Duration(seconds: 180);
  int bestTime = 0;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    game = Game(widget.gameLevel);
    startTimer();
    _loadInitialStats();
  }

  void _loadInitialStats() async {
    try {
      final stats = await GameApiService.getGameStats();
      if (mounted) {
        setState(() {
          bestTime = stats['best_time'] ?? 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stats: ${e.toString()}')),
      );
    }
  }

  void _showResultDialog(bool isWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isWin ? 'Congratulations!' : 'Time\'s Up!'),
          content: Text(isWin ? 'You won the game!' : 'Better luck next time!'),
          actions: [
            TextButton(
              child: Text(isWin ? 'CLAIM' : 'OKAY'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(
                    {'won': isWin, 'timeTaken': 180 - remainingTime.inSeconds});
              },
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });

        if (game.isGameOver) {
          timer.cancel();
          final totalTimeSeconds = 180 - remainingTime.inSeconds;

          try {
            final result = await GameApiService.submitGameResult(
              totalTimeSeconds,
              true,
            );

            if (mounted) {
              setState(() {
                showConfetti = true;
                bestTime = result['best_time'];
              });
              _showResultDialog(true);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit score: ${e.toString()}')),
            );
          }
        }
      } else {
        timer.cancel();
        if (mounted) _showResultDialog(false);
      }
    });
  }

  void pauseTimer() {
    timer.cancel();
  }

  void _showPauseDialog() {
    pauseTimer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Paused'),
          actions: [
            TextButton(
              child: const Text('RESUME'),
              onPressed: () {
                Navigator.pop(context);
                startTimer();
              },
            ),
            TextButton(
              child: const Text('QUIT'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  child: Center(
                    child: !game.isGameOver
                        ? IconButton(
                            icon: const Icon(Icons.pause_circle_filled),
                            color: Colors.amberAccent[700]!,
                            iconSize: 40,
                            onPressed: () => _showPauseDialog(),
                          )
                        : null,
                  ),
                ),
                GameTimerMobile(time: remainingTime),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: game.gridSize,
                    childAspectRatio: aspectRatio * 2,
                    children: List.generate(game.cards.length, (index) {
                      return MemoryCard(
                          index: index,
                          card: game.cards[index],
                          onCardPressed: game.onCardPressed);
                    }),
                  ),
                ),
                GameBestTimeMobile(bestTime: bestTime),
              ],
            ),
            showConfetti ? const GameConfetti() : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class GameBestTimeMobile extends StatelessWidget {
  const GameBestTimeMobile({
    required this.bestTime,
    super.key,
  });

  final int bestTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 60,
      ),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.greenAccent[700],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Expanded(
              flex: 1,
              child: Icon(
                Icons.celebration,
                size: 40,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                textAlign: TextAlign.center,
                Duration(seconds: bestTime)
                    .toString()
                    .split('.')
                    .first
                    .padLeft(8, "0"),
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameTimerMobile extends StatelessWidget {
  const GameTimerMobile({
    required this.time,
    super.key,
  });

  final Duration time;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 60,
      ),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.red[700],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Expanded(
              flex: 1,
              child: Icon(
                Icons.timer,
                size: 40,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                textAlign: TextAlign.center,
                time.toString().split('.').first.padLeft(8, "0"),
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameConfetti extends StatefulWidget {
  const GameConfetti({
    super.key,
  });

  @override
  State<GameConfetti> createState() => _GameConfettiState();
}

class _GameConfettiState extends State<GameConfetti> {
  final controllerCenter =
      ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    controllerCenter.play();
  }

  @override
  void dispose() {
    controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controllerCenter,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        gravity: 0.5,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
      ),
    );
  }
}
