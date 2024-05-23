// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:research_consulting/forgot_password.dart';
// import 'package:research_consulting/forgot_password.dart';
import 'dart:convert';

import 'package:research_consulting/home.dart';
import 'package:research_consulting/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(512, 512),
      builder: (BuildContext context, child) => MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: "Login"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var staffIdController = TextEditingController();
  var passwordController = TextEditingController();
  late Map<String, dynamic> res = {};

  late List<String> list1 = [];
  Map<String, dynamic> list = {};

  Future<String> login(String staff_ID, String password) async {
    var response = await http.post(
      Uri.parse("http://rcapp.nitt.edu/loginUser.php"),
      //  Uri.parse("http://127.0.0.1/R&C/v1/loginUser.php"),
      headers: {
        "Accept": "application/json", // Expect a JSON response
        "Content-Type": "application/x-www-form-urlencoded" // Sending form data
      },
      body: {
        "username": staff_ID,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        // Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['error']) {
          // Failed to login
          Fluttertoast.showToast(
            msg: "Login failed. Please check your credentials.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } else {
          // Successful login
          Fluttertoast.showToast(
            msg: "Login successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Assuming you have a setState function to update the UI
          setState(() {
            isLogin = true;
          });

          // Redirect to the Home page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                id: staff_ID,
                pass: password,
              ),
            ),
          );
        }
      } catch (e) {
        // JSON parsing error
        print('Error parsing JSON: $e');
        print("Response body: ${response.body}");
        Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print("Server error: ${response.statusCode}");
      print("Response body: ${response.body}");
      Fluttertoast.showToast(
        msg: "Server error: ${response.statusCode}. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 15.0,
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/NITT_logo.png/481px-NITT_logo.png',
                width: 90.0,
                height: 90.0,
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
              Text(
                "Login",
                style: TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Staff Id',
                          hintText: 'Enter Staff ID',
                          prefixIcon: Icon(Icons.account_circle_outlined),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String staffID) {},
                        controller: staffIdController,
                        validator: (staff_ID) {
                          if (staff_ID == null || staff_ID.isEmpty) {
                            return 'Please enter Staff ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String password) {},
                        controller: passwordController,
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await login(staffIdController.text,
                                passwordController.text);
                            print("Login status: $isLogin"); // Debugging
                            if (!isLogin) {
                              print("Navigating to Home page"); // Debugging
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home(
                                            id: staffIdController.text,
                                            pass: passwordController.text,
                                          )));
                            }
                          }
                        },
                        child: const Text('Submit'),
                      ),
                      SizedBox(height: 5.h),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPasswordPage()),
                          );
                        },
                        child: Text("Forgot Password?",
                            style: TextStyle(
                                color: Color.fromARGB(255, 244, 47, 3))),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text("New User?"),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()));
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    decoration: TextDecoration.underline),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
