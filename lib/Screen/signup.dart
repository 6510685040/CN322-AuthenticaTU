import 'package:authenticatu/Screen/login.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
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
                          decoration: InputDecoration(
                            hintText: 'Enter your username',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
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
                      SizedBox(height: screenHeight * 0.04),
                
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
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
