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
      body: Center(
        child: Container(
          width: screenWidth * 0.9,
          //height: screenHeight * 0.32,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reset Your Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 10),
              //Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 25.0),
              // child:
              Text(
                //"Enter your email to reset password",
                "Enter your email below and we'll send you instructions to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  //fontFamily: 'Geist',
                  fontSize: 14,
                  color: Colors.grey[700],
                  //color: Color(0xFF000957),
                  //fontWeight: FontWeight.w600
                ),
              ),
              //),
              const SizedBox(height: 20),
              //email textfield
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.10),
              //  child:
              TextField(
                style: TextStyle(color: Colors.black),
                controller: controllerEmail,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'example@hmail.com',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide.none, //BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                ),
              ),
              // ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEB00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
