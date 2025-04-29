import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/Screen/login.dart';
import 'package:authenticatu/Screen/verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:authenticatu/Screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authenticatu/Screen/app_loading_page.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  bool? isGuest;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final guest = prefs.getBool('guestUser') ?? false;
    setState(() {
      isGuest = guest;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest == null) {
      return const AppLoadingPage(); // still loading
    }

    if (isGuest == true) {
      return const HomeScreen(); // Guest mode
    }

    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = VerifyEmailPage();
            } else {
              widget = const LoginScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
