import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class AppAppearancePage extends StatelessWidget {
  const AppAppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    String themeLabel(ThemePreference pref) {
      switch (pref) {
        case ThemePreference.light: return 'Light';
        case ThemePreference.dark: return 'Dark';
        case ThemePreference.system: return 'System';
      }
    }
    String fontLabel(FontSizePreference pref) {
      switch (pref) {
        case FontSizePreference.small: return 'Small';
        case FontSizePreference.medium: return 'Normal';
        case FontSizePreference.large: return 'Large';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'App Appearance',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AppearanceSettingTile(
            icon: Icons.color_lens,
            title: 'Theme',
            value: themeLabel(settings.themePref),
            onTap: () {
              _showOptionsDialog(
                context,
                'Theme',
                ThemePreference.values.map(themeLabel).toList(),
                themeLabel(settings.themePref),
                (String selected) {
                  final idx = ThemePreference.values.indexWhere((e) => themeLabel(e) == selected);
                  if (idx != -1) {
                    final newPref = ThemePreference.values[idx];
                    settings.updateTheme(newPref, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc5OTQxMTM5LCJpYXQiOjE3NDg0MDUxMzksImp0aSI6IjFjMzE5YTQyNWZmYjRjNTk4NmFiZjI0Zjg3NjQ3N2Y2IiwidXNlcl9pZCI6MX0.jXVGeAkPmh6SIR3gBfz9UzfrXP8_GPENbfF7-Aoxdag"); // <-- use your token here
                  }
                },
              );
            },
          ),
          
          _AppearanceSettingTile(
            icon: Icons.format_size,
            title: 'Font Size',
            value: fontLabel(settings.fontPref),
            onTap: () {
              _showOptionsDialog(
                context,
                'Font Size',
                FontSizePreference.values.map(fontLabel).toList(),
                fontLabel(settings.fontPref),
                (String selected) {
                  final idx = FontSizePreference.values.indexWhere((e) => fontLabel(e) == selected);
                  if (idx != -1) {
                    final newPref = FontSizePreference.values[idx];
                    settings.updateFontSize(newPref, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc5OTQxMTM5LCJpYXQiOjE3NDg0MDUxMzksImp0aSI6IjFjMzE5YTQyNWZmYjRjNTk4NmFiZjI0Zjg3NjQ3N2Y2IiwidXNlcl9pZCI6MX0.jXVGeAkPmh6SIR3gBfz9UzfrXP8_GPENbfF7-Aoxdag");
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    Function(String) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: current,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) onSelected(value);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AppearanceSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _AppearanceSettingTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: Colors.black54)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
