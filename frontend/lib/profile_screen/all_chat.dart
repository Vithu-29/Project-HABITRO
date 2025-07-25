// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/api_services/friend_chat_service.dart';
import 'package:frontend/components/chat_shimmer_item.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/profile_screen/chat_screen.dart';
import 'package:frontend/profile_screen/select_friend.dart';
import 'package:frontend/theme.dart';
import 'package:intl/intl.dart';

class AllChat extends StatefulWidget {
  const AllChat({super.key});

  @override
  AllChatState createState() => AllChatState();
}

class AllChatState extends State<AllChat> {
  bool _isLoading = true;
  List<Map<String, dynamic>> friends = [];
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    // 1️⃣ Bail out entirely if this State is defunct.
    if (!mounted) return;

    try {
      currentUserId = await FriendChatService.getCurrentUserId();
      final data = await FriendChatService.getFriends();

      // 2️⃣ Always check mounted *before* calling setState
      if (mounted) {
        setState(() {
          friends = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading chats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  String _buildSubtitle(Map<String, dynamic> chat) {
    final lastMsg = chat['last_message']?.toString().trim();
    final lastSenderId = chat['last_sender_id'];
    if (lastMsg == null || lastMsg.isEmpty) return "Tap to start chatting";

    final prefix = lastSenderId == currentUserId ? "You: " : "";
    final maxLength = 35;
    final truncatedMsg = lastMsg.length > maxLength
        ? "${lastMsg.substring(0, maxLength)}..."
        : lastMsg;

    return "$prefix$truncatedMsg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: StandardAppBar(
        appBarTitle: "Chats",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _loadChats,
          ),
        ],
      ),
      body: _isLoading
          ? ListView.separated(
              itemCount: 8,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, __) => const ChatShimmerItem(),
            )
          : friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No chats yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start a conversation with your friends",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final chat = friends[index];
                    final profilePic = chat['profile_pic']?.toString();
                    final imageUrl =
                        profilePic != null && profilePic.startsWith('/media/')
                            ? "${dotenv.get('BASE_URL')}$profilePic"
                            : profilePic;

                    DateTime? msgTime;
                    try {
                      if (chat['timestamp'] != null) {
                        msgTime = DateTime.parse(chat['timestamp']).toLocal();
                      }
                    } catch (_) {
                      msgTime = null;
                    }

                    final unreadCount = chat['unread_count'] ?? 0;
                    final hasUnread = unreadCount > 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey[600],
                                      size: 28,
                                    )
                                  : null,
                            ),
                            if (hasUnread)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF25D366),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          chat['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _buildSubtitle(chat),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  hasUnread ? Colors.black87 : Colors.grey[600],
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (msgTime != null)
                              Text(
                                _formatTime(msgTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasUnread
                                      ? const Color(0xFF25D366)
                                      : Colors.grey[500],
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () async {
                          final roomRes =
                              await FriendChatService.getOrCreateRoom(
                                  chat['id'].toString());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatRoomId: 'chat_${roomRes['room_id']}',
                                receiverId: chat['id'],
                                receiverName: chat['name'],
                                receiverProfilePic: chat['profile_pic'],
                                currentUserId: currentUserId!,
                              ),
                            ),
                          ).then((_) {
                            // 3️⃣ Only reload if not disposed
                            if (mounted) _loadChats();
                          }); // Refresh when returning
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SelectFriendScreen()),
            ).then((_) => _loadChats());
          },
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(
            Icons.chat_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
