import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'friends_Page.dart';
import 'select_Friend_Page.dart';

const String baseUrl = 'http://<your_ip>:8000'; // Replace with your IP

Future<List<dynamic>> fetchChat(String sender, String receiver) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/chat/?sender=$sender&receiver=$receiver'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load chat');
  }
}

class ChatPage extends StatefulWidget {
  final String? currentUser;
  final String? receiver;

  const ChatPage({super.key, required this.currentUser, this.receiver});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (widget.currentUser == null || widget.receiver == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final data = await fetchChat(widget.currentUser!, widget.receiver!);
      setState(() {
        messages = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsPage()),
              );
            },
          ),
        ],
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        messages.isEmpty
                            ? const Center(child: Text('No messages yet'))
                            : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (_, index) {
                                final msg = messages[index];
                                final isMe =
                                    widget.currentUser != null &&
                                    msg['sender_username'] ==
                                        widget.currentUser;

                                return Align(
                                  alignment:
                                      isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isMe
                                              ? Colors.blue[200]
                                              : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(msg['message'] ?? ''),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color.fromRGBO(40, 83, 175, 1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectFriendPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
