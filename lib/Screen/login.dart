import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/backup_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authenticatu/Screen/auth_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:authenticatu/Screen/signup.dart';
import 'package:authenticatu/Screen/reset_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  String errorMessage = '';

  Future<void> signIn() async {
    if (controllerEmail.text.isEmpty || controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password.';
      });
      return;
    }
    try {
      final password = controllerPassword.text;
      await authService.value.signIn(
        email: controllerEmail.text,
        password: password,
      );
      await BackupService().handleLogin(password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'This is not working';
      });
    }
  }

  void loginWithoutAccount() async {
    // Save guest mode flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guestUser', true);

    // Navigate to Home or AuthLayout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthLayout()),
    );
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF000957),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000957),
              Color.fromARGB(255, 16, 27, 126),
              Color.fromARGB(255, 54, 63, 142),
              Color.fromARGB(255, 79, 84, 130),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SingleChildScrollView(
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
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        //fontFamily: 'Geist',
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

                // Subtitle
                Positioned(
                  top: screenHeight * 0.27,
                  left: screenWidth * 0.23,
                  child: Text(
                    'Lock your world, secure your life',
                    style: TextStyle(
                      //fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                      color: Colors.white70,
                    ),
                  ),
                ),

                // Form Box
                Positioned(
                  top: screenHeight * 0.35,
                  left: screenWidth * 0.10,
                  child: Container(
                    width: screenWidth * 0.80,
                    height: screenHeight * 0.56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
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
                                //fontFamily: 'Geist',
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
                              hintText: 'example@hmail.com',
                              hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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
                                //fontFamily: 'Geist',
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
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // --- Forgot Password Button ---
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //     right:
                        //         screenWidth *
                        //         0.10, // Align with text field padding
                        //     top: 4, // Add a small space above
                        //   ),
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child: TextButton(
                        //       onPressed: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder:
                        //                 (context) =>
                        //                     ResetPasswordPage(email: ''),
                        //           ),
                        //         );
                        //       },
                        //       style: TextButton.styleFrom(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 8.0,
                        //           vertical: 4.0,
                        //         ),
                        //         minimumSize: Size(
                        //           50,
                        //           30,
                        //         ), // Ensure it's clickable
                        //         tapTargetSize:
                        //             MaterialTapTargetSize
                        //                 .shrinkWrap, // Reduce tap area
                        //         alignment: Alignment.centerRight,
                        //       ),
                        //       child: Text(
                        //         'Forgot Password?',
                        //         style: TextStyle(
                        //           //fontFamily: 'Geist',
                        //           fontWeight: FontWeight.w600,
                        //           fontSize:
                        //               screenWidth *
                        //               0.035, // Slightly smaller font
                        //           color: Color(
                        //             0xFF000957,
                        //           ), // Use app's primary color
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 8),
                        // --- End Forgot Password Button ---
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        // SizedBox(height: screenHeight * 0.04),

                        // Login Button
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.10,
                          ),
                          child: SizedBox(
                            width: screenWidth * 0.70,
                            height: screenHeight * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFEB00),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide.none,
                                ),
                              ),
                              onPressed: () async {
                                await signIn();
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  //fontFamily: 'Geist',
                                  //fontWeight: FontWeight.w900,//FontWeight.w600,
                                  fontSize: screenWidth * 0.045,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
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
                                side:
                                    BorderSide
                                        .none, //BorderSide(color: Color(0xFFD9D9D9)),
                                backgroundColor: Color.fromARGB(
                                  128,
                                  217,
                                  217,
                                  217,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  //fontFamily: 'Geist',
                                  //fontWeight: FontWeight.w900,
                                  fontSize: screenWidth * 0.045,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          //height: screenHeight * 0.015),
                          width: screenWidth * 0.60,
                          height: screenHeight * 0.05,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // use without account
                            /*
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: SizedBox(
                          width: screenWidth * 0.70,
                          height: screenHeight * 0.05,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,//BorderSide(color: Color(0xFFD9D9D9)),
                              backgroundColor: Color.fromARGB(128, 217, 217, 217),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),*/
                            onPressed: loginWithoutAccount,
                            child: Text(
                              'Use Without Account',
                              style: TextStyle(
                                //fontFamily: 'Geist',
                                //: FontWeight.w600,
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF2C2C2C),
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
      ),
    );
  }
}
