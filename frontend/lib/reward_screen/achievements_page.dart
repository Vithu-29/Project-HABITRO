// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/api_services/achievement_service.dart';
import 'package:http/http.dart' as http;

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List achievements = [];

  @override
  void initState() {
    super.initState();
    _fetchAllAchievements();
  }

  Future<void> _fetchAllAchievements() async {
    try {
      final data = await AchievementService.fetchAll();
      setState(() => achievements = data);
    } catch (e) {
      debugPrint("Error fetching all achievements: $e");
    }
  }

  void _showClaimDialog(BuildContext context, dynamic achievement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Claim Reward"),
        content: const Text("You earned 500 coins and 1 gem!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await http.post(
                  Uri.parse(
                      '${AchievementService.baseUrl}/achievements/claim/${achievement["id"]}/'),
                );
                if (response.statusCode == 200) {
                  _fetchAllAchievements(); // Refresh the list
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text("Reward claimed successfully!")),
                  );
                }
              } catch (e) {
                debugPrint("Claim error: $e");
              }
              Navigator.pop(ctx);
            },
            child: const Text("Claim"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth * 0.2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: Text(
          "Achievements",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: achievements.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  var userAchievement = achievements[index];
                  final isClaimable = userAchievement['unlocked'] == true &&
                      userAchievement['is_collected'] == false;

                  return GestureDetector(
                    onTap: () {
                      if (isClaimable) {
                        _showClaimDialog(context, userAchievement);
                      }
                    },
                    child: Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: imageSize,
                                    height: imageSize,
                                    color: userAchievement['unlocked'] == false
                                        ? Colors.grey.shade300
                                        : null,
                                    child: userAchievement['unlocked'] == false
                                        ? const Icon(Icons.lock_outline,
                                            size: 40, color: Colors.black54)
                                        : Image.network(
                                            "${AchievementService.baseUrl}${userAchievement["image"]}",
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(
                                                    Icons.image_not_supported),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userAchievement['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        userAchievement['description'] ??
                                            'No description available.',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isClaimable)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
