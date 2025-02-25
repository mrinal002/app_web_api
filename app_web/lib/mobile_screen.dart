import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_email_service.dart';
import 'token_service.dart';
import 'widgets/nav_bar.dart';
import 'widgets/footer.dart';

class MobileScreen extends StatefulWidget {
  @override
  _MobileScreenState createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _apiService = ApiService();
  String? _message;
  bool _isLoading = false;
  String? _tempToken;
  String? _savedPhoneNumber;
  bool _showOtpField = false;

  // Add these controllers for individual OTP digits
  final List<TextEditingController> _otpDigitControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

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
    for (var controller in _otpDigitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final userEmail = UserEmailService.getEmail();
    if (userEmail == null) {
      setState(() {
        _isLoading = false;
        _message = "Please Go Register first.";
      });
      return;
    }

    final response = await _apiService.sendOtp(
      userEmail,
      _phoneController.text,
    );

    setState(() {
      _isLoading = false;
      _message = response.message;
      if (response.success) {
        _tempToken = response.data?['tempToken'];
        _savedPhoneNumber = _phoneController.text;
        _showOtpField = true;
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_tempToken == null || _savedPhoneNumber == null) return;

    // Collect OTP from individual controllers
    final String combinedOtp = _otpDigitControllers
        .map((controller) => controller.text)
        .join();

    if (combinedOtp.length != 6) {
      setState(() {
        _message = "Please enter a complete 6-digit code";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final response = await _apiService.verifyOtp(
      _savedPhoneNumber!,
      _tempToken!,
      combinedOtp,
    );

    setState(() {
      _isLoading = false;
      _message = response.message;
      if (response.success) {
        if (response.data?['token'] != null) {
          TokenService.setToken(response.data!['token']);
        }
        // Clear all OTP fields
        for (var controller in _otpDigitControllers) {
          controller.clear();
        }
        _showOtpField = false;
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildMessageBox() {
    bool isEmailNotFound = _message?.contains('Email not found') ?? false;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmailNotFound 
            ? Colors.orange[50]
            : _message!.contains('successful')
                ? Colors.green[50]
                : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmailNotFound
              ? Colors.orange[200]!
              : _message!.contains('successful')
                  ? Colors.green[200]!
                  : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEmailNotFound
                    ? Icons.info_outline
                    : _message!.contains('successful')
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                color: isEmailNotFound
                    ? Colors.orange[700]
                    : _message!.contains('successful')
                        ? Colors.green[700]
                        : Colors.red[700],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: isEmailNotFound
                        ? Colors.orange[700]
                        : _message!.contains('successful')
                            ? Colors.green[700]
                            : Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (isEmailNotFound) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Register Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_showOtpField ? _verifyOtp : _sendOtp),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[700],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showOtpField ? 'Verify OTP' : 'Send OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    _showOtpField ? Icons.check_circle : Icons.arrow_forward,
                    size: 20,
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
                            Colors.purple[700]!,
                            Colors.purple[900]!,
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
                            'Phone Verification',
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
                              'Secure your account and enable instant notifications by verifying your phone number',
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
                                      _showOtpField ? 'Enter Verification Code' : 'Enter Phone Number',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[900],
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      _showOtpField
                                          ? 'Please enter the code we sent to your phone'
                                          : 'We\'ll send you a verification code to confirm your number',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          if (!_showOtpField)
                                            _buildTextField(
                                              controller: _phoneController,
                                              label: 'Phone Number',
                                              hint: '+918538877079',
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter phone number';
                                                }
                                                if (!value.startsWith('+')) {
                                                  return 'Phone number must start with +';
                                                }
                                                return null;
                                              },
                                            ),
                                          if (_showOtpField)
                                            _buildOtpInput(),
                                          if (_message != null)
                                            _buildMessageBox(),
                                          SizedBox(height: 24),
                                          _buildActionButton(),
                                        ],
                                      ),
                                    ),
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
                                _buildFeatureCard(
                                  icon: Icons.verified_user,
                                  title: 'Enhanced Security',
                                  description: 'Protect your account with two-factor authentication for better security.',
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 24),
                                _buildFeatureCard(
                                  icon: Icons.notifications_active,
                                  title: 'Instant Updates',
                                  description: 'Get real-time notifications about your matches and messages.',
                                  color: Colors.green,
                                ),
                                SizedBox(height: 24),
                                _buildFeatureCard(
                                  icon: Icons.support_agent,
                                  title: 'Priority Support',
                                  description: 'Access premium customer support with verified phone number.',
                                  color: Colors.orange,
                                ),
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

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter 6-digit code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 50,
              child: TextField(
                controller: _otpDigitControllers[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (value) {
                  if (value.length == 1) {
                    if (index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                },
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple[700]!,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: Colors.purple[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Code sent to ${_savedPhoneNumber ?? ""}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
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

  Widget _buildMobileLayout() {
    return Container(
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
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
                          Icons.phone_android,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Verify Your Phone',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Complete your profile verification',
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
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressIndicator(),
                      SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _showOtpField ? 'Enter OTP' : 'Enter Phone Number',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _showOtpField
                                      ? 'Please enter the verification code sent to your phone'
                                      : 'We\'ll send you a verification code',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 24),
                                if (!_showOtpField)
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number',
                                    hint: '+918538877079',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      if (!value.startsWith('+')) {
                                        return 'Phone number must start with +';
                                      }
                                      return null;
                                    },
                                  ),
                                if (_showOtpField)
                                  _buildTextField(
                                    controller: _otpController,
                                    label: 'OTP Code',
                                    hint: '123456',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter OTP';
                                      }
                                      return null;
                                    },
                                  ),
                                SizedBox(height: 24),
                                if (_message != null)
                                  _buildMobileMessageBox(),
                                SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : (_showOtpField ? _verifyOtp : _sendOtp),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[700],
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            _showOtpField ? 'Verify OTP' : 'Send OTP',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildFeatureList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(1, 'Account', false),
        _buildProgressLine(true),
        _buildProgressStep(2, 'Verify', true),
        _buildProgressLine(false),
        _buildProgressStep(3, 'Complete', false),
      ],
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(
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
        ),
      ],
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.person_outline;
      case 2:
        return Icons.phone_android;
      case 3:
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
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

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why verify your phone?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        _buildFeatureItem(
          Icons.verified_user,
          'Enhanced Security',
          'Protect your account with two-factor authentication',
          Colors.blue,
        ),
        SizedBox(height: 16),
        _buildFeatureItem(
          Icons.chat_bubble_outline,
          'Instant Notifications',
          'Receive important updates and messages',
          Colors.green,
        ),
        SizedBox(height: 16),
        _buildFeatureItem(
          Icons.lock_outline,
          'Account Recovery',
          'Easily recover your account if needed',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMessageBox() {
    bool isEmailNotFound = _message?.toLowerCase().contains('register') ?? false;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmailNotFound ? Colors.orange[50] : _message!.contains('successful')
            ? Colors.green[50]
            : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isEmailNotFound ? Icons.info_outline
                    : _message!.contains('successful') ? Icons.check_circle
                    : Icons.error_outline,
                color: isEmailNotFound ? Colors.orange[700]
                    : _message!.contains('successful') ? Colors.green[700]
                    : Colors.red[700],
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: isEmailNotFound ? Colors.orange[700]
                        : _message!.contains('successful') ? Colors.green[700]
                        : Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isEmailNotFound) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                icon: Icon(Icons.person_add),
                label: Text('Create Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
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
