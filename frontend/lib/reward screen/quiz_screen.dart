import 'dart:math';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  List<String> shuffledOptions = [];

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What is the capital of Australia?",
      "options": ["Sydney", "Canberra", "Melbourne", "Brisbane"],
      "correctAnswer": "Canberra"
    },
    {
      "question": "What is 2 + 2?",
      "options": ["3", "4", "5", "6"],
      "correctAnswer": "4"
    },
    // Add more questions...
  ];

  @override
  void initState() {
    super.initState();
    shuffleOptions();
  }

  void shuffleOptions() {
    setState(() {
      shuffledOptions =
          List<String>.from(questions[currentQuestionIndex]["options"]);
      shuffledOptions.shuffle(Random());
    });
  }

  void selectAnswer(String answer) {
    if (!isAnswered) {
      setState(() {
        selectedAnswer = answer;
        isAnswered = true;
      });

      // Auto move to next question after 1.5 seconds
      Future.delayed(const Duration(seconds: 1), () {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            isAnswered = false;
            shuffleOptions();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Row(
              children: List.generate(
                questions.length,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= currentQuestionIndex
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question
            Text(
              question["question"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Answer Options
            ...shuffledOptions.map<Widget>((option) {
              bool isCorrect = option == question["correctAnswer"];
              bool isSelected = option == selectedAnswer;
              Color buttonColor = Colors.white;

              if (isAnswered) {
                if (isSelected) {
                  buttonColor = isCorrect ? Colors.green : Colors.red;
                } else if (isCorrect) {
                  buttonColor = Colors.green;
                }
              }

              return GestureDetector(
                onTap: () => selectAnswer(option),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0
                      ? () {
                          setState(() {
                            currentQuestionIndex--;
                            selectedAnswer = null;
                            isAnswered = false;
                            shuffleOptions();
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text("Finish"),
                ),
                ElevatedButton(
                  onPressed:
                      isAnswered && currentQuestionIndex < questions.length - 1
                          ? () {
                              setState(() {
                                currentQuestionIndex++;
                                selectedAnswer = null;
                                isAnswered = false;
                                shuffleOptions();
                              });
                            }
                          : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
