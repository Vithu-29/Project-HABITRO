import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Explore",
        )
    );
  }
}