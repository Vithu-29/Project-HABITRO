import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/components/game_icons.dart';
import 'package:frontend/reward_screen/game/card_item.dart';
import 'package:vibration/vibration.dart';
class Game {
  Game(this.gridSize) {
    generateCards();
  }

  final int gridSize;
  List<CardItem> cards = [];
  Set<IconData> icons = {};

  bool isGameOver = false;
  bool isBusy = false; // Prevent taps while comparing cards
  //int steps = 0;

  late DateTime _startTime;
  Duration timeTaken = Duration.zero;


  /// Generates the initial cards
  void generateCards() {
    generateIcons();
    cards = [];
    final List<Color> cardColors = Colors.primaries.toList();
    for (int i = 0; i < (gridSize * gridSize / 2); i++) {
      final cardValue = i + 1;
      final IconData icon = icons.elementAt(i);
      final Color cardColor = cardColors[i % cardColors.length];
      cards.addAll(_createCardItems(icon, cardColor, cardValue));
    }
    cards.shuffle(Random());

    //steps = 0;
    timeTaken = Duration.zero;
    _startTime = DateTime.now();
    isGameOver = false;
    isBusy = false;
  }

  /// Called when a memory card is tapped
  Future<bool?> onCardPressed(int index) async {
    if (cards[index].state != CardState.hidden || isGameOver || isBusy) return null;

    //steps++;
    cards[index].state = CardState.visible;

    final List<int> visibleCardIndexes = _getVisibleCardIndexes();

    if (visibleCardIndexes.length == 2) {
      isBusy = true;

      final CardItem card1 = cards[visibleCardIndexes[0]];
      final CardItem card2 = cards[visibleCardIndexes[1]];

      if (card1.value == card2.value) {
        // Match
        card1.state = CardState.guessed;
        card2.state = CardState.guessed;

        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 150);
        }

        isGameOver = _isGameOver();
        if (isGameOver) {
          timeTaken = DateTime.now().difference(_startTime);
        }

        isBusy = false;
        return true;
      } else {
        // No match - delay then hide
        await Future.delayed(const Duration(milliseconds: 1000));
        card1.state = CardState.hidden;
        card2.state = CardState.hidden;

        isBusy = false;
        return false;
      }
    }

    return null; // Only one card is open
  }

  /// Checks if all cards are guessed
  bool _isGameOver() {
    return cards.every((card) => card.state == CardState.guessed);
  }

  /// Generates unique icons for the cards
  void generateIcons() {
    icons = <IconData>{};
    while (icons.length < gridSize * gridSize / 2) {
      final IconData icon = _getRandomCardIcon();
      icons.add(icon);
    }
  }

  /// Creates a pair of matching card items
  List<CardItem> _createCardItems(IconData icon, Color color, int value) {
    return List.generate(
      2,
      (_) => CardItem(
        value: value,
        icon: icon,
        color: color,
      ),
    );
  }

  /// Gets a random icon
  IconData _getRandomCardIcon() {
    final Random random = Random();
    IconData icon;
    do {
      icon = cardIcons[random.nextInt(cardIcons.length)];
    } while (icons.contains(icon));
    return icon;
  }

  /// Gets all currently visible cards
  List<int> _getVisibleCardIndexes() {
    return cards
        .asMap()
        .entries
        .where((entry) => entry.value.state == CardState.visible)
        .map((entry) => entry.key)
        .toList();
  }
}

