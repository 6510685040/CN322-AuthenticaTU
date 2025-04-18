import 'package:authenticatu/Screen/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController controllerEmail = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided
    controllerEmail.text = widget.email;
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    super.dispose();
  }

  void resetPassword() async {
    try {
      await authService.value.resetPassword(email: controllerEmail.text);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link sent! Pls check your email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(e.message.toString()));
        },
      );
      setState(() {
        errorMessage = e.message ?? 'This is not working';
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Enter your email to reset password",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          //email textfield
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.10),
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: controllerEmail,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Color(0xFFB3B3B3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(errorMessage, style: TextStyle(color: Colors.redAccent)),

          MaterialButton(
            onPressed: resetPassword,
            child: Text('Reset Password'),
            color: Color(0xFFFFEB00),
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
