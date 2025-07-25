import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/profile_screen/theme_provider.dart';
import 'package:frontend/theme.dart';
import 'package:provider/provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: StandardAppBar(appBarTitle: 'App Appearance',showBackButton: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 20),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text("Dark Mode"),
                tileColor: AppColors.secondary,
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.dark_mode),
              ),
          ],
        ),
      ),
    );
  }
}