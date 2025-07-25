// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/ai_services.dart';
import './qustionire_screen.dart';
import '../components/cnav_bar.dart';
import '../components/custom_button.dart';


class BuildScreen extends StatefulWidget {
  final String habit;
  final String classification;

  const BuildScreen({
    required this.habit,
    required this.classification,
    super.key,
  });

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  List<String> _dynamicQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  Future<void> _generateQuestions() async {
    try {
      final questions = await AIService.generateDynamicQuestions(
        widget.habit,
        widget.classification,
      );
      print("Generated dynamic questions: $questions"); // Add this line

      setState(() {
        _dynamicQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load questions.")),
      );
    }
  }

  void _goToQuestionnaire() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen(
          habit: widget.habit,
          classification: widget.classification,
          dynamicQuestions: _dynamicQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: CustomAppBar(title: "Build Plan",
      onBackPressed: () => {
        Navigator.pop(context)
      },),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : CustomButton(
                buttonText: 'Build',
                onPressed: _goToQuestionnaire,
              ),
      ),
    );
  }
}
