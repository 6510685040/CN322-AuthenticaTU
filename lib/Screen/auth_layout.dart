import 'package:authenticatu/Screen/app_loading_page.dart';
import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/Screen/login.dart';
import 'package:flutter/material.dart';
import 'package:authenticatu/Screen/home.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key});

  @override
  Widget build(BuildContext context) {
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
              widget = HomeScreen();
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
