import 'package:flutter/material.dart';
import 'dart:async'; // Add this import
import '../api_service.dart';
import '../models/chat_message.dart';

class ChatPage extends StatefulWidget {
  final String? userId;
  final String? userName;

  const ChatPage({Key? key, this.userId, this.userName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> recentChats = [];
  List<dynamic> messages = [];
  String? selectedConversationId;
  Map<String, dynamic>? userData;  // Add this line
  Timer? _messageTimer;
  int _pollInterval = 3; // seconds

  @override
  void initState() {
    super.initState();
    _loadUserData();  // Add this line
    if (widget.userId != null) {
      _startDirectChat();
    } else {
      _loadRecentChats();
    }
    // Start message polling
    _startMessagePolling();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {  // Add this method
    final response = await _apiService.getProfile();
    if (response.success && mounted) {
      setState(() {
        userData = response.data;
      });
    }
  }

  Future<void> _loadRecentChats() async {
    final response = await _apiService.getRecentChats();
    if (response.success && mounted) {
      setState(() {
        recentChats = response.data?['chats'] ?? [];
      });
    }
  }

  Future<void> _loadChatHistory(String conversationId) async {
    try {
      final response = await _apiService.getChatHistory(conversationId);
      if (response.success && mounted) {
        setState(() {
          messages = response.data?['messages'] ?? [];
          selectedConversationId = conversationId;
        });
        // Reset polling when loading new chat
        _startMessagePolling();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      print('Error loading chat history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history')),
      );
    }
  }

  Future<void> _sendMessage(String receiverId) async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final message = _messageController.text;
      _messageController.clear();

      // Show sending indicator
      final tempMessage = {
        'message': message,
        'senderId': userData?['_id'],
        'timestamp': DateTime.now().toIso8601String(),
        'sending': true,
      };

      setState(() {
        messages.insert(0, tempMessage);
      });

      final response = await _apiService.sendMessage(receiverId, message);
      
      if (response.success && response.data?['message'] != null) {
        // Get conversation ID from the response
        final newMessage = response.data!['message'];
        final conversationId = newMessage['conversation'];
        
        if (selectedConversationId == null) {
          selectedConversationId = conversationId;
        }
        
        // Remove temp message and load new messages
        setState(() {
          messages.removeWhere((m) => m['sending'] == true);
        });
        
        await _loadChatHistory(conversationId);
      } else {
        // Show error and remove temporary message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        setState(() {
          messages.removeWhere((m) => m['sending'] == true);
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
      setState(() {
        messages.removeWhere((m) => m['sending'] == true);
      });
    }
  }

  Future<void> _startDirectChat() async {
    if (widget.userId == null) return;
    
    try {
      // First check for existing conversation
      final checkResponse = await _apiService.checkExistingConversation(widget.userId!);
      
      if (checkResponse.success && checkResponse.data != null) {
        final existingConversationId = checkResponse.data?['conversationId'];
        
        if (existingConversationId != null) {
          await _loadChatHistory(existingConversationId);
          return;
        }
      }

      // If no existing conversation, wait for first message to create one
      setState(() {
        messages = [];
        selectedConversationId = null;
      });
      
    } catch (e) {
      print('Error starting chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat')),
      );
    }
  }

  void _startMessagePolling() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(Duration(seconds: _pollInterval), (timer) {
      if (selectedConversationId != null) {
        _refreshMessages();
      }
    });
  }

  Future<void> _refreshMessages() async {
    if (!mounted || selectedConversationId == null) return;

    try {
      final response = await _apiService.getChatHistory(selectedConversationId!);
      if (response.success && mounted) {
        final newMessages = response.data?['messages'] ?? [];
        if (newMessages.length != messages.length) {
          setState(() {
            messages = newMessages;
          });
        }
      }
    } catch (e) {
      print('Error refreshing messages: $e');
    }
  }

  Widget _buildMessageBubble(dynamic message) {
    if (message == null) return SizedBox.shrink();
    
    // Check if the message is from the current user
    final isMe = message['sender']?['_id'] == userData?['_id'];
    final isSending = message['sending'] == true;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isSending ? Colors.grey[100] : (isMe ? Colors.blue[100] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(20),
            bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              Text(
                message['sender']?['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
            ],
            Text(
              message['message'] ?? '',
              style: TextStyle(fontSize: 16),
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSending ? 'Sending...' : _formatTime(message['createdAt']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (isSending) ...[
                  SizedBox(width: 4),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? 'Chat'),
      ),
      body: widget.userId != null
        ? _buildDirectChatBody()
        : _buildFullChatBody(),
    );
  }

  Widget _buildDirectChatBody() {
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(child: Text('No messages yet'))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () => widget.userId != null 
                  ? _sendMessage(widget.userId!)
                  : null,
                child: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullChatBody() {
    return Row(
      children: [
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Recent Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recentChats.length,
                  itemBuilder: (context, index) {
                    final chat = recentChats[index];
                    return ListTile(
                      selected: selectedConversationId == chat['conversationId'],
                      title: Text(chat['name'] ?? 'Unknown'),
                      subtitle: Text(
                        chat['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _loadChatHistory(chat['conversationId']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedConversationId == null
              ? Center(child: Text('Select a conversation to start chatting'))
              : _buildDirectChatBody(),
        ),
      ],
    );
  }
}
