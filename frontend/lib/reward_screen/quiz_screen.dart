import 'package:flutter/material.dart';
import 'package:frontend/api_services/quiz_service.dart';
import 'package:frontend/models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Quiz> quizzes = [];
  int currentQuestionIndex = 0;
  int index = 0;
  bool isLoading = false;
  int coins = 0;
  String selectedAnswer = '';
  bool isAnswerChecked = false;

  @override
  void initState() {
    super.initState();
    startQuiz();
  }

  Future<void> startQuiz() async {
    setState(() => isLoading = true);
    try {
      final response = await QuizApiService.fetchQuizzes();
      setState(() {
        quizzes = response.quizzes;
        index = response.currentQuestionIndex;
      });
    } catch (e) {
      showError('Error fetching quizzes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProgress() async {
    try {
      await QuizApiService.updateProgress(
        currentQuestionIndex: index + currentQuestionIndex,
      );
    } catch (e) {
      showError(e.toString());
    }
  }

  void handleAnswer(String answer) {
    if (isAnswerChecked) return;

    final correctAnswer = quizzes[currentQuestionIndex].answer;

    setState(() {
      selectedAnswer = answer;
      isAnswerChecked = true;
    });

    if (answer == correctAnswer) {
      coins += 10;
    }

    Future.delayed(const Duration(seconds: 1), () async {
      if (currentQuestionIndex < quizzes.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = '';
          isAnswerChecked = false;
        });
      } else {
        await updateProgress();
        try {
          await QuizApiService.addCoins(coins: coins);
        } catch (e) {
          showError(e.toString());
        }
        showScorePopup();
      }
    });
  }

  void handleQuit() async {
    await updateProgress();
    try {
      await QuizApiService.addCoins(coins: coins);
    } catch (e) {
      showError('Failed to update coins: $e');
    }
    showScorePopup();
  }

  void showScorePopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Text("Coins earned: $coins / ${quizzes.length * 10}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Color getOptionColor(String option) {
    final correctAnswer = quizzes[currentQuestionIndex].answer;
    if (!isAnswerChecked) return Colors.grey;

    if (option == correctAnswer) {
      return Colors.green;
    } else if (option == selectedAnswer) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(child: Text("No quiz available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (currentQuestionIndex + 1) / quizzes.length,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blueAccent,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Question ${currentQuestionIndex + 1}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        quizzes[currentQuestionIndex].question,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      ...quizzes[currentQuestionIndex].options.map((option) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: getOptionColor(option),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              option,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () => handleAnswer(option),
                          ),
                        );
                      }),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: handleQuit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text("Quit"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}
