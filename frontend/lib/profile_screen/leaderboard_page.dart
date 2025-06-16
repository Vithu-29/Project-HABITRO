import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> leaderboardData = [];
  bool isLoading = true;
  String? errorMessage;
  String period = 'weekly'; // Default period
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserProfile();
  }

  Future<void> _fetchCurrentUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/profile/me/'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentUsername = data['username'] ?? '';
        });
        _fetchLeaderboard();
      } else {
        setState(() {
          errorMessage = 'Failed to load profile: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Profile Exception: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/leaderboard/?period=$period'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Add rank based on position
        for (int i = 0; i < data.length; i++) {
          data[i]['rank'] = i + 1;
        }
        setState(() {
          leaderboardData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load leaderboard: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Leaderboard Exception: $e';
        isLoading = false;
      });
    }
  }

  void _changePeriod(String newPeriod) {
    setState(() {
      period = {
        'Daily': 'daily',
        'Weekly': 'weekly',
        'Monthly': 'monthly',
        'All Time': 'all_time',
      }[newPeriod]!;
      isLoading = true;
    });
    _fetchLeaderboard();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    // Split data into top 3 and others
    final top3 = leaderboardData.length >= 3 
        ? leaderboardData.sublist(0, 3) 
        : leaderboardData;
    final otherUsers = leaderboardData.length > 3 
        ? leaderboardData.sublist(3) 
        : [];

    // Find current user entry
    Map<String, dynamic>? currentUserEntry;
    for (var user in leaderboardData) {
      if (user['username'] == currentUsername) {
        currentUserEntry = user;
        break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Leader Board',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildPeriodDropdown(),
                          const Spacer(),
                          _buildSortDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (top3.length >= 2) _buildTopUser(top3[1], 2),
                        if (top3.length >= 2) const SizedBox(width: 4),
                        if (top3.isNotEmpty) _buildTopUser(top3[0], 1, isCenter: true),
                        if (top3.length >= 3) const SizedBox(width: 4),
                        if (top3.length >= 3) _buildTopUser(top3[2], 3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: otherUsers.length + (currentUserEntry != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < otherUsers.length) {
                            final user = otherUsers[index];
                            return _buildUserTile(
                              user['rank'],
                              user['username'],
                              user['score'],
                              user['avatar'] ?? 'https://i.pravatar.cc/150',
                            );
                          } else {
                            return _buildUserTile(
                              currentUserEntry!['rank'],
                              "Me",
                              currentUserEntry['score'],
                              currentUserEntry['avatar'] ?? 'https://i.pravatar.cc/150',
                              isCurrentUser: true,
                            );
                          }
                        },
                      ),
                    ),
                    _buildPagination(),
                  ],
                ),
    );
  }

  Widget _buildPeriodDropdown() {
    final options = ['Daily', 'Weekly', 'Monthly', 'All Time'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButton<String>(
        value: period == 'daily' ? 'Daily' 
              : period == 'monthly' ? 'Monthly'
              : period == 'all_time' ? 'All Time'
              : 'Weekly',
        underline: const SizedBox(),
        items: options.map((String v) {
          return DropdownMenuItem(
            value: v,
            child: Text(v),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            _changePeriod(newValue);
          }
        },
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildSortDropdown() {
    final options = ['Success rate'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButton<String>(
        value: 'Success rate',
        underline: const SizedBox(),
        items: options.map((String v) {
          return DropdownMenuItem(
            value: v,
            child: Text(v),
          );
        }).toList(),
        onChanged: (_) {}, // Not implemented
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildTopUser(
    Map<String, dynamic> user,
    int rank, {
    bool isCenter = false,
  }) {
    Gradient backgroundGradient;

    if (rank == 1) {
      backgroundGradient = const LinearGradient(
        colors: [
          Color.fromRGBO(40, 83, 175, 1),
          Color.fromRGBO(40, 83, 175, 0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (rank == 2) {
      backgroundGradient = const LinearGradient(
        colors: [
          Color.fromRGBO(40, 83, 175, 1),
          Color.fromRGBO(10, 176, 214, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      backgroundGradient = const LinearGradient(
        colors: [
          Color.fromRGBO(10, 176, 214, 1),
          Color.fromRGBO(40, 83, 175, 0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: isCenter ? 110 : 80,
              width: 80,
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                gradient: backgroundGradient,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    user['avatar'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['username'] ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user['score']}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            Positioned(
              top: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Text('$rank', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTile(
    int rank,
    String name,
    int score,
    String image, {
    bool isCurrentUser = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color.fromRGBO(40, 83, 175, 1)
            : const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: NetworkImage(image),
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageButton('1', isSelected: true),
          _pageButton('2'),
          _pageButton('3'),
          const Text('...'),
          _pageButton('20'),
          _pageButton('>>'),
        ],
      ),
    );
  }

  Widget _pageButton(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromRGBO(40, 83, 175, 1)
            : const Color.fromRGBO(217, 217, 217, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}