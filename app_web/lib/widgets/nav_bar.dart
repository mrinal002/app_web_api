import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.purple[700], size: 32),
              SizedBox(width: 8),
              Text(
                'DatingApp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                ),
              ),
            ],
          ),
          SizedBox(width: 60),
          _buildNavItem('Home', true),
          _buildNavItem('Browse', false),
          _buildNavItem('Success Stories', false),
          _buildNavItem('About Us', false),
          Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Login'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple[700],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text('Get Started'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.purple[700] : Colors.grey[700],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
