import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import 'tasks_card_view.dart';
import '../components/cnav_bar.dart';
import '../components/custom_button.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String habit;
  final String classification;
  final List<String> dynamicQuestions;

  const QuestionnaireScreen({
    required this.habit,
    required this.classification,
    required this.dynamicQuestions,
    super.key,
  });

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final List<Map<String, String>> _coreQuestions;
  late final List<Map<String, String>> _allQuestions;
  late final List<String?> _answers;
  late final int _coreLength;
  String? _errorText;

  int _currentQuestionIndex = 0;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.classification == "Good") {
      _coreQuestions = [
        {
          "key": "motivation",
          "question":
              "What motivates you to build or maintain this good habit?",
        },
        {
          "key": "obstacle",
          "question": "What might stop you from continuing this habit?",
        },
        {
          "key": "duration",
          "question": "How long do you plan to continue building this habit?",
        },
      ];
    } else if (widget.classification == "Bad") {
      _coreQuestions = [
        {
          "key": "reason",
          "question": "Why do you want to reduce or quit this habit?",
        },
        {
          "key": "challenge",
          "question": "What makes it difficult to let go of this habit?",
        },
        {
          "key": "duration",
          "question": "In how many days do you want to quit this habit?",
        },
      ];
    } //else {
    //   _coreQuestions = [
    //     {
    //       "key": "motivation",
    //       "question": "What is your main motivation related to this habit?",
    //     },
    //     {
    //       "key": "challenges",
    //       "question": "What challenges or obstacles do you face with this habit?",
    //     },
    //     {
    //       "key": "duration",
    //       "question": "How long do you plan to continue building this habit?",
    //     },
    //   ];
    // }

    _coreLength = _coreQuestions.length;
    List<Map<String, String>> dynamicMapped =
        widget.dynamicQuestions.map((q) => {"key": q, "question": q}).toList();

    _allQuestions = [..._coreQuestions, ...dynamicMapped];
    _answers = List.filled(_allQuestions.length, null);
  }

  bool _isNonsense(String input, {String? field}) {
    input = input.trim();

    if (input.isEmpty) return true;

    // Handle duration separately (only 2-digit numbers allowed)
  if (field == "duration") {
    final num = int.tryParse(input);
    return num == null || num < 10 || num > 99;
  }
    // Only digits
    if (RegExp(r'^\d+$').hasMatch(input)) return true;

    // Reject pure emojis or emoji-heavy input
    final emojiRegex = RegExp(
      r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F|\p{Emoji_Modifier_Base})+$',
      unicode: true,
    );
    if (emojiRegex.hasMatch(input)) return true;

    // Reject if all characters are punctuation
    if (RegExp(r'^[^\w\s]+$').hasMatch(input)) return true;

    // Reject repeated characters (e.g., "aaaaaaa", "!!!!!!!")
    if (RegExp(r'^(.)\1{4,}$').hasMatch(input)) return true;

    // Reject too short or meaningless strings
    if (input.length < 4 && input.split(' ').length < 2) return true;

    return false;
  }

  void _nextQuestion() {
    final answer = _answerController.text.trim();
    final fieldKey = _allQuestions[_currentQuestionIndex]["key"];

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an answer before proceeding."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_isNonsense(answer, field: fieldKey)) {
      setState(() {
        _errorText = "Please enter a valid answer";
      });
      return;
    }

    setState(() {
      _answers[_currentQuestionIndex] = answer;
      _answerController.clear();
      _errorText = null;
      _currentQuestionIndex++;
    });
  }

  void _submitAnswers() async {
    final answer = _answerController.text.trim();
    final fieldKey = _allQuestions[_currentQuestionIndex]["key"];
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an answer before submitting."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_isNonsense(answer, field: fieldKey)) {
      setState(() {
        _errorText = "Please enter a valid answer";
      });
      return;
    }

    _answers[_currentQuestionIndex] = answer;
    _errorText = null;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Map<String, String> allResponses = {};
    for (int i = 0; i < _coreLength; i++) {
      final key = _allQuestions[i]["key"]!;
      final value = _answers[i] ?? "";
      allResponses[key] = value;
    }

    for (int i = _coreLength; i < _allQuestions.length; i++) {
      final question = _allQuestions[i]["question"]!;
      final answer = _answers[i] ?? "";
      allResponses[question] = answer;
    }

    Map<String, dynamic> payload = {
      "habit_name": widget.habit,
      "habit_type": widget.classification,
    };

    for (int i = 0; i < _coreLength; i++) {
      final key = _allQuestions[i]["key"]!;
      payload[key] = allResponses[key]!;
    }

    List<Map<String, String>> dynamicAnswers = [];
    for (int i = _coreLength; i < _allQuestions.length; i++) {
      dynamicAnswers.add({
        "question": _allQuestions[i]["question"]!,
        "answer": allResponses[_allQuestions[i]["question"]!]!,
      });
    }

    final finalPayload = {
      "responses": {...payload, "dynamic_answers": dynamicAnswers},
      "regenerate": false,
    };

    final tasks = await AIService.sendToAI(finalPayload);

    // Close loading dialog
    Navigator.of(context).pop();

    if (tasks.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TasksCardView(
            tasks: tasks,
            responses: finalPayload,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to generate tasks."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = _currentQuestionIndex == _allQuestions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Made With AI',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Question ${_currentQuestionIndex + 1} / ${_allQuestions.length}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _allQuestions[_currentQuestionIndex]["question"] ??
                                "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 227, 235, 252),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _answerController,
                              onChanged: (text) {
                                final fieldKey =
                                    _allQuestions[_currentQuestionIndex]["key"];
                                setState(() {
                                  _errorText =
                                      _isNonsense(text, field: fieldKey)
                                          ? "Please enter a valid answer"
                                          : null;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Your answer",
                                border: InputBorder.none,
                                errorText: _errorText,
                              ),
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '"Answer honestly—it helps build a plan that works best for you."',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButton(
                        buttonText: isLastQuestion ? "Submit" : "Next",
                        onPressed:
                            isLastQuestion ? _submitAnswers : _nextQuestion,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}