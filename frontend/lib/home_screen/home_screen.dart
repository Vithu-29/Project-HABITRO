import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:frontend/home_screen/home_app_bar.dart';
import 'package:frontend/onboarding_content.dart';
import '../services/ai_services.dart';
import '../models/habit.dart';
import '../api_services/challenge_service.dart'; // Correct import
import './first.dart';
import './mychallenges_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'challenge_model.dart'; // <-- Use relative import instead of ../models/challenge_model.dart

class HomeScreen extends StatefulWidget {
  final bool isNewSignIn;
  final Function(bool)? onOnboardingStateChanged;
  final bool isOnboardingActive; // Add this parameter

  const HomeScreen({
    this.isNewSignIn = false,
    this.onOnboardingStateChanged,
    this.isOnboardingActive = false, // Default to false
    super.key,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Habit>> habits;
  late Future<List<UserChallenge>> userChallenges; // <-- Add this line
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  late ConfettiController _confettiController;
  int userCoins = 0;
  double completionRate = 0.0;
  bool _isCelebrating = false;

  // Onboarding tutorial variables
  int onboardingStep = 0;
  bool showOnboarding = false;
  bool onboardingCompleted = false;

  // Define keys for navigation items
  final GlobalKey fabKey = GlobalKey();
  final GlobalKey dateKey = GlobalKey();
  final GlobalKey exploreKey = GlobalKey();
  final GlobalKey reportKey = GlobalKey();
  final GlobalKey rewardKey = GlobalKey();
  final GlobalKey profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadCoins();
    _refreshHabits();
    userChallenges = ChallengeService.getUserChallenges().then((data) => data
        .map((e) => UserChallenge.fromJson(e))
        .toList()); // <-- Add this line

    // Always show onboarding when user enters the screen after sign-in
    _checkSignInStatus();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Check if user is signed in and show onboarding accordingly
  Future<void> _checkSignInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedIn = prefs.getBool('is_signed_in') ?? false;

    if (isSignedIn) {
      // User is signed in, show onboarding
      setState(() {
        showOnboarding = true;
        onboardingStep = 0; // Reset to first step
      });

      // Notify parent about onboarding state
      if (widget.onOnboardingStateChanged != null) {
        widget.onOnboardingStateChanged!(true);
      }

      // Mark as signed in but not completed onboarding yet
      await prefs.setBool('is_signed_in', false); // Reset sign-in flag
    } else {
      // Check if onboarding was previously completed
      _checkOnboardingStatus();
    }
  }

  // Onboarding methods
  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      onboardingCompleted = completed;
      showOnboarding = !completed && widget.isNewSignIn;
    });

    // Notify parent about onboarding state
    if (widget.onOnboardingStateChanged != null) {
      widget.onOnboardingStateChanged!(showOnboarding);
    }
  }

  void _nextOnboardingStep() {
    setState(() {
      if (onboardingStep < onboardingItems.length - 1) {
        onboardingStep++;
        // Auto-switch navigation tab for nav steps
        final navTargets = {
          'explore': 1,
          'report': 2,
          'reward': 3,
          'profile': 4,
        };
        final target = onboardingItems[onboardingStep].targetElement;
        if (navTargets.containsKey(target)) {
          // Handle navigation switching if needed
        }
      } else {
        setState(() {
          showOnboarding = false;
          onboardingCompleted = true;
        });
        _saveOnboardingCompleted();

        // Notify parent that onboarding is completed
        if (widget.onOnboardingStateChanged != null) {
          widget.onOnboardingStateChanged!(false);
        }
      }
    });
  }

  Future<void> _saveOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  Offset? _getTargetOffset(String? target) {
    RenderBox? box;
    switch (target) {
      case 'fab':
        box = fabKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'date':
        box = dateKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'explore':
        box = exploreKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'report':
        box = reportKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'reward':
        box = rewardKey.currentContext?.findRenderObject() as RenderBox?;
        break;
      case 'profile':
        box = profileKey.currentContext?.findRenderObject() as RenderBox?;
        break;
    }
    return box?.localToGlobal(Offset.zero);
  }

  Widget _buildFingerIcon({required String target}) {
    String assetPath = 'assets/icons/finger_down.png';
    switch (target) {
      case 'fab':
        assetPath = 'assets/icons/finger_right.png';
        break;
      case 'date':
        assetPath = 'assets/icons/finger_up.png';
        break;
      case 'explore':
      case 'report':
      case 'reward':
      case 'profile':
        assetPath = 'assets/icons/finger_down.png';
        break;
      default:
        assetPath = 'assets/icons/finger_down.png';
    }
    return Image.asset(
      assetPath,
      width: 32,
      height: 32,
    );
  }

  Widget _buildOnboardingOverlay() {
    if (!showOnboarding) return const SizedBox();

    final item = onboardingItems[onboardingStep];
    final target = item.targetElement;

    // Next/Finish button styled as in the screenshots, inside the message box, right-aligned
    Widget nextButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, right: 8, bottom: 4),
          child: ElevatedButton(
            onPressed: _nextOnboardingStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2853AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              item.buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );

    Widget messageBoxWithButton = Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 16), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Centered content
        children: [
          if (item.title.isNotEmpty) ...[
            Image.asset(
              'assets/images/welcome.png',
              height: 100, // height
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22, //  size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16, //  size
              color: Color(0xFF2853AF),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          nextButton,
        ],
      ),
    );

    // Handle different onboarding steps
    if (target == 'fab') {
      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Align(
            alignment: const Alignment(0.85, 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                messageBoxWithButton,
                const SizedBox(height: 1),
                _buildFingerIcon(target: 'fab'),
              ],
            ),
          ),
        ],
      );
    } else if (target == 'date') {
      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            children: [
              const SizedBox(height: 30),
              _buildFingerIcon(target: 'date'),
              const SizedBox(height: 1),
              Align(
                alignment: const Alignment(0.0, -0.3),
                child: messageBoxWithButton,
              ),
            ],
          ),
        ],
      );
    } else if (target == 'explore' ||
        target == 'report' ||
        target == 'reward' ||
        target == 'profile') {
      double horizontalOffset = 0.0;
      if (target == 'explore') horizontalOffset = -0.5;
      if (target == 'report') horizontalOffset = -0.05;
      if (target == 'reward') horizontalOffset = 0.4;
      if (target == 'profile') horizontalOffset = 0.8;

      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment(horizontalOffset, 0),
                child: Container(
                  width: 280,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2853AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      nextButton,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment(horizontalOffset, 0),
                child: _buildFingerIcon(target: target!),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      );
    }

    // Default (centered welcome)
    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.5)),
        Align(
          alignment: Alignment.center,
          child: messageBoxWithButton,
        ),
      ],
    );
  }

  Future<void> _loadCoins() async {
    try {
      final coins = await AIService.getCoinBalance();
      setState(() => userCoins = coins);
    } catch (e) {
      // final localCoins = await CoinService.getCoins();
      // setState(() => userCoins = localCoins);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Failed to show coin balance. Please check your connection.')),
      );
    }
  }

  Future<void> _deductCoins(int amount, {String reason = 'adjustment'}) async {
    try {
      final newBalance = await AIService.deductCoins(amount);
      setState(() => userCoins = newBalance);
    } catch (e) {
      // await CoinService.deductCoins(amount);
      // await _loadCoins();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to deduct coins. Please check your connection.')),
      );
    }
  }

  Future<void> _addCoinsForTaskCompletion() async {
    try {
      final newBalance = await AIService.addCoins(10);
      setState(() => userCoins = newBalance);
    } catch (e) {
      // await CoinService.addCoins(100);
      // await _loadCoins();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to add coins. Please check your connection.')),
      );
    }
  }

  double calculateCompletionRate(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;
    int totalTasks = 0;
    int completedTasks = 0;

    for (var habit in habits) {
      totalTasks += habit.tasks.length;
      completedTasks += habit.tasks.where((task) => task.isCompleted).length;
    }

    return totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  }

  Future<void> _saveCelebrationDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCelebrationDate', date);
  }

  Future<String?> _getLastCelebrationDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastCelebrationDate');
  }

  void checkForCompletionCelebration(List<Habit> habits) async {
    final rate = calculateCompletionRate(habits);
    setState(() {
      completionRate = rate;
    });

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? lastCelebrationDate = await _getLastCelebrationDate();

    if (rate == 1.0 && !_isCelebrating && lastCelebrationDate != today) {
      _isCelebrating = true;
      _confettiController.play();
      await _saveCelebrationDate(today);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Congratulations! 🎉'),
          content: const Text('You completed all your tasks for today!'),
          actions: [
            TextButton(
              child: const Text('Awesome!'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      ).then((_) {
        _confettiController.stop();
        _isCelebrating = false;
      });
    }
  }

  Future<void> _refreshHabits() async {
    final refreshedHabits = AIService().fetchHabitsWithTodayTasks();
    setState(() {
      habits = refreshedHabits;
      userChallenges = ChallengeService.getUserChallenges().then((data) => data
          .map((e) => UserChallenge.fromJson(e))
          .toList()); // <-- Add this line
    });

    refreshedHabits.then((loadedHabits) {
      checkForCompletionCelebration(loadedHabits);
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      if (DateFormat('yyyy-MM-dd').format(date) ==
          DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        _refreshHabits();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBar(
        key: dateKey, // Add key for onboarding
        currentDate: currentDate,
        selectedDate: selectedDate,
        onDateSelected: _handleDateSelected,
        completionRate: completionRate,
        userCoins: userCoins,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _refreshHabits();
            },
            child: CustomScrollView(
              slivers: [
                // Regular habits section
                SliverToBoxAdapter(
                  child: FutureBuilder<List<Habit>>(
                    future: habits,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height:
                                          70), // <-- Add this line to push content down
                                  Image.asset(
                                    'assets/images/home_img.png',
                                    width: screenWidth * 0.9,
                                  ),
                                  const Text("You have no habits"),
                                  const Text(
                                      "Add a habit by clicking (+) icon below."),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...snapshot.data!
                                .map((habit) => buildHabitTile(habit)),
                            // Challenge habits section
                            FutureBuilder<List<UserChallenge>>(
                              future: userChallenges,
                              builder: (context, challengeSnapshot) {
                                if (challengeSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (challengeSnapshot.hasError ||
                                    !challengeSnapshot.hasData) {
                                  return const SizedBox();
                                }
                                final challengeHabits = challengeSnapshot.data!
                                    .expand((uc) => uc.habits)
                                    .toList();
                                if (challengeHabits.isEmpty) {
                                  return const SizedBox();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 12.0),
                                      child: Text(
                                        "Challenge Habits",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    ...challengeHabits.map((userHabit) =>
                                        buildChallengeHabitTile(userHabit)),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                'Error loading habits',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshHabits,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),

                // Add some bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Add onboarding overlay - must be last in stack
          if (showOnboarding) _buildOnboardingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: fabKey, // Add key for onboarding
        onPressed: (widget.isOnboardingActive || showOnboarding)
            ? null // Disable during onboarding or when overlay is shown
            : () {
                _showAddOptions(context);
              },
        shape: const CircleBorder(),
        backgroundColor: (widget.isOnboardingActive || showOnboarding)
            ? Colors.grey.shade400 // More visible grey when disabled
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        tooltip: (widget.isOnboardingActive || showOnboarding)
            ? 'Complete the tutorial first'
            : 'Add a new habit',
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.blue),
                ),
                title: const Text(
                  'Add With AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FirstScreen()),
                  ).then((_) => _refreshHabits());
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flag, color: Colors.blue),
                ),
                title: const Text(
                  'Challenges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyChallengesScreen(),
                    ),
                  ).then((_) =>
                      _refreshHabits()); // Use _refreshHabits instead of _loadActiveChallenges
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget buildHabitTile(Habit habit) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(habit.type),
                  backgroundColor: habit.type == "Good"
                      ? const Color.fromARGB(255, 189, 249, 188)
                      : const Color.fromARGB(255, 244, 168, 168),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...habit.tasks.map(
              (task) => Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) async {
                      final wasCompleted = task.isCompleted;
                      final willBeCompleted = value ?? false;

                      await AIService()
                          .updateTaskStatus(task.id, willBeCompleted);

                      if (wasCompleted && !willBeCompleted) {
                        await _deductCoins(10, reason: 'task_unchecked');
                      } else if (!wasCompleted && willBeCompleted) {
                        await _addCoinsForTaskCompletion();
                        // Show success message for regular habit
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Habit completed successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }

                      setState(() {
                        task.isCompleted = willBeCompleted;
                      });

                      _refreshHabits();
                    },
                  ),
                  Expanded(child: Text(task.task)),
                  if (task.isCompleted)
                    const Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber),
                        Text("+100"),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChallengeHabitTile(UserChallengeHabit userHabit) {
    final habit = userHabit.habit;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // Remove blue background
      color: Colors.white, // <-- Remove blue theme
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: userHabit.isCompleted,
              onChanged: (bool? value) async {
                try {
                  final result = await ChallengeService.updateHabitStatus(
                      userHabit.id, value ?? false);

                  setState(() {
                    userHabit.isCompleted = value ?? false;
                  });

                  // Show gem add/remove message if present
                  if (result is Map && result.containsKey('message')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor:
                            (result['message'].toString().contains('gain'))
                                ? Colors.green
                                : Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (value == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Habit completed successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }

                  // Optionally update gems in UI if needed (result['gems'])
                  // You may want to trigger a refresh of the reward screen here

                  _refreshHabits();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating habit: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      // Remove blue color
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    habit.description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    "Frequency: ${habit.frequency}",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black), // Remove blue color
                  ),
                  if (userHabit.isCompleted && userHabit.completedDate != null)
                    Text(
                      "Completed: ${userHabit.completedDate}",
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
