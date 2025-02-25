import 'package:flutter/material.dart';
import 'widgets/nav_bar.dart';
import 'widgets/banner_section.dart';
import 'widgets/features_section.dart';
import 'widgets/how_it_works_section.dart';
import 'widgets/testimonials_section.dart';
import 'widgets/footer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Column(
              children: [
                NavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BannerSection(),
                        HowItWorksSection(),
                        FeaturesSection(),
                        TestimonialsSection(),
                        _buildCallToAction(),
                        Footer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple[700]!, Colors.purple[900]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Find Love Today',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Join millions of people finding real connections every day',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildMobileButtons(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[900]!],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Find Your Perfect Match?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: Text('Get Started Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple[900],
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text('Login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[900],
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: Text('Register'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white),
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
