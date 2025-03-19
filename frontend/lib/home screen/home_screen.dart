import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<DateTime> currentWeek = [];
  Map<int, double> taskCompletion = {}; // Store task progress for each day

  @override
  void initState() {
    super.initState();
    generateCurrentWeek();
    initializeTaskProgress();
  }

  // Generate the current week dynamically (Monday - Sunday)
  void generateCurrentWeek() {
    DateTime today = DateTime.now();
    int currentWeekday = today.weekday; // 1 = Monday, 7 = Sunday
    DateTime monday = today.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 7; i++) {
      currentWeek.add(monday.add(Duration(days: i)));
    }
  }

  // Initialize dummy task progress (random values)
  void initializeTaskProgress() {
    for (int i = 0; i < 7; i++) {
      taskCompletion[i] = (i + 1) / 7; // Example progress (1/7, 2/7, ...)
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Different background color for Scaffold
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(165), // Height of AppBar
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 35, 25, 10),
          color: Colors.white, // AppBar White Background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hello, User!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date Selector with Progress Indicators
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentWeek.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == selectedIndex;
                    DateTime date = currentWeek[index];
                    String dayName =
                        DateFormat('E').format(date); // Mon, Tue, etc.
                    int dayNumber = date.day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circular Progress Indicator
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    value:
                                        taskCompletion[index], // Progress value
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isSelected ? Colors.blue : Colors.green,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                                // Date inside the circle
                                Positioned(
                                  child: Text(
                                    "$dayNumber",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/home_img.png',
              width: screenWidth * 0.9,
            ),
            Text("You have no habits",),
            Text("Add a habit by clicking (+) icon below."),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        shape: CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
