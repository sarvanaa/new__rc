

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var newPasswordController = TextEditingController();
  var staffIdController = TextEditingController();

  Future<Map<String, dynamic>> resetPassword(
      String WebmailId, String newPassword, String staffId) async {
    final response = await http.post(
      Uri.parse('http://rcapp.nitt.edu/resetPassword.php'),
      // Uri.parse("http://127.0.0.1/R&C/v1/resetPassword.php"),
      body: {
        'email': WebmailId,
        'password': newPassword,
        'username': staffId, // Add this line
      },
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print('Response data: $responseData');
      return responseData;
    } else {
      print('Server error: ${response.statusCode}');
      return {'success': false, 'message': 'Server error'};
    }
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  void _showResetSuccessMessage() {
    Fluttertoast.showToast(
      msg: "Password reset successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/NITT_logo.png/481px-NITT_logo.png',
                width: 70.0,
                height: 100.0,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
              SizedBox(height: 5.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Webmail ID',
                  icon: Icon(Icons.person), // Username icon
                ),
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your webmail id';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Staff ID',
                  icon: Icon(Icons.badge), // Staff ID icon
                ),
                controller: staffIdController, // Define this controller
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your staff ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                  icon: Icon(Icons.lock), // Password icon
                ),
                controller: newPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 105.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var result = await resetPassword(usernameController.text,
                          newPasswordController.text, staffIdController.text);
                      if (result['success']) {
                        _showToast(result['message'], Colors.green);
                        Navigator.pop(context); // Pop the current page
                      } else {
                        _showToast(result['message'] ?? 'Password reset failed',
                            Colors.red);
                      }
                    }
                  },
                  child: Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
