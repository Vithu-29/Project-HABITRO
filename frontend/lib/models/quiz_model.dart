class Quiz {
  final String question;
  final List<String> options;
  final String answer;

  Quiz({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      options: [
        json['option_1'],
        json['option_2'],
        json['option_3'],
        json['option_4'],
      ],
      answer: json['answer'],
    );
  }
}

class QuizResponse {
  final List<Quiz> quizzes;
  final int currentQuestionIndex;

  QuizResponse({
    required this.quizzes,
    required this.currentQuestionIndex,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      quizzes: (json['quizzes'] as List)
          .map((quizJson) => Quiz.fromJson(quizJson))
          .toList(),
      currentQuestionIndex: json['current_question_index'],
    );
  }
}