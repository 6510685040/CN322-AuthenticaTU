import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authenticatu/Screen/home.dart';
import 'dart:async';

class VerifyEmailPage extends StatefulWidget {
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      // Show a SnackBar on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>  
      isEmailVerified      
          ? HomeScreen()
          : Scaffold(           
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text(
                'Email Verification',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF000957),
            ),
            body: /*Center(
              child: Container(
                width: 350,
                height: 450,
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 246, 145),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),*/Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                  Icons.mark_email_read_rounded, // or any other icon
                  size: 80,
                  color: Color(0xFF000957),
                ),
                SizedBox(height: 16),
                  Text(
                    'Thanks for signing up!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'A verification email has been sent to your email.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      backgroundColor: Color(0xFF000957),
                    ),
                    icon: Icon(Icons.send, size: 32, color: Colors.white),
                    label: Text(
                      'Resend Email',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ],
              ),
            ),
     //     ),
          );
}
