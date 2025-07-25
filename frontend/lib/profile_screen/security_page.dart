import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(appBarTitle: 'Account & Security',showBackButton: true,),
    );
  }
}