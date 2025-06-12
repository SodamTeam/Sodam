import 'package:flutter/material.dart';

class EncouragementGenerator extends StatefulWidget {
  final VoidCallback onGoBack;
  const EncouragementGenerator({super.key, required this.onGoBack});

  @override
  State<EncouragementGenerator> createState() => _EncouragementGeneratorState();
}

class _EncouragementGeneratorState extends State<EncouragementGenerator> {
  final List<String> messages = [
    '너의 존재만으로도 소중해 🌷',
    '오늘 하루도 잘 버틴 너, 정말 대단해 💪',
    '조금 쉬어가도 괜찮아. 항상 응원해! 💖',
    '괜찮아. 넌 할 수 있어. 🌈',
  ];
  String message = '';

  @override
  void initState() {
    super.initState();
    message = messages[0];
  }

  void generate() {
    final random = (messages.toList()..shuffle()).first;
    setState(() => message = random);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Column(
          children: [
            TextButton.icon(
              onPressed: widget.onGoBack,
              icon: const Icon(Icons.chevron_left),
              label: const Text("뒤로가기"),
            ),
            const SizedBox(height: 12),
            const Text(
              "💌 응원 메시지 생성기",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.pink.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: generate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text("오늘의 한마디 받기"),
            )
          ],
        ),
      ),
    );
  }
}