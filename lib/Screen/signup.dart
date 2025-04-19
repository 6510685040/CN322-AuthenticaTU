import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/Screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();
  String errorMessage = '';

  void register() async {
    final email = controllerEmail.text.trim();
    final password = controllerPassword.text.trim();
    final confirmPassword = controllerConfirmPassword.text.trim();

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email and password.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        errorMessage = "Please enter your password.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
      });
      return;
    }
    try {
      await authService.value.createAccount(
        email: controllerEmail.text,
        password: controllerPassword.text,
      );
      popPage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'There is an error';
      });
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF000957),
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.20,
                left: screenWidth * 0.20,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w800,
                      fontSize: screenWidth * 0.10,
                    ),
                    children: [
                      TextSpan(
                        text: 'Authentica',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'TU',
                        style: TextStyle(color: Color(0xFFFFEB00)),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: screenHeight * 0.27,
                left: screenWidth * 0.23,
                child: Text(
                  'Lock your world, secure your life',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),

              // Form Box
              Positioned(
                top: screenHeight * 0.35,
                left: screenWidth * 0.10,
                child: Container(
                  width: screenWidth * 0.80,
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      // Username Label
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.04,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Username Input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerEmail,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // Password Label
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.04,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Password Input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Create Your Password',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Password Labe
                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: screenWidth * 0.10,
                      //   ),
                      //   child: TextField(
                      //     obscureText: true,
                      //     decoration: InputDecoration(
                      //       hintText: 'Confirm Your Password',
                      //       hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //         borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                      //       ),
                      //     ),
                      //   ),

                      // ),
                      // Password Labe
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerConfirmPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Confirm Your Password',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Sign Up Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: SizedBox(
                          width: screenWidth * 0.70,
                          height: screenHeight * 0.05,

                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFFFFEB00),
                              side: BorderSide(color: Color(0xFFD9D9D9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: register, //{
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => LoginScreen(),
                            //   ),
                            // );
                            //}
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                        ),
                      ),
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
}
