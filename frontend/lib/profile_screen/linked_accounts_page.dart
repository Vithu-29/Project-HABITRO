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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Linked Accounts',
          style: TextStyle(color: Colors.black),
        ),
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
                    color: const Color.fromRGBO(232, 239, 255, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
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
                                ? const Color.fromRGBO(40, 83, 175, 1)
                                : const Color.fromRGBO(0, 0, 238, 1),
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
