import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'chat_service.dart';
import 'profile_service.dart';
import 'EmotionDiary.dart';
import 'MeditationContent.dart';
import 'Encouragement.dart';
import 'config.dart';

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
  final int userId = 3;

  List<Map<String, String>> messages = [
    {
      'sender': 'mina',
      'text': '안녕하세요, 저는 미나예요 🌸\n오늘 당신의 감정을 함께 나눠볼까요?',
    },
  ];

  bool _isLoading = false;
  String systemPrompt = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadHistory();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('mina');
    setState(() {
      systemPrompt = profile;
    });
  }

  Future<void> _loadHistory() async {
    try {
      final hist = await chatService.fetchHistory(userId, 'mina');
      final List<Map<String, String>> loaded = hist
          .map((e) => {
                'sender': e['sender'].toString(),
                'text': e['content'].toString(),
              })
          .toList();
      setState(() {
        messages = [
          {
            'sender': 'mina',
            'text': '안녕하세요, 저는 미나예요 🌸\n오늘 당신의 감정을 함께 나눠볼까요?',
          },
          ...loaded,
        ];
      });
    } catch (e) {
      print('히스토리 로드 에러: \$e');
    }
  }

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;

    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    await chatService.saveHistory(userId, 'mina', 'user', input);

    final apiUrl = Uri.parse('${Config.baseUrl}/api/chat/generate');
    String history = '';
    for (var i = 0; i < messages.length - 1; i++) {
      final m = messages[i];
      history += (m['sender'] == 'user' ? '사용자: ' : '미나: ') + m['text']! + '\n';
    }
    history += '사용자: \$input';

    final request = http.Request('POST', apiUrl)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': history,
        'mode': 'chat',
        'stream': true,
        'system': systemPrompt,
        'character': 'mina',
        'name': '미나',
      });

    try {
      final response = await request.send();
      if (response.statusCode != 200) {
        final err = await response.stream.bytesToString();
        throw Exception('서버 오류: \${response.statusCode} - \$err');
      }
      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());
      String full = '';
      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6));
          final chunk = data['response'] as String?;
          if (chunk != null) {
            full += chunk;
            setState(() {
              if (messages.isNotEmpty && messages.last['sender'] == 'mina') {
                messages.last['text'] = full;
              } else {
                messages.add({'sender': 'mina', 'text': full});
              }
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      print('오류: \$e');
      setState(() {
        messages.add({'sender': 'mina', 'text': '죄송합니다. 오류가 발생했어요.'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 24, color: Colors.pink), Text(label, style: const TextStyle(fontSize: 12, color: Colors.pink))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f4fa),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: widget.goBack, icon: const Icon(Icons.chevron_left)),
                  const Text('미나', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/girl3.png')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/girl3.png')),
                  SizedBox(width: 8),
                  Text('미나', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isMina = msg['sender'] == 'mina';
                  return Align(
                    alignment: isMina ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMina ? Colors.white : Colors.pink[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(msg['text']!, style: TextStyle(color: isMina ? Colors.black87 : Colors.pink[900], fontSize: 15)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmotionDiary(onGoBack: () => Navigator.pop(context)))), child: const Text('감정일기 작성')),
                  ElevatedButton(onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationContent(onGoBack: () => Navigator.pop(context)))), child: const Text('명상 & 릴렉스 콘텐츠')),
                  ElevatedButton(onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => EncouragementGenerator(onGoBack: () => Navigator.pop(context)))), child: const Text('응원 메시지 생성')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: '감정을 자유롭게 적어보세요...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('보내기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, '홈'),
              _navItem(Icons.smart_toy, 'AI'),
              _navItem(Icons.search, '탐색'),
              _navItem(Icons.settings, '설정'),
              _navItem(Icons.person, '나'),
            ],
          ),
        ),
      ),
    );
  }
}
