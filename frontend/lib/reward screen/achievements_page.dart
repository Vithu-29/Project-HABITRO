import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  final List<Map<String, dynamic>> achievements = [
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": true
    },
    {
      "title": "7 Perfect Days",
      "image": "assets/images/home_img.png",
      "unlocked": true
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": true
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": false
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": false
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": false
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": false
    },
    {
      "title": "Quiz Master",
      "image": "assets/images/home_img.png",
      "unlocked": false
    },
  ];

  AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 4 : 3; // Responsive grid columns

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
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: achievements.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return AchievementCard(
              title: achievements[index]["title"],
              imageUrl: achievements[index]["image"],
              unlocked: achievements[index]["unlocked"],
            );
          },
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool unlocked;

  const AchievementCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.blue[100] : Colors.grey[500],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(imageUrl, width: 50, height: 50, fit: BoxFit.contain),
              if (!unlocked)
                SizedBox(
                  width: 50,
                  height: 50,
                  //color: Colors.black.withValues(red: 0,green:  0,blue:  0,alpha:  128), // 128 is equivalent to 50% opacity

                  child: const Icon(Icons.lock_open, color: Colors.white, size: 30),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
