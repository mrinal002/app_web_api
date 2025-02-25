import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2024 Your Company',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Privacy Policy'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
              SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: Text('Terms of Service'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
