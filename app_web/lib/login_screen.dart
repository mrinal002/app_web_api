import 'package:flutter/material.dart';
import 'api_service.dart';
import 'token_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  void login() async {
    var response = await apiService.login(emailOrMobileController.text, passwordController.text);
    if (response.success && response.data != null) {
      TokenService.setToken(response.data!['token']);
      Navigator.pushReplacementNamed(context, '/profile');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: response.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailOrMobileController, 
              decoration: InputDecoration(labelText: "Email or Mobile")
            ),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}
