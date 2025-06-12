// Sodam/lib/main.dart
import 'auth_services/intermediate_screen.dart';
import 'package:flutter/material.dart';
import 'auth_services/intro_screen.dart';
import 'auth_services/login_screen.dart';
import 'auth_services/signup_screen.dart';
import 'mainScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sodam',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const IntroScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/intermediate': (_) => const CharacterSurveyScreen(), // ✅ 추가된 라우트
        '/home': (_) => const HomePage(),
      },
    );
  }
}
