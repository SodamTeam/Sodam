import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'chat_service.dart';
import 'profile_service.dart';
import 'EmotionDiary.dart';
import 'MeditationContent.dart';
import 'Encouragement.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'dart:async';
import 'dart:io';
import 'config.dart';

class MinaChat extends StatefulWidget {
  final VoidCallback goBack;
  const MinaChat({super.key, required this.goBack, Map<String, dynamic>? preferences});

  @override
  State<MinaChat> createState() => _MinaChatState();
}

class _MinaChatState extends State<MinaChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final ChatService chatService = ChatService();
  final int userId = 3;  // 미나의 사용자 ID
  String mode = 'chat';  // 기본 모드를 'chat'으로 설정
  final String _baseUrl = '${Config.baseUrl}/api/chat/generate';

  List<Map<String, String>> messages = [
    {
      'sender': 'mina',
      'text': '안녕하세요, 저는 미나예요 🌸\n오늘 당신의 감정을 함께 나눠볼까요?',
    },
  ];
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
      final loaded = hist.map((e) => {
        'sender': e['sender'] as String,
        'text': e['content'] as String,
      }).toList();

      if (loaded.isNotEmpty) {
        setState(() {
          messages.addAll(loaded);
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('히스토리 로드 에러: $e');
    }
  }

  Future<String> _generateResponse(
    String input, {
    String? systemPrompt,
    String mode = 'chat',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma3:4b',
          'prompt': input,
          'mode': mode,
          'stream': false,
          'system': systemPrompt,
          'character': 'mina',
          'name': '미나',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to generate response');
      }
    } catch (e) {
      return '죄송합니다. 오류가 발생했습니다.';
    }
  }

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;
    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _controller.clear();
      _isLoading = true;
    });

    await chatService.saveHistory(userId, 'mina', 'user', input);

    // 이전 대화 내용을 포함한 프롬프트 생성
    String conversationHistory = '';
    for (var i = 0; i < messages.length - 1; i++) {
      final message = messages[i];
      if (message['sender'] == 'user') {
        conversationHistory += '사용자: ${message['text']}\n';
      } else {
        conversationHistory += '미나: ${message['text']}\n';
      }
    }
    conversationHistory += '사용자: $input';

    // 모드에 따라 prefix 추가
    String promptWithPrefix = conversationHistory;
    if (mode == 'novel-writing') {
      promptWithPrefix = '소설 작성을 도와줘!\n$conversationHistory';
    } else if (mode == 'storytelling') {
      promptWithPrefix = '이야기를 들려줘!\n$conversationHistory';
    } else if (mode == 'creative-writing') {
      promptWithPrefix = '창작을 도와줘!\n$conversationHistory';
    } else if (mode == 'plot-development') {
      promptWithPrefix = '플롯을 발전시켜줘!\n$conversationHistory';
    }

    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': promptWithPrefix,
        'mode': mode,
        'stream': true,
        'system': systemPrompt,
        'character': 'mina',
        'name': '미나',
      });

      final response = await request.send();
      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      String fullResponse = '';
      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6));
          final chunk = data['response'] as String;

          setState(() {
            if (messages.isNotEmpty && messages.last['sender'] == 'mina') {
              messages.last['text'] = fullResponse + chunk;
            } else {
              messages.add({'sender': 'mina', 'text': chunk});
            }
            fullResponse += chunk;
          });
          _scrollToBottom();
        }
      }
      setState(() {
        _isLoading = false;
      });
      // 스트리밍이 완료된 후 응답 저장
      await chatService.saveHistory(userId, 'mina', 'mina', fullResponse);
    } catch (e) {
      print('Error in _sendMessage: $e');
      setState(() {
        messages.add({
          'sender': 'mina',
          'text': '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 왼쪽 버튼
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: widget.goBack,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  // 가운데 텍스트
                  const Text(
                    '미나',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // ─── 헤더 2/2: 왼쪽 아바타 + 이름
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 수정: 세로 패딩 축소
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/girl3.png'), // 수정: 미나 사진
                  ),
                  const SizedBox(width: 4),                             // 수정: 가로 여백 축소
                  const Text(
                    '미나',                                              // 수정: 이름 추가
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,                                // 수정: 유리 화면과 동일한 색
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      decoration: const InputDecoration(
                        hintText: '감정을 자유롭게 적어보세요...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _sendMessage(),

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