import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/challenge_service.dart';
import 'challenge_model.dart';

class MyChallengesScreen extends StatefulWidget {
  const MyChallengesScreen({Key? key}) : super(key: key);

  @override
  _MyChallengesScreenState createState() => _MyChallengesScreenState();
}

class _MyChallengesScreenState extends State<MyChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = FlutterSecureStorage();

  List<Challenge> availableChallenges = [];
  List<UserChallenge> myChallenges = [];
  bool isLoading = true;
  String? error;

  // Track selected habits for each challenge
  Map<int, List<int>> selectedHabits = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChallenges();
  }

  Future<String?> _getToken() async {
    return await storage.read(key: 'authToken');
  }

  Future<void> _loadChallenges() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // First check if token exists
      final token = await _getToken();
      if (token == null) {
        setState(() {
          error = "Authentication token not found. Please log in again.";
          isLoading = false;
        });

        // Show a dialog with option to go to login screen
        _showLoginRequiredDialog();
        return;
      }

      // Then try to load data
      final availableChallengesData =
          await ChallengeService.getAvailableChallenges();
      final myChallengesData = await ChallengeService.getUserChallenges();

      // Process and use the fetched data
      setState(() {
        availableChallenges = availableChallengesData
            .map((data) => Challenge.fromJson(data))
            .toList();
        myChallenges = myChallengesData
            .map((data) => UserChallenge.fromJson(data))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error loading challenges: $e');

      // If error contains "token" or "authentication", show login dialog
      if (e.toString().toLowerCase().contains("token") ||
          e.toString().toLowerCase().contains("auth")) {
        _showLoginRequiredDialog();
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Authentication Required'),
        content:
            Text('Your session has expired. Please sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              // Clear any saved tokens
              _clearTokens();
              // Navigate to sign-in screen, replacing the current route
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearTokens() async {
    try {
      final storage = FlutterSecureStorage();
      await storage.delete(key: 'authToken');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.setBool('is_signed_in', false);
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  void _toggleHabitSelection(int challengeId, int habitId) {
    setState(() {
      if (selectedHabits[challengeId] == null) {
        selectedHabits[challengeId] = [];
      }

      if (selectedHabits[challengeId]!.contains(habitId)) {
        selectedHabits[challengeId]!.remove(habitId);
      } else {
        selectedHabits[challengeId]!.add(habitId);
      }
    });
  }

  Future<void> _joinChallenge(int challengeId) async {
    if (selectedHabits[challengeId]?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select at least one habit to join the challenge'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ChallengeService.joinChallenge(
          challengeId, selectedHabits[challengeId] ?? []);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined challenge!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset selections and reload data
        setState(() {
          selectedHabits[challengeId] = [];
        });

        await _loadChallenges();
        _tabController.animateTo(1); // Switch to My Challenges tab
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join challenge'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateHabitStatus(int habitId, bool isCompleted) async {
    try {
      final success =
          await ChallengeService.updateHabitStatus(habitId, isCompleted);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCompleted
                ? 'Habit completed!'
                : 'Habit marked as incomplete'),
            backgroundColor: isCompleted ? Colors.green : Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
        await _loadChallenges(); // Refresh to show updated status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update habit status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating habit: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: 'Discover'),
            Tab(text: 'My Challenges'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: $error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChallenges,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDiscoverTab(),
                    _buildMyChallengesTab(),
                  ],
                ),
    );
  }

  Widget _buildDiscoverTab() {
    if (availableChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No challenges available'),
            SizedBox(height: 8),
            Text('Check back later for new challenges!'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChallenges,
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: availableChallenges.length,
        itemBuilder: (context, index) {
          final challenge = availableChallenges[index];

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge header
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          challenge.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${challenge.durationDays} days',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Challenge title
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Challenge description
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                  // Habits list with checkboxes
                  if (challenge.habits.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Habits in this challenge:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    ...challenge.habits.map((habit) {
                      bool isSelected =
                          selectedHabits[challenge.id]?.contains(habit.id) ??
                              false;

                      return CheckboxListTile(
                        title: Text(habit.title),
                        subtitle: Text(
                          habit.description,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleHabitSelection(challenge.id, habit.id);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            habit.frequency,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    // Join challenge button
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _joinChallenge(challenge.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Join Challenge'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyChallengesTab() {
    if (myChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No challenges joined yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Join a challenge from the Discover tab!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text('Discover Challenges'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: myChallenges.length,
        itemBuilder: (context, index) {
          final userChallenge = myChallenges[index];
          final challenge = userChallenge.challenge;
          final completedHabits =
              userChallenge.habits.where((h) => h.isCompleted).length;
          final totalHabits = userChallenge.habits.length;
          final progress =
              totalHabits > 0 ? completedHabits / totalHabits : 0.0;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge header
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          challenge.category,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Started: ${_formatDate(userChallenge.startDate)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Challenge title
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Progress indicator
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$completedHabits of $totalHabits habits completed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Challenge habits with checkboxes to mark completion
                  Text(
                    'My Habits:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  ...userChallenge.habits.map((userHabit) {
                    final habit = userHabit.habit;

                    return CheckboxListTile(
                      title: Text(
                        habit.title,
                        style: TextStyle(
                          decoration: userHabit.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.description,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (userHabit.completedDate != null)
                            Text(
                              'Completed: ${_formatDate(userHabit.completedDate!)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                      value: userHabit.isCompleted,
                      onChanged: (bool? value) {
                        _updateHabitStatus(userHabit.id, value ?? false);
                      },
                      secondary: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          habit.frequency,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0].substring(2)}';
    }
    return dateString;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
