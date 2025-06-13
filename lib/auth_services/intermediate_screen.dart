import 'package:flutter/material.dart';

class CharacterSurveyScreen extends StatefulWidget {
  const CharacterSurveyScreen({super.key});

  @override
  State<CharacterSurveyScreen> createState() => _CharacterSurveyScreenState();
}

class _CharacterSurveyScreenState extends State<CharacterSurveyScreen> {
  final Map<int, int> answers = {};

  final List<String> questions = [
    "나는 새로운 사람과 쉽게 친해지는 편이다.",
    "나는 기술적인 아이디어보다 감정 표현을 더 선호한다.",
    "나는 계획보다는 즉흥적인 것을 더 좋아한다.",
    "나는 시적이거나 문학적인 표현을 자주 사용한다.",
    "나는 문제를 논리적으로 해결하려 한다.",
    "나는 다양한 시도를 즐기는 편이다.",
    "나는 감정에 따라 결정을 내리는 경우가 많다.",
    "나는 혼자 있는 시간보다 여럿이 있는 시간을 더 좋아한다.",
    "나는 규칙보다는 자유를 중요하게 생각한다."
  ];

  void _selectAnswer(int value, int index) {
    setState(() {
      answers[index] = value;
    });

    if (answers.length == questions.length) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    String result = _calculateResult();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("추천 캐릭터 🎯"),
        content: Text("당신에게 어울리는 캐릭터는 '$result' 입니다!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  String _calculateResult() {
    int score = answers.values.fold(0, (sum, value) => sum + value);
    if (score <= 30) return '세라 (기술적)';
    if (score <= 50) return '유리 (균형잡힘)';
    return '하린 (감성적)';
  }

  Widget _buildOption(int index, int questionIndex) {
    return GestureDetector(
      onTap: () => _selectAnswer(index + 1, questionIndex),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: answers[questionIndex] == index + 1
              ? (index < 3
                  ? const Color.fromARGB(255, 138, 219, 91)
                  : index > 3
                      ? const Color.fromARGB(255, 233, 182, 147)
                      : Colors.grey[400])
              : Colors.white,
          border: Border.all(
            color: index < 3
                ? const Color.fromARGB(255, 145, 231, 148)
                : index > 3
                    ? const Color.fromARGB(255, 243, 181, 139)
                    : Colors.grey,
            width: 2,
          ),
        ),
        child: answers[questionIndex] == index + 1
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = answers.length / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: questions.length + 1,
                separatorBuilder: (context, index) {
                  if (index == 0) return const SizedBox(height: 16);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 0.8,
                      indent: 32,
                      endIndent: 32,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/sodam_icon.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.85),
                            BlendMode.lighten,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "일상속 맞춤형 AI 친구를 선택해보세요!",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Sodam🍃",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                InfoCard(
                                  icon: Icons.balance,
                                  text:
                                      "여러분의 성격 유형을 확인할 수 있도록 솔직하게 답변해 주세요.",
                                ),
                                InfoCard(
                                  icon: Icons.scatter_plot,
                                  text: "친구같은 AI를 만들어보세요!",
                                ),
                                InfoCard(
                                  icon: Icons.menu_book,
                                  text: "설문을 통해 AI친구와 일상을 같이 보내보세요!",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final questionIndex = index - 1;
                  final isAnswered = answers.containsKey(questionIndex);
                  final isCurrent = questionIndex == answers.length;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isAnswered || isCurrent ? 1.0 : 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          questions[questionIndex],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              7, (i) => _buildOption(i, questionIndex)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 15, 14, 15)),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  Text("${(progress * 100).round()}% 완료"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoCard({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 248, 248),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 34, color: const Color.fromARGB(255, 240, 206, 183)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
