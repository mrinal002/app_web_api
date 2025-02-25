import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_email_service.dart';
import 'widgets/nav_bar.dart';
import 'widgets/footer.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool passwordsMatch = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  void validatePasswords() {
    setState(() {
      passwordsMatch = passwordController.text == confirmPasswordController.text;
    });
  }

  void register() async {
    if (!isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!passwordsMatch || confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var response = await apiService.register(
      emailController.text,
      nameController.text,
      dateOfBirthController.text,
      genderController.text,
      passwordController.text,
    );

    if (response.success) {
      UserEmailService.setEmail(emailController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: response.success ? Colors.green : Colors.red,
      ),
    );

    if (response.success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/mobile',
        (route) => false,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isPassword = false,
    String? errorText,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: emailController,
          label: "Email",
          hint: "example@email.com",
          errorText: emailController.text.isNotEmpty && !isValidEmail(emailController.text)
              ? 'Enter a valid email'
              : null,
        ),
        _buildTextField(
          controller: nameController,
          label: "Name",
          hint: "Fastname Lastname",
        ),
        _buildTextField(
          controller: dateOfBirthController,
          label: "Date of Birth",
          hint: "MM/DD/YYYY",
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                dateOfBirthController.text = "${pickedDate.month.toString().padLeft(2, '0')}/"
                    "${pickedDate.day.toString().padLeft(2, '0')}/"
                    "${pickedDate.year}";
              });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: genderController.text.isNotEmpty ? genderController.text : null,
            items: ["Male", "Female", "Other"].map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                genderController.text = value!;
              });
            },
            decoration: InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        _buildTextField(
          controller: passwordController,
          label: "Password",
          hint: "xxxxxxxxxx",
          isPassword: true,
        ),
        _buildTextField(
          controller: confirmPasswordController,
          label: "Confirm Password",
          hint: "xxxxxxxxxx",
          isPassword: true,
          errorText: !passwordsMatch && confirmPasswordController.text.isNotEmpty
              ? 'Passwords do not match'
              : null,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: register,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Register",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        NavBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple[700] ?? Colors.purple,
                            Colors.purple[900] ?? Colors.deepPurple,
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: BackgroundPatternPainter(),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        children: [
                          Text(
                            'Start Your Journey Today',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 24),
                          Container(
                            width: 600,
                            child: Text(
                              'Join millions of people who have found their perfect match through our platform. Create your account and start your journey to happiness.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 1200),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Card(
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProgressIndicator(),
                                    SizedBox(height: 32),
                                    Text(
                                      'Create Your Account',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[900],
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Fill in your details to get started',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    _buildForm(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 48),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildEnhancedFeatureCard(
                                  icon: Icons.verified_user,
                                  title: 'Verified Profiles',
                                  description: 'All profiles are manually verified by our team to ensure authenticity and safety.',
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 24),
                                _buildEnhancedFeatureCard(
                                  icon: Icons.security,
                                  title: 'Bank-Level Security',
                                  description: 'Your data is protected with enterprise-grade encryption and security measures.',
                                  color: Colors.green,
                                ),
                                SizedBox(height: 24),
                                _buildEnhancedFeatureCard(
                                  icon: Icons.favorite,
                                  title: 'Success Stories',
                                  description: 'Join over 10,000+ happy couples who found their perfect match with us.',
                                  color: Colors.red,
                                ),
                                SizedBox(height: 40),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(1, 'Account', true),
        _buildProgressLine(true),
        _buildProgressStep(2, 'Verify', false),
        _buildProgressLine(false),
        _buildProgressStep(3, 'Complete', false),
      ],
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.purple[700] : Colors.grey[200],
            border: Border.all(
              color: isActive ? Colors.purple[700]! : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.purple[700] : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? Colors.purple[700] : Colors.grey[300],
      ),
    );
  }

  Widget _buildEnhancedFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
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
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Container(
        color: Colors.purple[700],
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.purple[700]!,
                            Colors.purple[900]!,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Find your perfect match today',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: _buildMobileProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: _buildMobileForm(),
                      ),
                      _buildSocialLogin(),
                      Divider(height: 48),
                      _buildFeatureList(),
                      SizedBox(height: 24),
                      _buildLoginLink(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildMobileProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMobileProgressStep(1, 'Account', true),
            _buildMobileProgressStep(2, 'Verify', false),
            _buildMobileProgressStep(3, 'Complete', false),
          ],
        ),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMobileProgressStep(int step, String label, bool isActive) {
    return Container(
      width: 90,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.purple[700] : Colors.grey[200],
              boxShadow: isActive ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ] : null,
            ),
            child: Icon(
              _getStepIcon(step),
              color: isActive ? Colors.white : Colors.grey[400],
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.purple[700] : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.person_outline;
      case 2:
        return Icons.verified_user_outlined;
      case 3:
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24),
        _buildTextField(
          controller: emailController,
          label: "Email",
          hint: "example@email.com",
          errorText: emailController.text.isNotEmpty && !isValidEmail(emailController.text)
              ? 'Enter a valid email'
              : null,
        ),
        _buildTextField(
          controller: nameController,
          label: "Name",
          hint: "Fastname Lastname",
        ),
        _buildTextField(
          controller: dateOfBirthController,
          label: "Date of Birth",
          hint: "MM/DD/YYYY",
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                dateOfBirthController.text = "${pickedDate.month.toString().padLeft(2, '0')}/"
                    "${pickedDate.day.toString().padLeft(2, '0')}/"
                    "${pickedDate.year}";
              });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: genderController.text.isNotEmpty ? genderController.text : null,
            items: ["Male", "Female", "Other"].map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                genderController.text = value!;
              });
            },
            decoration: InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        _buildTextField(
          controller: passwordController,
          label: "Password",
          hint: "xxxxxxxxxx",
          isPassword: true,
        ),
        _buildTextField(
          controller: confirmPasswordController,
          label: "Confirm Password",
          hint: "xxxxxxxxxx",
          isPassword: true,
          errorText: !passwordsMatch && confirmPasswordController.text.isNotEmpty
              ? 'Passwords do not match'
              : null,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: register,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Register",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Or continue with',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, Colors.blue[600]!),
              SizedBox(width: 16),
              _buildSocialButton(Icons.g_mobiledata, Colors.red),
              SizedBox(width: 16),
              _buildSocialButton(Icons.apple, Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why choose us?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildMobileFeatureItem(
            Icons.verified_user,
            'Verified Profiles',
            Colors.blue,
          ),
          SizedBox(height: 16),
          _buildMobileFeatureItem(
            Icons.security,
            'Safe & Secure',
            Colors.green,
          ),
          SizedBox(height: 16),
          _buildMobileFeatureItem(
            Icons.favorite,
            'Successful Matches',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFeatureItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 40) {
      for (var j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
