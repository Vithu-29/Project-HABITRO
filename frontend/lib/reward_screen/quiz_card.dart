import 'package:flutter/material.dart';
import 'package:frontend/reward_screen/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final VoidCallback? onQuizCompleted;

  const QuizCard({super.key, this.onQuizCompleted});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;
    final spacing = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 25, bottom: 5),
          child: Text(
            "Quiz",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 0.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/quiz.png',
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Test Your Knowledge",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      children: [
                        Text(
                          "Reward:",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Image.asset(
                          'assets/icons/coin.png',
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "100",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Await the result from the quiz screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QuizScreen()),
                            );

                            // If quiz was completed successfully, trigger refresh
                            if (result == true && onQuizCompleted != null) {
                              onQuizCompleted!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor:Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text(
                            "Start",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
