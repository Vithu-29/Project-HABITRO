import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/ai_services.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData(); // Initially load "daily" stats
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final data = await AIService.getCompletionStats(selectedRange);

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

  List<BarChartGroupData> _getBarGroups() {
    final today = DateFormat('E').format(DateTime.now()); // gives 'Thu'
    final currentDateIndex =
        labels.indexOf(today); // finds 'Thu' in labels list
    return completionRates.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.key == currentDateIndex
                ? const Color(0xFF2853AF)
                : const Color(0xFFAFC1E7), // Change color based on current date
            width: 30,
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _getTaskBarGroups() {
    final today =
        DateFormat('E').format(DateTime.now()); // gives 3 word day label
    final currentDateIndex =
        labels.indexOf(today); // finds 'day' in labels list
    return taskCounts.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: entry.key == currentDateIndex
                ? const Color(0xFF2853AF)
                : const Color(0xFFAFC1E7), // Change color based on current date
            width: 30,
          ),
        ],
      );
    }).toList();
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= labels.length) return const Text('');
    return Text(labels[index], style: const TextStyle(fontSize: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Report",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Range",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedRange,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedRange = value);
                            _fetchData(); // Fetch new data for selected range
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: "daily",
                            child: Text("Daily"),
                          ),
                          DropdownMenuItem(
                            value: "monthly",
                            child: Text("Monthly"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // COMPLETION RATE CHART
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Completion Rate",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                            color: const Color(0xFF2853AF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            completionRateChartType == "line"
                                ? Icons.bar_chart
                                : Icons.show_chart,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: completionRateChartType == "line"
                        ? LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getChartSpots(),
                                  isCurved: false,
                                  color: Colors.blue,
                                  barWidth:
                                      3, // determine the thiknessof the line chart
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: _bottomTitleWidgets,
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) =>
                                        Text('${value.toInt()}%'),
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(),
                                topTitles: AxisTitles(),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false, // Hides vertical lines
                                drawHorizontalLine:
                                    true, // Shows horizontal lines
                                horizontalInterval:
                                    20, // Optional: sets spacing between horizontal lines
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 3,
                                ),
                              ),
                              borderData: FlBorderData(
                                  show:
                                      false), // show the border of the line chart

                              minY: 0,
                              maxY: 100,
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              barGroups: _getBarGroups(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: _bottomTitleWidgets,
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) =>
                                        Text('${value.toInt()}%'),
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(),
                                topTitles: AxisTitles(),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false, // Hides vertical lines
                                drawHorizontalLine:
                                    true, // Shows horizontal lines
                                horizontalInterval:
                                    20, // Optional: sets spacing between horizontal lines
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 3,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                              maxY: 100,
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // TASKS COMPLETED CHART
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tasks Completed",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                            color: const Color(0xFF2853AF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            taskCompletedChartType == "line"
                                ? Icons.bar_chart
                                : Icons.show_chart,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
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
                                  isCurved: false,
                                  color: Colors.indigo,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.indigo.withOpacity(0.1),
                                  ),
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: _bottomTitleWidgets,
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) =>
                                        Text('${value.toInt()}'),
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(),
                                topTitles: AxisTitles(),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false, // Hides vertical lines
                                drawHorizontalLine:
                                    true, // Shows horizontal lines
                                horizontalInterval:
                                    2, // Optional: sets spacing between horizontal lines
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 3,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              barGroups: _getTaskBarGroups(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: _bottomTitleWidgets,
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) =>
                                        Text('${value.toInt()}'),
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(),
                                topTitles: AxisTitles(),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false, // Hides vertical lines
                                drawHorizontalLine:
                                    true, // Shows horizontal lines
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 5,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
