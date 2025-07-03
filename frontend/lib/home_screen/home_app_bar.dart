import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime currentDate;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double completionRate;
  final int userCoins;

  const HomeAppBar({
    super.key,
    required this.currentDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.completionRate,
    required this.userCoins,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120); // Increased height

  List<DateTime> getWeekDates() {
    return List.generate(7, (index) {
      return currentDate.subtract(Duration(days: 3 - index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('yyyy-MM-dd').format(currentDate);
    final selectedFormatted = DateFormat('yyyy-MM-dd').format(selectedDate);
    final weekDates = getWeekDates();

    return AppBar(
      toolbarHeight: 120, // Match preferredSize
      title: Column(
        children: [
          // Top row with greeting and coins
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between greeting and coins
            children: [
              // "Hello User!" text on the left
              const Text(
                "Hello User!",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Coin display on the right
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    userCoins.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date selector
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                final date = weekDates[index];
                final isSelected = DateFormat('yyyy-MM-dd').format(date) == selectedFormatted;
                final isToday = DateFormat('yyyy-MM-dd').format(date) == todayFormatted;
                final progress = isToday ? completionRate : 0.0;

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    width: 45,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(date).substring(0, 3),
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: CircularProgressIndicator(
                                value: progress,
                                backgroundColor: const Color.fromRGBO(167, 165, 165, 0.3), //progress indicator bg color
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0
                                      ? Colors.amber 
                                      : isSelected
                                          ? const Color.fromARGB(255, 20, 74, 183)
                                          : const Color.fromARGB(255, 183, 179, 179),
                                ),
                                strokeWidth: 4,
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.grey,
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
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final int selectedIndex;
//   final Function(int) onDateSelected;

//   const HomeAppBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onDateSelected,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(165);

//   @override
//   CustomAppBarState createState() => CustomAppBarState();
// }

// class CustomAppBarState extends State<HomeAppBar> {
//   List<DateTime> currentWeek = [];
//   Map<int, double> taskCompletion = {}; // Task progress data

//   @override
//   void initState() {
//     super.initState();
//     generateCurrentWeek();
//     initializeTaskProgress();
//   }

//   // Generate current week dynamically (Monday - Sunday)
//   void generateCurrentWeek() {
//     DateTime today = DateTime.now();
//     int currentWeekday = today.weekday;
//     DateTime monday = today.subtract(Duration(days: currentWeekday - 1));

//     for (int i = 0; i < 7; i++) {
//       currentWeek.add(monday.add(Duration(days: i)));
//     }
//   }

//   // Initialize dummy task progress (random values)
//   void initializeTaskProgress() {
//     for (int i = 0; i < 7; i++) {
//       taskCompletion[i] = (i + 1) / 7;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(25, 35, 25, 10),
//       color: Colors.white, // AppBar background
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Greeting & Icons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Hello, User!",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.notifications_none, size: 30),
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.filter_alt_outlined, size: 30),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           // Date Selector with Progress Indicators
//           SizedBox(
//             height: 80,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: currentWeek.length,
//               itemBuilder: (context, index) {
//                 bool isSelected = index == widget.selectedIndex;
//                 DateTime date = currentWeek[index];
//                 String dayName = DateFormat('E').format(date);
//                 int dayNumber = date.day;

//                 return GestureDetector(
//                   onTap: () => widget.onDateSelected(index),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           dayName,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: isSelected ? Colors.black : Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // Circular Progress Indicator
//                             SizedBox(
//                               width: 30,
//                               height: 30,
//                               child: CircularProgressIndicator(
//                                 value: taskCompletion[index],
//                                 backgroundColor: Colors.grey.shade300,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   isSelected ? Colors.blue : Colors.green,
//                                 ),
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                             // Date inside the circle
//                             Positioned(
//                               child: Text(
//                                 "$dayNumber",
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold,
//                                   color: isSelected
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
