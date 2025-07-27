// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/api_services/friend_chat_service.dart';
import 'package:frontend/theme.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final int receiverId;
  final String receiverName;
  final String? receiverProfilePic;
  final int currentUserId;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfilePic,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  late AnimationController _fabAnimationController;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeChat();

    _scrollController.addListener(() {
      final showFab = _scrollController.offset > 100;
      if (showFab != _showScrollToBottom) {
        setState(() => _showScrollToBottom = showFab);
        if (showFab) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      }
    });
  }

  Future<void> _initializeChat() async {
    final baseUrl = dotenv.get('BASE_URL').replaceFirst('http', 'ws');
    channel = WebSocketChannel.connect(
      Uri.parse('$baseUrl/ws/chat/${widget.chatRoomId}/'),
    );

    try {
      final pastMessages = await FriendChatService.fetchMessages(
          widget.chatRoomId.replaceFirst('chat_', ''));
      setState(() {
        messages = pastMessages;
        _isLoading = false;
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: false);
      });
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      setState(() => _isLoading = false);
    }

    channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      setState(() {
        messages.add({
          'message': decoded['message'],
          'sender_id': decoded['sender_id'],
          'receiver_id': decoded['receiver_id'],
          'timestamp': decoded['timestamp'],
          'message_id': decoded['message_id'] ?? decoded['id'], // Handle both
          'is_read': decoded['is_read'] ?? false,
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isTyping = true);

    final message = {
      'message': _controller.text.trim(),
      'sender_id': widget.currentUserId,
      'receiver_id': widget.receiverId,
    };
    channel.sink.add(jsonEncode(message));
    _controller.clear();

    setState(() => _isTyping = false);
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now().toLocal();
    final localTime = time.toLocal();

    if (localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day) {
      return DateFormat('HH:mm').format(localTime);
    } else {
      return DateFormat('dd/MM HH:mm').format(localTime);
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now().toLocal();
    final localDate = date.toLocal();

    if (localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day) {
      return 'Today';
    } else if (localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(localDate);
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;

    final currentMsg = messages[index];
    final previousMsg = messages[index - 1];

    try {
      final currentDate = DateTime.parse(currentMsg['timestamp']).toLocal();
      final previousDate = DateTime.parse(previousMsg['timestamp']).toLocal();

      return currentDate.day != previousDate.day ||
          currentDate.month != previousDate.month ||
          currentDate.year != previousDate.year;
    } catch (_) {
      return false;
    }
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(date),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, int index) {
    final isMe = msg['sender_id'] == widget.currentUserId;
    final timestamp = msg['timestamp']?.toString();

    String formattedTime = '';
    if (timestamp != null) {
      try {
        final dt = DateTime.parse(timestamp);
        formattedTime = _formatMessageTime(dt);
      } catch (_) {
        formattedTime = timestamp;
      }
    }

    return Dismissible(
      key: Key('${msg['message_id'] ?? index}'),
      direction:
          isMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
      background: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: isMe ? 0 : 20,
          right: isMe ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red[400],
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Delete Message'),
                content:
                    const Text('Are you sure you want to delete this message?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        try {
          await FriendChatService.deleteMessage(msg['message_id'] ?? msg['id']);
          setState(() {
            messages.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          debugPrint('Error deleting message: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight:
                    isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg['message'] ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: msg['is_read'] == true
                            ? const Color(0xFF4FC3F7)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = (widget.receiverProfilePic != null &&
            widget.receiverProfilePic!.startsWith('/media/'))
        ? '${dotenv.get('BASE_URL')}${widget.receiverProfilePic}'
        : widget.receiverProfilePic;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.receiverName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF128C7E)),
                    ),
                  )
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Send a message to start the conversation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];

                          if (msg['message'] == null ||
                              msg['message'].toString().trim().isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final widgets = <Widget>[];

                          // Add date header if needed
                          if (_shouldShowDateHeader(index)) {
                            try {
                              final date =
                                  DateTime.parse(msg['timestamp']).toLocal();
                              widgets.add(_buildDateHeader(date));
                            } catch (_) {}
                          }

                          widgets.add(_buildMessageBubble(msg, index));

                          return Column(children: widgets);
                        },
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF128C7E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isTyping
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isTyping ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
