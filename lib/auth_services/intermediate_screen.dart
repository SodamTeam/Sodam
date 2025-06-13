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
    "나는 규칙보다는 자유를 중요하게 생각한다.",
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
      title: const Center(
        child: Text(
          "추천 캐릭터",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
    content: Text(
      "당신에게 어울리는 캐릭터는 '$result' 입니다!",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),

        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/home");
            },
            child: const Text(
              "확인",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateResult() {
    int score = answers.values.fold(0, (sum, value) => sum + value);
    if (score <= 30) return '세라';
    if (score <= 50) return '유리';
    return '하린 ';
  }

  Widget _buildOption(int index, int questionIndex, {bool isDimmed = false}) {
    final bool isSelected = answers[questionIndex] == index + 1;
    return Opacity(
      opacity: isDimmed ? 0.2 : 1,
      child: GestureDetector(
        onTap: () => _selectAnswer(index + 1, questionIndex),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.deepOrange : Colors.white,
            border: Border.all(
              color: isSelected
                  ? Colors.deepOrange
                  : Colors.deepOrange.withOpacity(0.5),
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Column(
      key: ValueKey(index),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (index > 0) _buildDimmedQuestion(index - 1),
        _buildMainQuestion(index),
        if (index < questions.length - 1) _buildDimmedQuestion(index + 1),
      ],
    );
  }

  Widget _buildMainQuestion(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepOrange, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            questions[index],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              7,
              (i) => _buildOption(i, index, isDimmed: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimmedQuestion(int index) {
    return Opacity(
      opacity: 0.2,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              questions[index],
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  List.generate(7, (i) => _buildOption(i, index, isDimmed: true)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = answers.length / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 480,
          height: 740,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.deepOrange.shade100, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Image.asset(
                    'assets/sodam_icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const Text(
                  " 나와 어울리는 AI 친구를 추천해줄게!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "일상 속의 편안함을 주는 AI 소담🌸\n",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: answers.length < questions.length
                        ? _buildQuestionCard(answers.length)
                        : const Center(
                            key: ValueKey("done"),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 60, color: Colors.green),
                                SizedBox(height: 14),
                                Text(
                                  "설문이 완료되었습니다!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 2, 8, 5),
                        ),
                        minHeight: 5,
                      ),
                      const SizedBox(height: 20),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                        child: Text("${(progress * 100).round()}% 완료"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
