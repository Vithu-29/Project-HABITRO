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
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Space between greeting and coins
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
                final isSelected =
                    DateFormat('yyyy-MM-dd').format(date) == selectedFormatted;
                final isToday =
                    DateFormat('yyyy-MM-dd').format(date) == todayFormatted;
                final progress = isToday ? completionRate : 0.0;

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    width: 42, // Decrease from 45 to 40 if needed
                    margin: const EdgeInsets.symmetric(
                        horizontal: 6), // Increase this value from 2 to 8
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(date).substring(0, 3),
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                                backgroundColor: const Color.fromRGBO(167, 165,
                                    165, 0.3), //progress indicator bg color
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0
                                      ? Colors.amber
                                      : isSelected
                                          ? const Color.fromARGB(
                                              255, 20, 74, 183)
                                          : const Color.fromARGB(
                                              255, 183, 179, 179),
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
      automaticallyImplyLeading: false, // Remove the back button
    );
  }
}
