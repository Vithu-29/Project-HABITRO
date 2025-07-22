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
  List<dynamic> top3Users = [];
  bool isLoading = true;
  String? errorMessage;
  String period = 'weekly';
  String currentUsername = '';
  int currentPage = 1;
  int totalPages = 20;
  Map<String, dynamic>? currentUserGlobal;

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
        await _fetchCurrentUserRank();
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

  Future<void> _fetchCurrentUserRank() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/leaderboard/around_me/?period=$period',
        ),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final entry = data['entries'].firstWhere(
          (u) => u['username'] == currentUsername,
          orElse: () => null,
        );

        if (entry != null) {
          setState(() {
            currentUserGlobal = entry;
          });
        }
      }
    } catch (e) {
      print("Error fetching current user rank: $e");
    }
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (top3Users.isEmpty) {
        final top3Response = await http.get(
          Uri.parse(
            'http://127.0.0.1:8000/api/leaderboard/?period=$period&page=1',
          ),
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        );
        if (top3Response.statusCode == 200) {
          final data = json.decode(top3Response.body);
          setState(() {
            top3Users = data.length >= 3 ? data.sublist(0, 3) : data;
          });
        }
      }

      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/leaderboard/?period=$period&page=$currentPage',
        ),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (response.statusCode == 200) {
        final pageData = json.decode(response.body);
        setState(() {
          leaderboardData = pageData;
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
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _changePeriod(String newPeriod) {
    setState(() {
      period =
          {
            'Daily': 'daily',
            'Weekly': 'weekly',
            'Monthly': 'monthly',
            'All Time': 'all_time',
          }[newPeriod]!;

      currentPage = 1;
      top3Users.clear();
    });
    _fetchCurrentUserRank();
    _fetchLeaderboard();
  }

  void _changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
      _fetchLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUsers =
        leaderboardData
            .where(
              (user) =>
                  !top3Users.any((top) => top['username'] == user['username']),
            )
            .toList();

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
            onPressed: _fetchLeaderboard,
          ),
        ],
      ),
      body:
          isLoading
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
                      if (top3Users.length >= 2) _buildTopUser(top3Users[1], 2),
                      if (top3Users.length >= 2) const SizedBox(width: 4),
                      if (top3Users.isNotEmpty)
                        _buildTopUser(top3Users[0], 1, isCenter: true),
                      if (top3Users.length >= 3) const SizedBox(width: 4),
                      if (top3Users.length >= 3) _buildTopUser(top3Users[2], 3),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: otherUsers.length,
                      itemBuilder: (context, index) {
                        final user = otherUsers[index];
                        return _buildUserTile(
                          user['rank'],
                          user['username'],
                          user['score'],
                          user['avatar'] ?? 'https://i.pravatar.cc/150',
                          isCurrentUser: user['username'] == currentUsername,
                        );
                      },
                    ),
                  ),
                  if (currentUserGlobal != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2853AF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${currentUserGlobal!['rank']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              currentUserGlobal!['avatar'] ??
                                  'https://i.pravatar.cc/150',
                            ),
                            radius: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Me',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            '${currentUserGlobal!['score']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
      ),
      child: DropdownButton<String>(
        value:
            {
              'daily': 'Daily',
              'weekly': 'Weekly',
              'monthly': 'Monthly',
              'all_time': 'All Time',
            }[period],
        underline: const SizedBox(),
        items:
            options
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
        onChanged: (newValue) {
          if (newValue != null) _changePeriod(newValue);
        },
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 239, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: 'Success rate',
        underline: const SizedBox(),
        items:
            [
              'Success rate',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (_) {},
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildTopUser(
    Map<String, dynamic> user,
    int rank, {
    bool isCenter = false,
  }) {
    Gradient gradient =
        rank == 1
            ? const LinearGradient(
              colors: [Color(0xFF2853AF), Color(0xB32853AF)],
            )
            : rank == 2
            ? const LinearGradient(
              colors: [Color(0xFF2853AF), Color(0xFF0AB0D6)],
            )
            : const LinearGradient(
              colors: [Color(0xFF0AB0D6), Color(0xB32853AF)],
            );

    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: isCenter ? 110 : 80,
              width: 80,
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                gradient: gradient,
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
        color:
            isCurrentUser ? const Color(0xFF2853AF) : const Color(0xFFE8EFFF),
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
          CircleAvatar(backgroundImage: NetworkImage(image), radius: 16),
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
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentPage > 1 ? () => _changePage(currentPage - 1) : null,
          ),
          for (int i = 1; i <= totalPages; i++)
            if (i == 1 ||
                i == totalPages ||
                (i >= currentPage - 2 && i <= currentPage + 2))
              _pageButton(i.toString(), isSelected: i == currentPage),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                currentPage < totalPages
                    ? () => _changePage(currentPage + 1)
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _pageButton(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _changePage(int.parse(label)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2853AF) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
