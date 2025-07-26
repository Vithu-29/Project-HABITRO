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
  bool isCompleted;
  String? completedDate;
  Map<String, bool> dailyStatus; // key: yyyy-MM-dd, value: completed
  DateTime lastUpdated; // New field to track last update time

  UserChallengeHabit({
    required this.id,
    required this.habit,
    required this.isCompleted,
    this.completedDate,
    Map<String, bool>? dailyStatus,
    required this.lastUpdated, // Added required parameter
  }) : dailyStatus = dailyStatus ?? {};

  factory UserChallengeHabit.fromJson(Map<String, dynamic> json) {
    // Parse dailyStatus if present, else empty
    Map<String, bool> dailyMap = {};
    if (json.containsKey('daily_status')) {
      (json['daily_status'] as Map<String, dynamic>).forEach((k, v) {
        dailyMap[k] = v == true;
      });
    }
    
    // Get current Sri Lanka time
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    
    return UserChallengeHabit(
      id: json['id'],
      habit: ChallengeHabit.fromJson(json['habit']),
      isCompleted: json['is_completed'],
      completedDate: json['completed_date'],
      dailyStatus: dailyMap,
      lastUpdated: now, // Initialize with current time
    );
  }

  // Helper: get today's status (Sri Lanka time)
  bool getTodayStatus() {
    resetDailyStatus(); // Reset if needed
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final todayStr = 
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return dailyStatus[todayStr] ?? false;
  }

  void setTodayStatus(bool value) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final todayStr = 
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    dailyStatus[todayStr] = value;
    lastUpdated = now; // Update lastUpdated timestamp
  }
  
  // Reset daily status if it's a new day
  void resetDailyStatus() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    
    // Check if last update was on a different day
    if (lastUpdated.day != now.day || 
        lastUpdated.month != now.month || 
        lastUpdated.year != now.year) {
      isCompleted = false;
      lastUpdated = now;
    }
  }
}