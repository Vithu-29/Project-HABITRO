import 'package:flutter/material.dart';

class LinkedAccountsPage extends StatelessWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final linkedAccounts = [
      {'icon': Icons.g_mobiledata, 'label': 'Google', 'linked': false},
      {'icon': Icons.apple, 'label': 'Apple', 'linked': true},
      {'icon': Icons.facebook, 'label': 'Facebook', 'linked': true},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Linked Accounts'),
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              linkedAccounts.map((item) {
                final bool isLinked = item['linked'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(item['icon'] as IconData),
                    title: Text(item['label'] as String),
                    trailing: Text(
                      isLinked ? 'Connected' : 'Connect',
                      style: TextStyle(
                        color:
                            isLinked
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                        fontWeight:
                            isLinked ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
