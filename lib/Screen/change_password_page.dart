import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:authenticatu/Screen/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerCurrentPassword = TextEditingController();
  TextEditingController controllerNewPassword = TextEditingController();
  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;

  void changePassword() async {
    if (controllerEmail.text.isEmpty ||
        controllerCurrentPassword.text.isEmpty ||
        controllerNewPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      // Re-authenticate the user first
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: controllerEmail.text,
        password: controllerCurrentPassword.text,
      );

      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(controllerNewPassword.text);

      setState(() {
        successMessage = 'Password updated successfully';
        controllerCurrentPassword.clear();
        controllerNewPassword.clear();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Failed to change password';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF000957),
      appBar: AppBar(
        backgroundColor: Color(0xFF000957),
        foregroundColor: Colors.white,
        title: Text(
          'Change Password',
          style: TextStyle(
            /*fontFamily: 'Geist',*/ fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight * 0.9,
          child: Stack(
            children: [
              // Title
              Positioned(
                top: screenHeight * 0.10,
                left: screenWidth * 0.10,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      //fontFamily: 'Geist',
                      fontWeight: FontWeight.w800,
                      fontSize: screenWidth * 0.08,
                    ),
                    children: [
                      TextSpan(
                        text: 'Update ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Password',
                        style: TextStyle(color: Color(0xFFFFEB00)),
                      ),
                    ],
                  ),
                ),
              ),

              // Subtitle
              Positioned(
                top: screenHeight * 0.17,
                left: screenWidth * 0.10,
                child: Text(
                  'Keep your account secure with a strong password',
                  style: TextStyle(
                    //fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),

              // Form Box
              Positioned(
                top: screenHeight * 0.25,
                left: screenWidth * 0.10,
                child: Container(
                  width: screenWidth * 0.80,
                  height: screenHeight * 0.60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Email Label
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              // fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.04,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Email Input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'example@hmail.com',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Current Password Label
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Current Password',
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

                      // Current Password Input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerCurrentPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: 'Enter your current password',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // New Password Label
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'New Password',
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

                      // New Password Input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: TextField(
                          controller: controllerNewPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: 'Enter your new password',
                            hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                        ),
                      ),

                      // Error message
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.10,
                          ),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.redAccent,
                              //fontFamily: 'Geist',
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),

                      // Success message
                      if (successMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.10,
                          ),
                          child: Text(
                            successMessage,
                            style: TextStyle(
                              color: Colors.green,
                              //fontFamily: 'Geist',
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Update Password Button
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
                              ),
                            ),
                            onPressed: isLoading ? null : changePassword,
                            child:
                                isLoading
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF2C2C2C),
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      'Update Password',
                                      style: TextStyle(
                                        //fontFamily: 'Geist',
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.045,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                    ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Cancel Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.10,
                        ),
                        child: SizedBox(
                          width: screenWidth * 0.70,
                          height: screenHeight * 0.05,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFD9D9D9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                //fontFamily: 'Geist',
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
