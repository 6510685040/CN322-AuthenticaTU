import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:authenticatu/Screen/auth_layout.dart';
import 'package:authenticatu/shared_pref_access.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await TOTPDB.initialize();
  await initializePreferences();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return OtpProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authenticator',
      home: const AuthLayout(), // ✅ AuthLayout will decide which screen to show
    );
  }
}
