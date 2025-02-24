import 'package:flutter/material.dart';
import '../api_service.dart';

class OnlineUsersPage extends StatefulWidget {
  const OnlineUsersPage({super.key});

  @override
  State<OnlineUsersPage> createState() => _OnlineUsersPageState();
}

class _OnlineUsersPageState extends State<OnlineUsersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _onlineUsers = [];

  @override
  void initState() {
    super.initState();
    _loadOnlineUsers();
  }

  Future<void> _loadOnlineUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiService.getOnlineUsers();
    
    setState(() {
      _isLoading = false;
      if (response.success) {
        _onlineUsers = response.data?['users'] ?? [];
      } else {
        _error = response.message;
      }
    });
  }

  void _startChat(dynamic user) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'userId': user['_id'], 'userName': user['name']},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOnlineUsers,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOnlineUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_onlineUsers.isEmpty) {
      return const Center(
        child: Text('No users are currently online'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOnlineUsers,
      child: ListView.builder(
        itemCount: _onlineUsers.length,
        itemBuilder: (context, index) {
          final user = _onlineUsers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user['name']?[0] ?? '?'),
            ),
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text(user['email'] ?? ''),
            trailing: ElevatedButton(
              onPressed: () => _startChat(user),
              child: const Text('Start Chat'),
            ),
          );
        },
      ),
    );
  }
}
