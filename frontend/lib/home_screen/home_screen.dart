import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:frontend/home_screen/home_app_bar.dart';
import '../services/ai_services.dart';
import '../models/habit.dart';
import '../services/coin_services.dart';
import './first.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Habit>> habits;
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  late ConfettiController _confettiController;
  int userCoins = 0;
  double completionRate = 0.0;
  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadCoins();
    _refreshHabits();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    try {
      final coins = await AIService.getCoinBalance();
      setState(() => userCoins = coins);
    } catch (e) {
      final localCoins = await CoinService.getCoins();
      setState(() => userCoins = localCoins);
    }
  }

  Future<void> _deductCoins(int amount, {String reason = 'adjustment'}) async {
    try {
      final newBalance = await AIService.deductCoins(amount, reason: reason);
      setState(() => userCoins = newBalance);
    } catch (e) {
      await CoinService.deductCoins(amount);
      await _loadCoins();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Deducted coins locally (offline mode)')),
      // );
    }
  }

  Future<void> _addCoinsForTaskCompletion() async {
    try {
      final newBalance = await AIService.addCoins(10, reason: 'task_completion');
      setState(() => userCoins = newBalance);
    } catch (e) {
      await CoinService.addCoins(10);
      await _loadCoins();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Connected to local coins (offline mode)')),
      // );
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
        currentDate: currentDate,
        selectedDate: selectedDate,
        onDateSelected: _handleDateSelected,
        completionRate: completionRate,
        userCoins: userCoins,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Habit>>(
            future: habits,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/home_img.png',
                          width: screenWidth * 0.9,
                        ),
                        const Text("You have no habits"),
                        const Text("Add a habit by clicking (+) icon below."),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstScreen(),
                              ),
                            ).then((_) => _refreshHabits());
                          },
                          child: const Text('Add your first habit'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshHabits,
                  child: ListView(
                    children: snapshot.data!
                        .map((habit) => buildHabitTile(habit))
                        .toList(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  FirstScreen()),
          ).then((_) => _refreshHabits());
        },
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
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
                      ? const Color.fromARGB(255, 15, 102, 202)
                      : Colors.red[100],
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
                        Text("+10"),
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
}
