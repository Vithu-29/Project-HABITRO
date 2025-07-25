class Challenge {
  final int id;
  final String title;
  final String description;
  final String category;
  final int durationDays;
  final List<ChallengeHabit> habits;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.habits,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      durationDays: json['duration_days'],
      habits: (json['habits'] as List)
          .map((habit) => ChallengeHabit.fromJson(habit))
          .toList(),
    );
  }
}

class ChallengeHabit {
  final int id;
  final String title;
  final String description;
  final String frequency;

  ChallengeHabit({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
  });

  factory ChallengeHabit.fromJson(Map<String, dynamic> json) {
    return ChallengeHabit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      frequency: json['frequency'],
    );
  }
}

class UserChallenge {
  final int id;
  final Challenge challenge;
  final String startDate;
  final bool isActive;
  final List<UserChallengeHabit> habits;

  UserChallenge({
    required this.id,
    required this.challenge,
    required this.startDate,
    required this.isActive,
    required this.habits,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'],
      challenge: Challenge.fromJson(json['challenge']),
      startDate: json['start_date'],
      isActive: json['is_active'],
      habits: (json['habits'] as List)
          .map((habit) => UserChallengeHabit.fromJson(habit))
          .toList(),
    );
  }
}

class UserChallengeHabit {
  final int id;
  final ChallengeHabit habit;
  final bool isCompleted;
  final String? completedDate;

  UserChallengeHabit({
    required this.id,
    required this.habit,
    required this.isCompleted,
    this.completedDate,
  });

  factory UserChallengeHabit.fromJson(Map<String, dynamic> json) {
    return UserChallengeHabit(
      id: json['id'],
      habit: ChallengeHabit.fromJson(json['habit']),
      isCompleted: json['is_completed'],
      completedDate: json['completed_date'],
    );
  }
}