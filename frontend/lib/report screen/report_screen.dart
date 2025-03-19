import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Report",
        )
    );
  }
}