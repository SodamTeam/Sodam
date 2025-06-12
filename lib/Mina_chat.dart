import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'profile_service.dart';
import 'EmotionDiary.dart';
import 'MeditationContent.dart';
import 'Encouragement.dart';

class MinaChat extends StatefulWidget {
  final VoidCallback goBack;
  const MinaChat({super.key, required this.goBack});

  @override
  State<MinaChat> createState() => _MinaChatState();
}

class _MinaChatState extends State<MinaChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService chatService = ChatService();
  String systemPrompt = '';

  List<Map<String, String>> messages = [
    {
      'sender': 'mina',
      'text': '안녕하세요, 저는 미나예요 🌸\n오늘 당신의 감정을 함께 나눠볼까요?',
    },
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('mina');
    setState(() {
      systemPrompt = profile;
    });
  }

  void _sendMessage(String input) async {
    if (input.trim().isEmpty || _isLoading) return;

    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final reply = await chatService.generate(input, systemPrompt: systemPrompt);

    setState(() {
      messages.add({'sender': 'mina', 'text': reply});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isMina = msg['sender'] == 'mina';
    return Align(
      alignment: isMina ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMina ? Colors.white : Colors.purple[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(
            color: isMina ? Colors.black87 : Colors.deepPurple,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f4fa),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.goBack,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Text(
                    '미나',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/girl3.png'),
                  ),
                ],
              ),
            ),

            // 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, idx) => _buildBubble(messages[idx]),
              ),
            ),

            // 기능 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmotionDiary(
                            onGoBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    child: const Text('감정일기 작성'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MeditationContent(
                            onGoBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    child: const Text('명상 & 릴렉스 콘텐츠'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EncouragementGenerator(
                            onGoBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    child: const Text('응원 메시지 생성'),
                  ),
                ],
              ),
            ),

            // 입력창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: '감정을 자유롭게 적어보세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('보내기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
