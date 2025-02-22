import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_email_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();

void register() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
TextField(
  controller: emailController,
  decoration: InputDecoration(labelText: "Email"),
  keyboardType: TextInputType.emailAddress,
),
TextField(
  controller: nameController,
  decoration: InputDecoration(labelText: "Name"),
),
TextField(
  controller: dateOfBirthController,
  decoration: InputDecoration(labelText: "Date of Birth"),
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
DropdownButtonFormField<String>(
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
  decoration: InputDecoration(labelText: "Gender"),
),
TextField(
  controller: passwordController,
  decoration: InputDecoration(labelText: "Password"),
  obscureText: true,
),

            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
