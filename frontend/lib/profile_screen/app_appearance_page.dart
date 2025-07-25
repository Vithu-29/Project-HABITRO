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
        case ThemePreference.light:
          return 'Light';
        case ThemePreference.dark:
          return 'Dark';
        case ThemePreference.system:
          return 'System';
      }
    }

    String fontLabel(FontSizePreference pref) {
      switch (pref) {
        case FontSizePreference.small:
          return 'Small';
        case FontSizePreference.medium:
          return 'Normal';
        case FontSizePreference.large:
          return 'Large';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('App Appearance'),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                  final idx = ThemePreference.values.indexWhere(
                    (e) => themeLabel(e) == selected,
                  );
                  if (idx != -1) {
                    final newPref = ThemePreference.values[idx];
                    settings.updateTheme(newPref, "your-token-here");
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
                  final idx = FontSizePreference.values.indexWhere(
                    (e) => fontLabel(e) == selected,
                  );
                  if (idx != -1) {
                    final newPref = FontSizePreference.values[idx];
                    settings.updateFontSize(newPref, "your-token-here");
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
      builder:
          (_) => AlertDialog(
            title: Text('Select $title'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.map((option) {
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
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
