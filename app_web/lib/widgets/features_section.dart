import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.favorite_border,
      'title': 'Smart Matching',
      'description': 'Our AI-powered algorithm finds your perfect match based on interests, values, and lifestyle.',
      'color': Color(0xFFFFF0F7),
      'iconColor': Color(0xFFFF4D94),
    },
    {
      'icon': Icons.verified_user,
      'title': 'Verified Profiles',
      'description': 'All members are verified through our multi-step verification process for your safety.',
      'color': Color(0xFFF0F7FF),
      'iconColor': Color(0xFF4D94FF),
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Privacy First',
      'description': 'Your privacy matters. Control what you share and who can see your profile.',
      'color': Color(0xFFF3F0FF),
      'iconColor': Color(0xFF884DFF),
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Meaningful Connections',
      'description': 'Start conversations that matter with ice-breakers and guided chat topics.',
      'color': Color(0xFFF0FFF4),
      'iconColor': Color(0xFF4DFF88),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            'Why Choose Us',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.purple[900],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Experience the difference with our unique features',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 80),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: features.map((feature) => _buildFeatureCard(
              icon: feature['icon'],
              title: feature['title'],
              description: feature['description'],
              color: feature['color'],
              iconColor: feature['iconColor'],
            )).toList(),
          ),
          SizedBox(height: 60),
          _buildStatisticsBar(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 280,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[900]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('2M+', 'Active Users'),
          _buildDivider(),
          _buildStatItem('150K+', 'Successful Matches'),
          _buildDivider(),
          _buildStatItem('95%', 'Satisfaction Rate'),
          _buildDivider(),
          _buildStatItem('24/7', 'Support'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
