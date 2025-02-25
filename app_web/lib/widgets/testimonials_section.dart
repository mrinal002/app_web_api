import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  final List<Map<String, dynamic>> testimonials = [
    {
      'names': 'Sarah & Mike',
      'images': ['assets/images/sarah.jpg', 'assets/images/mike.jpg'],
      'age': '28 & 30',
      'duration': '2 years together',
      'status': '💑 Recently Married',
      'location': 'New York, USA',
      'story': 'We found true love here! The matching algorithm really works.',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
      'interests': ['Travel', 'Music', 'Cooking'],
    },
    {
      'names': 'Emma & James',
      'images': ['assets/images/emma.jpg', 'assets/images/james.jpg'],
      'age': '26 & 29',
      'duration': '1 year together',
      'status': '💍 Engaged',
      'location': 'London, UK',
      'story': 'From the first message to our engagement, everything was perfect!',
      'gradient': [Color(0xFF6B8AFF), Color(0xFF8EA8FF)],
      'interests': ['Movies', 'Sports', 'Reading'],
    },
    {
      'names': 'David & Lisa',
      'images': ['assets/images/david.jpg', 'assets/images/lisa.jpg'],
      'age': '32 & 30',
      'duration': '18 months together',
      'status': '❤️ In Love',
      'location': 'Toronto, Canada',
      'story': 'The personality matching feature helped us find our perfect match.',
      'gradient': [Color(0xFFB06BFF), Color(0xFFC68EFF)],
      'interests': ['Hiking', 'Photography', 'Cooking'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 60),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
              ),
              itemCount: testimonials.length,
              itemBuilder: (context, index) => _buildTestimonialCard(testimonials[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(testimonial),
          Divider(height: 1),
          Expanded(child: _buildCardContent(testimonial)),
          Divider(height: 1),
          _buildCardFooter(testimonial),
        ],
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> testimonial) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (String image in testimonial['images'])
                Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: testimonial['gradient'][0].withOpacity(0.3),
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            testimonial['names'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 4),
          Text(
            testimonial['age'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: testimonial['gradient']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              testimonial['status'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> testimonial) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            testimonial['story'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (String interest in testimonial['interests'])
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(Map<String, dynamic> testimonial) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            testimonial['location'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.purple[700]!, Colors.purple[900]!],
          ).createShader(bounds),
          child: Text(
            'Success Stories',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Real People, Real Connections',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
