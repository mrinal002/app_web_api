import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_email_service.dart';
import 'token_service.dart';  // Add this import

class MobileScreen extends StatefulWidget {
  @override
  _MobileScreenState createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _apiService = ApiService();
  String? _message;
  bool _isLoading = false;
  String? _tempToken;
  String? _savedPhoneNumber;
  bool _showOtpField = false;

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
        _message = "Email not found. Please register first.";
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

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final response = await _apiService.verifyOtp(
      _savedPhoneNumber!,
      _tempToken!,
      _otpController.text,
    );

    setState(() {
      _isLoading = false;
      _message = response.message;
      if (response.success) {
        // Store the token
        if (response.data?['token'] != null) {
          TokenService.setToken(response.data!['token']);
        }
        _showOtpField = false;
        _otpController.clear();
        // Navigate to profile screen after successful verification
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number (e.g., +918538877079)',
                ),
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
              if (_showOtpField) ...[
                SizedBox(height: 20),
                TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    hintText: 'Enter OTP received',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 20),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('successful') ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : (_showOtpField ? _verifyOtp : _sendOtp),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(_showOtpField ? 'Verify OTP' : 'Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
