import 'package:flutter/material.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/profile_screen/theme_provider.dart'; // This has FontSizeOption
import 'package:frontend/theme.dart';
import 'package:provider/provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: StandardAppBar(appBarTitle: 'App Appearance', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            // Dark Mode Switch
            SwitchListTile(
              title: const Text("Dark Mode"),
              tileColor: AppColors.secondary,
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
              secondary: const Icon(Icons.dark_mode),
            ),
            const SizedBox(height: 30),

            // Font Size Dropdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Font Size", style: TextStyle(fontSize: 16)),
                  DropdownButton<FontSizeOption>(
                    value: themeProvider.fontSize,
                    underline: const SizedBox(), // remove underline
                    dropdownColor: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    onChanged: (FontSizeOption? newValue) {
                      if (newValue != null) {
                        themeProvider.setFontSize(newValue);
                      }
                    },
                    items: FontSizeOption.values.map((FontSizeOption option) {
                      return DropdownMenuItem<FontSizeOption>(
                        value: option,
                        child: Text(option.label),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
