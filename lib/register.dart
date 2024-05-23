import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:research_consulting/home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  var staffIdController = TextEditingController();
  var webmailIDController = TextEditingController();
  var passwordController = TextEditingController();

  //String error = "";
  String message = "";

  Future<String> Register(String staff_ID, webmail_ID, password) async {
    var _response = await http
        .post(Uri.parse("http://rcapp.nitt.edu/registerUser.php"), body: {
      "username": staff_ID,
      "password": password,
      "email": webmail_ID
    });
    print(_response.statusCode);
    if (_response.statusCode == 200) {
      setState(() {
        Map a = jsonDecode(_response.body);
        //error = a['error'];
        message = a['message'];
        print(a);

        //list1.add(_response.body);
      });
    }
    ;
    return _response.body;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text("Register"),
        // ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 15.0,
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/NITT_logo.png/481px-NITT_logo.png',
                width: 100.0,
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

              // SizedBox(height: 10.h,),
              Text(
                "Register",
                style: TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Staff Id',
                          hintText: 'Enter Staff ID',
                          prefixIcon: Icon(Icons.account_circle_outlined),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String staff_ID) {},
                        controller: staffIdController,
                        validator: (staff_ID) {
                          if (staff_ID == null || staff_ID.isEmpty) {
                            return 'Please enter Staff ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: ' Webmail ID',
                          hintText: 'Enter Username',
                          // prefixIcon: Icon(Icons.account_circle_outlined),
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        // onChanged: (String staff_ID){

                        // },
                        onChanged: (String email) {
                          // Update your logic here if needed
                        },
                        controller: webmailIDController,
                        // validator: (staff_ID){
                        //   if (staff_ID == null || staff_ID.isEmpty) {
                        //     return 'Please enter Username';
                        //   }
                        //   return null;
                        // },
                        validator: (email) {
                          if (email == null || email.isEmpty) {
                            return 'Please enter Email';
                          }
                          // Use a regular expression to check if the entered value is a valid email address
                          // You can use a more sophisticated email validation regex if needed
                          bool isValidEmail = RegExp(
                                  r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                              .hasMatch(email);
                          if (!isValidEmail) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 5.h,
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
                        height: 5.h,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await Register(
                                staffIdController.text,
                                webmailIDController.text,
                                passwordController.text);
                            if (message == "Invalid Username or staff Id") {
                              Fluttertoast.showToast(
                                  msg: "Invalid Username or staff Id",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (message == "User Already registered") {
                              Fluttertoast.showToast(
                                  msg: "User Already registered",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (message == "Registered Successfully") {
                              Fluttertoast.showToast(
                                  msg: "Registered Successfully",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);

                              // Navigator.push(context , MaterialPageRoute(builder: (context) => Home(id: staffIdController.text , pass: passwordController.text,)));
                              Navigator.pop(context, {
                                'id': staffIdController.text,
                                'pass': passwordController.text,
                              });
                            }
                          }
                        },
                        child: const Text('Register'),
                      ),
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
