import 'package:flutter/material.dart';
import 'package:frontend/reward%20screen/achievements_page.dart';

class Achievements extends StatelessWidget {
  final List<Map<String, String>> achievements = [
    {"title": "7 Perfect Days", "image": "assets/images/home_img.png"},
    {"title": "Quiz Master", "image": "assets/images/home_img.png"},
    {"title": "Challenge Winner", "image": "assets/images/home_img.png"},
    {"title": "Daily Streak", "image": "assets/images/home_img.png"},
    {"title": "Daily Streak", "image": "assets/images/home_img.png"},
    {"title": "Daily Streak", "image": "assets/images/home_img.png"},
    {"title": "Daily Streak", "image": "assets/images/home_img.png"},
    {"title": "Daily Streak", "image": "assets/images/home_img.png"},
  ];

  Achievements({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => AchievementsPage())
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, // Fixed height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 25),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return AchievementCard(
                title: achievements[index]["title"]!,
                imageUrl: achievements[index]["image"]!,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const AchievementCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.2),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Image.asset(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFAFC1E7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
