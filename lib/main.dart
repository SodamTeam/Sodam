// Sodam/lib/main.dart

import 'package:flutter/material.dart';
import 'auth_services/intro_screen.dart';
import 'auth_services/login_screen.dart';
import 'auth_services/signup_screen.dart';
import 'mainScreen.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const IntroScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home':  (_) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
