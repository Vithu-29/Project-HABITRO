import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Menu",
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.message_outlined,color: Colors.black,))
        ],
        )
    );
  }
}