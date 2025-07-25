// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/api_services/friend_chat_service.dart';
import 'package:frontend/profile_screen/chat_screen.dart';

class SelectFriendScreen extends StatefulWidget {
  const SelectFriendScreen({super.key});

  @override
  State<SelectFriendScreen> createState() => _SelectFriendScreenState();
}

class _SelectFriendScreenState extends State<SelectFriendScreen> {
  List<dynamic> friends = [];
  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndFriends();
  }

  Future<void> _loadCurrentUserAndFriends() async {
    try {
      final id = await FriendChatService.getCurrentUserId();
      if (id == null) throw Exception('User ID not found, please login again');
      final result = await FriendChatService.getFriends();

      setState(() {
        currentUserId = id;
        friends = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  void _showSearchPopup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Search by Email or Phone"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter email or phone"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final user = await FriendChatService.searchUser(controller.text);
                _showFriendResultPopup(user);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _showFriendResultPopup(Map user) {
    final String? imageUrl = user['profile_pic'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Friend"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? Icon(Icons.person) : null,
            ),
            SizedBox(height: 10),
            Text(user['full_name']),
            Text(user['email'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await FriendChatService.addFriend(user['id'].toString());
                Navigator.pop(ctx);
                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User ID not found')));
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: _getRoomId(user['id']),
                      receiverId: user['id'],
                      receiverName: user['full_name'],
                      receiverProfilePic: user['profile_pic'],
                      currentUserId: currentUserId!,
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Add & Chat"),
          ),
        ],
      ),
    );
  }

  String _getRoomId(int receiverId) {
    if (currentUserId == null) return 'chat_0_0';
    final ids = [currentUserId!, receiverId]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Friend")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: friends.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return ListTile(
                    title: Text("Add Friend"),
                    leading: Icon(Icons.person_add),
                    onTap: _showSearchPopup,
                  );
                }
                final friend = friends[index - 1];
                final String? imageUrl = friend['profile_pic'];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? Icon(Icons.person) : null,
                  ),
                  title: Text(friend['name']),
                  onTap: () {
                    if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User ID not found')));
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatRoomId: _getRoomId(friend['id']),
                          receiverId: friend['id'],
                          receiverName: friend['name'],
                          receiverProfilePic: friend['profile_pic'],
                          currentUserId: currentUserId!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
