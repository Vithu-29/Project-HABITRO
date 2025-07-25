// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/models/habit.dart';
import 'package:frontend/theme.dart';
import 'package:intl/intl.dart';
import '../components/standard_app_bar.dart';
import '../services/ai_services.dart';

class ReportScreen extends StatefulWidget {
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<double> completionRates = [];
  List<int> taskCounts = [];
  List<String> labels = [];
  String completionRateChartType = "line";
  String taskCompletedChartType = "bar";
  bool isLoading = true;
  String selectedRange = "daily";
  String? selectedHabitType;
  String? selectedHabitId;
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchHabits();
  }

  // Method to fetch habits
  Future<void> _fetchHabits() async {
    try {
      final habitsData = await AIService.getHabits();
      setState(() {
        habits = habitsData.map((json) => Habit.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint("Error fetching habits: $e");
    }
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final data = await AIService.getCompletionStats(
      selectedRange,
      habitType: selectedHabitType,
      habitId: selectedHabitId,
    );

    setState(() {
      completionRates = List<double>.from(
        data['stats'].map((x) => x.toDouble()),
      );
      labels = List<String>.from(data['labels']);
      taskCounts = List<int>.from(data['taskCounts']);
      isLoading = false;
    });
  }

  List<FlSpot> _getChartSpots() {
    return completionRates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  List<BarChartGroupData> _getBarGroups(double barWidth) {
    String currentLabel;
    if (selectedRange == "daily") {
      currentLabel = DateFormat('E').format(DateTime.now());
    } else {
      currentLabel = DateFormat('MMM').format(DateTime.now());
    }
    final currentDateIndex = labels.indexOf(currentLabel);

    return completionRates.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.key == currentDateIndex
                ? AppColors.primary
                : AppColors.secondary,
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _getTaskBarGroups(double barWidth) {
    String currentLabel;
    if (selectedRange == "daily") {
      currentLabel = DateFormat('E').format(DateTime.now());
    } else {
      currentLabel = DateFormat('MMM').format(DateTime.now());
    }
    final currentDateIndex = labels.indexOf(currentLabel);

    return taskCounts.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: entry.key == currentDateIndex
                ? AppColors.primary
                : AppColors.secondary,
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= labels.length) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          labels[index],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.blackText,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildCustomRangeToggle() {
    final isDaily = selectedRange == "daily";

    return Center(
      child: Container(
        width: 220,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 0.5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!isDaily) {
                    setState(() {
                      selectedRange = "daily";
                      _fetchData();
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDaily ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Weekly',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDaily ? Colors.white : AppColors.blackText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (isDaily) {
                    setState(() {
                      selectedRange = "monthly";
                      _fetchData();
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isDaily ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: 14,
                      color: !isDaily ? Colors.white : AppColors.blackText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedHabitType,
                    hint: const Text(
                      'All Types',
                      style: TextStyle(
                        color: AppColors.blackText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_sharp,
                        color: AppColors.primary),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Types',
                          style: TextStyle(
                            color: AppColors.blackText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Good',
                        child: Text(
                          'Good Habits',
                          style: TextStyle(
                            color: AppColors.blackText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Bad',
                        child: Text(
                          'Bad Habits',
                          style: TextStyle(
                            color: AppColors.blackText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHabitType = value;
                        selectedHabitId = null;
                        _fetchData();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _getFilteredHabits()
                            .any((habit) => habit.id == selectedHabitId)
                        ? selectedHabitId
                        : null,
                    hint: const Text(
                      'All Habits',
                      style: TextStyle(
                        color: AppColors.blackText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_sharp,
                        color: AppColors.primary),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'All Habits',
                          style: TextStyle(
                            color: AppColors.blackText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ..._getFilteredHabits().map((habit) {
                        return DropdownMenuItem<String?>(
                          value: habit.id,
                          child: Text(
                            habit.name,
                            style: const TextStyle(
                              color: AppColors.blackText,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHabitId = value;
                        _fetchData();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get filtered habits
  List<Habit> _getFilteredHabits() {
    if (selectedHabitType == 'Good') {
      return habits.where((habit) => habit.type == 'Good').toList();
    } else if (selectedHabitType == 'Bad') {
      return habits.where((habit) => habit.type == 'Bad').toList();
    }
    return habits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StandardAppBar(appBarTitle: "Report"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight * 0.32;
                final barWidth =
                    (constraints.maxWidth - 100) / labels.length * 0.7;
                final maxTaskCount = taskCounts.isNotEmpty
                    ? taskCounts.reduce((a, b) => a > b ? a : b)
                    : 0;

                final double maxY = maxTaskCount > 0
                    ? (maxTaskCount < 5 ? 5 : maxTaskCount * 1.2)
                    : 5;
                final double interval = maxY > 0 ? (maxY / 5) : 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCustomRangeToggle(),
                        _buildHabitFilters(),
                        // COMPLETION RATE CHART
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Completion Rate",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blackText,
                                          ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          completionRateChartType =
                                              completionRateChartType == "line"
                                                  ? "bar"
                                                  : "line";
                                        });
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          completionRateChartType == "line"
                                              ? Icons.bar_chart
                                              : Icons.show_chart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: chartHeight,
                                  child: completionRateChartType == "line"
                                      ? LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: _getChartSpots(),
                                                isCurved: true,
                                                color: AppColors.primary,
                                                barWidth: 3,
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primary
                                                          .withOpacity(0.3),
                                                      AppColors.primary
                                                          .withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                      barData, index) {
                                                    return FlDotCirclePainter(
                                                      radius: 4,
                                                      color: AppColors.primary,
                                                      strokeWidth: 2,
                                                      strokeColor: Colors.white,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      _bottomTitleWidgets,
                                                  reservedSize:
                                                      42, 
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4.0),
                                                      child: Text(
                                                        '${value.toInt()}%',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .blackText,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 40,
                                                  interval: 20,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(),
                                              topTitles: const AxisTitles(),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              drawHorizontalLine: true,
                                              horizontalInterval: 20,
                                              getDrawingHorizontalLine:
                                                  (value) => FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                          ),
                                        )
                                      : BarChart(
                                          BarChartData(
                                            barGroups: _getBarGroups(barWidth),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      _bottomTitleWidgets,
                                                  reservedSize:
                                                      42, 
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4.0),
                                                      child: Text(
                                                        '${value.toInt()}%',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .blackText,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 40,
                                                  interval: 20,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(),
                                              topTitles: const AxisTitles(),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              drawHorizontalLine: true,
                                              horizontalInterval: 20,
                                              getDrawingHorizontalLine:
                                                  (value) => FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: 100,
                                            groupsSpace: 12,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // TASKS COMPLETED CHART
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tasks Completed",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blackText,
                                          ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          taskCompletedChartType =
                                              taskCompletedChartType == "line"
                                                  ? "bar"
                                                  : "line";
                                        });
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          taskCompletedChartType == "line"
                                              ? Icons.bar_chart
                                              : Icons.show_chart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: chartHeight,
                                  child: taskCompletedChartType == "line"
                                      ? LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: taskCounts
                                                    .asMap()
                                                    .entries
                                                    .map(
                                                      (entry) => FlSpot(
                                                        entry.key.toDouble(),
                                                        entry.value.toDouble(),
                                                      ),
                                                    )
                                                    .toList(),
                                                isCurved: true,
                                                color: Colors.indigo,
                                                barWidth: 3,
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primary
                                                          .withOpacity(0.3),
                                                      AppColors.primary
                                                          .withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                      barData, index) {
                                                    return FlDotCirclePainter(
                                                      radius: 4,
                                                      color: AppColors.primary,
                                                      strokeWidth: 2,
                                                      strokeColor: Colors.white,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      _bottomTitleWidgets,
                                                  reservedSize:
                                                      42, 
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4.0),
                                                      child: Text(
                                                        value
                                                            .toInt()
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .blackText,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 40,
                                                  interval: interval,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(),
                                              topTitles: const AxisTitles(),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              drawHorizontalLine: true,
                                              horizontalInterval: interval,
                                              getDrawingHorizontalLine:
                                                  (value) => FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: maxY,
                                          ),
                                        )
                                      : BarChart(
                                          BarChartData(
                                            barGroups:
                                                _getTaskBarGroups(barWidth),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      _bottomTitleWidgets,
                                                  reservedSize:
                                                      42, 
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4.0),
                                                      child: Text(
                                                        value
                                                            .toInt()
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .blackText,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 40,
                                                  interval: interval,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(),
                                              topTitles: const AxisTitles(),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              drawHorizontalLine: true,
                                              horizontalInterval: interval,
                                              getDrawingHorizontalLine:
                                                  (value) => FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                            minY: 0,
                                            maxY: maxY,
                                            groupsSpace: 12,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
