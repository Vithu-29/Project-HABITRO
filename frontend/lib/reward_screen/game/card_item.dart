import 'dart:async';
import 'package:flutter/material.dart';

enum CardState { hidden, visible, guessed }

class CardItem {
  CardItem({
    required this.value,
    required this.icon,
    required this.color,
    this.state = CardState.hidden,
  });

  final int value;
  final IconData icon;
  final Color color;
  CardState state;
}

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    required this.card,
    required this.index,
    required this.onCardPressed,
    super.key,
  });

  final CardItem card;
  final int index;
  final ValueChanged<int> onCardPressed;

  void _handleCardTap() {
    if (card.state == CardState.hidden) {
      Timer(const Duration(milliseconds: 100), () {
        onCardPressed(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleCardTap,
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color:
            card.state == CardState.visible || card.state == CardState.guessed
                ? card.color
                : Colors.grey,
        child: Center(
          child: card.state == CardState.hidden
              ? null
              : SizedBox.expand(
                  child: FittedBox(
                    child: Icon(
                      card.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
