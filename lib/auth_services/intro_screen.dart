// Sodam/lib/screens/intro_screen.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  static const String _title =
      '너무 친절하진 않아도,\n딱 너한테 맞는 대화. 그게 목표야';
  static const String _bgImage = 'assets/introback.png';
  static const String _iconImage = 'assets/introicon.png';

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
  final loggedIn = await AuthService.isLoggedIn();
  if (!mounted) return;
  if (loggedIn) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// ─── 상단 배경 (55%) ───
            SizedBox(
              height: size.height * 0.55,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_bgImage, fit: BoxFit.cover),
                  Container(color: Colors.white.withOpacity(0.4)),
                ],
              ),
            ),

            /// ─── 아이콘 ───
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: ClipOval(
                  child: Image.asset(_iconImage, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ─── 타이틀 ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// ─── 버튼 ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _PrimaryButton(
                    text: '가입하기',
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                  ),
                  const SizedBox(height: 16),
                  _SecondaryButton(
                    text: '로그인하기',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Text(text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );
}
