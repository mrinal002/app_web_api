import 'package:flutter/material.dart';
import 'image_slider.dart';

class BannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFDE7F9),
            Color(0xFFF4EEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🎉 #1 Dating App of 2024',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Find Your\nPerfect Match',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Join millions of people finding real connections\nthrough our intelligent matching system.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    _buildStatCard('2M+', 'Active Users', Icons.people),
                    SizedBox(width: 24),
                    _buildStatCard('1M+', 'Matches', Icons.favorite),
                    SizedBox(width: 24),
                    _buildStatCard('100K+', 'Success Stories', Icons.celebration),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Start Your Journey'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.play_circle_fill),
                      label: Text('How it works'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple[700],
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 80),
          ImageSlider(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[700], size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
