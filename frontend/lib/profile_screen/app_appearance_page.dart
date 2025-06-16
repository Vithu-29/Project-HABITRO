import 'package:flutter/material.dart';

class AppAppearancePage extends StatefulWidget {
  const AppAppearancePage({super.key});

  @override
  State<AppAppearancePage> createState() => _AppAppearancePageState();
}

class _AppAppearancePageState extends State<AppAppearancePage> {
  String _selectedTheme = 'Light';
  String _selectedLanguage = 'English';
  String _selectedFontSize = 'Normal';

  void _showOptionsDialog(
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

  @override
  Widget build(BuildContext context) {
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
            value: _selectedTheme,
            onTap: () {
              _showOptionsDialog(
                'Theme',
                ['Light', 'Dark', 'System'],
                _selectedTheme,
                (val) => setState(() => _selectedTheme = val),
              );
            },
          ),
          _AppearanceSettingTile(
            icon: Icons.language,
            title: 'App Language',
            value: _selectedLanguage,
            onTap: () {
              _showOptionsDialog(
                'Language',
                ['English', 'Español', 'Français'],
                _selectedLanguage,
                (val) => setState(() => _selectedLanguage = val),
              );
            },
          ),
          _AppearanceSettingTile(
            icon: Icons.format_size,
            title: 'Font Size',
            value: _selectedFontSize,
            onTap: () {
              _showOptionsDialog(
                'Font Size',
                ['Small', 'Normal', 'Large'],
                _selectedFontSize,
                (val) => setState(() => _selectedFontSize = val),
              );
            },
          ),
        ],
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
        color: Color.fromRGBO(232, 239, 255, 1),
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
