// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api_services/leaderboard_service.dart';
import 'package:frontend/api_services/profile_service.dart';
import 'package:frontend/theme.dart';
import 'package:intl/intl.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  String period = 'all_time';
  final _leaderboardService = LeaderboardService();
  final _profileService = ProfileService();
  List<dynamic> topUsers = [];
  Map<String, dynamic>? currentUserData;
  String? currentUserId;
  bool isLoading = true;
  late AnimationController _animationController;

  final _periodKeys = ['all_time', 'weekly', 'monthly'];
  final _periodLabels = ['All time', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadCurrentUserId();
    _fetchLeaderboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final profile = await _profileService.getFullProfile();
      setState(() => currentUserId = profile['user_id'].toString());
    } catch (e) {
      debugPrint('Error loading user ID: $e');
    }
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() => isLoading = true);
    try {
      final data = await _leaderboardService.getLeaderboard(period);
      setState(() {
        topUsers = data['top_100'] ?? [];
        currentUserData = data['current_user'];
        isLoading = false;
        _animationController.forward(from: 0);
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load leaderboard: $e')),
      );
    }
  }

  ImageProvider _getImageProvider(String? url) {
    if (url == null || url.isEmpty) return const AssetImage('assets/default_avatar.png');
    final uri = Uri.parse(url);
    if (!kIsWeb && uri.scheme == 'file') return FileImage(File(uri.toFilePath()));
    if (uri.scheme.startsWith('http')) return NetworkImage(url);
    return const AssetImage('assets/default_avatar.png');
  }

  Widget _buildPeriodToggle() {
    return Center(
      child: Container(
        width: 260,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 0.5),
          color: Colors.white,
        ),
        child: Row(
          children: List.generate(_periodKeys.length, (index) {
            final isSelected = period == _periodKeys[index];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    setState(() => period = _periodKeys[index]);
                    _fetchLeaderboardData();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _periodLabels[index],
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppColors.blackText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopUser(Map<String, dynamic> user, int rank) {
    final isFirst = rank == 1;
    final avatarRadius = isFirst ? 36.0 : 28.0;
    final fontSize = isFirst ? 16.0 : 14.0;
    final rankCircleSize = isFirst ? 24.0 : 20.0;
    final gradient = rank == 1
        ? const LinearGradient(colors: [Color(0xFF2853AF), Color(0xB32853AF)])
        : rank == 2
            ? const LinearGradient(colors: [Color(0xFF2853AF), Color(0xFF0AB0D6)])
            : const LinearGradient(colors: [Color(0xFF0AB0D6), Color(0xB32853AF)]);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Interval(rank * 0.1, 1.0, curve: Curves.easeOut),
      ),
      child: Container(
        margin: EdgeInsets.only(top: isFirst ? 0 : 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(12, avatarRadius + 16, 12, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: _getImageProvider(user['profile_pic_url']),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user['full_name']?.toString() ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user['completion_rate']?.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -(rankCircleSize / 2),
              child: CircleAvatar(
                radius: rankCircleSize,
                backgroundColor: Colors.white,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreeUsers(List top3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (top3.length > 1)
          Expanded(flex: 3, child: _buildTopUser(top3[1], 2)),
        if (top3.isNotEmpty)
          Expanded(flex: 4, child: _buildTopUser(top3[0], 1)),
        if (top3.length > 2)
          Expanded(flex: 3, child: _buildTopUser(top3[2], 3)),
      ],
    );
  }

  Widget _buildUserTile(
    Map<String, dynamic> user, {
    bool isCurrentUser = false,
    bool isOutOfTop100 = false,
  }) {
    final bgColor = isOutOfTop100
        ? Colors.amber[100]
        : (isCurrentUser ? const Color(0xFF2853AF) : const Color(0xFFE8EFFF));
    final textColor = isOutOfTop100 ? Colors.black : (isCurrentUser ? Colors.white :Colors.black);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Text(
            '${user['rank']}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: _getImageProvider(user['profile_pic_url']),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user['user_id'].toString() == currentUserId ? 'You' : user['full_name'] ??'Unknown',
              style: TextStyle(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${NumberFormat('#,##0.0').format(user['completion_rate'])}%',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top3Users = topUsers.take(3).toList();
    final otherUsers = topUsers.skip(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Board', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchLeaderboardData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPeriodToggle(),
                  const SizedBox(height: 20),
                  _buildTopThreeUsers(top3Users),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: otherUsers.length + (currentUserData != null ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx < otherUsers.length) {
                          return _buildUserTile(
                            otherUsers[idx],
                            isCurrentUser: otherUsers[idx]['user_id'].toString() == currentUserId,
                          );
                        }
                        return _buildUserTile(
                          currentUserData!,
                          isCurrentUser: true,
                          isOutOfTop100: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
