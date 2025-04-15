import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfnotConnected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: child)));
  }
}
