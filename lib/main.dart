import 'package:authenticatu/Screen/home.dart';
import 'package:authenticatu/Screen/login.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return OtpProvider();
          },
        ),
      ],
      child: MaterialApp(home: HomeScreen()),
    ),
  );
}
