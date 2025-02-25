import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  final List<Map<String, dynamic>> steps = [
    {
      'icon': Icons.person_add,
      'title': 'Create Profile',
      'description': 'Sign up and create your detailed profile in minutes',
    },
    {
      'icon': Icons.favorite,
      'title': 'Find Matches',
      'description': 'Browse profiles and find people who share your interests',
    },
    {
      'icon': Icons.chat,
      'title': 'Start Chatting',
      'description': 'Connect with your matches and start meaningful conversations',
    },
    {
      'icon': Icons.celebration,
      'title': 'Meet in Person',
      'description': 'Take your connection to the real world',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.purple[900],
            ),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: steps
                .map((step) => _buildStep(
                      step['icon'],
                      step['title'],
                      step['description'],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String description) {
    return Container(
      width: 200,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.purple[700]),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
