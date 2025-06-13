import 'package:flutter/material.dart';

class EncouragementGenerator extends StatefulWidget {
  final VoidCallback onGoBack;
  const EncouragementGenerator({super.key, required this.onGoBack});

  @override
  State<EncouragementGenerator> createState() => _EncouragementGeneratorState();
}

class _EncouragementGeneratorState extends State<EncouragementGenerator> {
  final List<Map<String, String>> letters = [
    {
      'title': '💌 오늘 너에게',
      'body': '''
안녕, 소중한 너에게 🍀

요즘 많이 힘들지 않았을까 걱정이 돼.  
그래도 여기까지 잘 버텨줘서 정말 고마워.  
누군가에게 보여지지 않더라도,  
너의 하루하루는 분명히 의미 있는 걸 알아줬으면 해.

오늘도 너를 응원할게.  
항상 네 편이야. 💛
''',
      'message': '너는 그 자체로 빛나는 사람이야 ✨',
    },
    {
      'title': '🕊 작은 위로',
      'body': '''
사랑하는 너에게 💌

매일을 살아낸다는 것,  
그 자체만으로도 너는 충분히 멋진 사람이야.  
가끔은 멈춰서 하늘도 보고,  
스스로에게 수고했다고 말해줘.

네가 얼마나 소중한 존재인지  
잊지 않길 바라.  
''',
      'message': '네 존재만으로도 이미 충분해 🌷',
    },
    {
      'title': '🌸 너에게 보내는 편지',
      'body': '''
완벽하지 않아도 괜찮아.  
슬퍼도 괜찮고, 울어도 괜찮아.  
네 감정 하나하나를 소중히 안아줘.

오늘도 네가 웃을 수 있기를 바랄게.  
언제나 널 응원하는 사람이 있다는 걸 기억해줘.
''',
      'message': '오늘도 너, 정말 멋져 💖',
    },
    {
      'title': '🌟 네가 잘하고 있다는 증거',
      'body': '''
어느 순간에도 포기하지 않은 너,  
그 자체로 정말 대단해.  

비록 느릴지라도  
한 걸음씩 나아가는 너의 모습이  
가장 빛나 보여.

조금만 더 힘내자.  
너는 충분히 해낼 수 있어. 💪
''',
      'message': '네가 걸어온 길을 믿어도 좋아! 🚀',
    },
    {
      'title': '☕ 마음 한잔, 위로 한스푼',
      'body': '''
지친 하루 끝,  
이 글이 너에게 작은 위로가 되길 바라.

완벽하지 않아도 괜찮아.  
잘하고 있어, 정말로.  

가끔은 잠시 멈춰 쉬어도 돼.  
네 마음도 소중하니까.

내일의 너는 더 따뜻할 거야. 🌼
''',
      'message': '너의 오늘에, 따뜻한 박수를 보낼게 👏',
    },
  ];

  late Map<String, String> selectedLetter;
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    selectedLetter = letters[0];
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => showContent = true);
    });
  }

  void generate() {
    final shuffled = List<Map<String, String>>.from(letters)..shuffle();
    setState(() {
      showContent = false;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        selectedLetter = shuffled.first;
        showContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: widget.onGoBack,
                icon: const Icon(Icons.chevron_left),
                label: const Text("뒤로가기"),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: AnimatedOpacity(
                  opacity: showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedScale(
                    scale: showContent ? 1.0 : 0.97,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.pink.shade100),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedLetter['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                              fontFamily: 'CuteFont',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedLetter['body'] ?? '',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.7,
                              fontFamily: 'NanumPenScript',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            selectedLetter['message'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontFamily: 'PoorStory',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: generate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("다른 편지 받아보기"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
