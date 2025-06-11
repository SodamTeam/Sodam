import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';

class HarinChat extends StatefulWidget {
  final VoidCallback goBack;
  const HarinChat({super.key, required this.goBack});

  @override
  State<HarinChat> createState() => _HarinChatState();
}

class _HarinChatState extends State<HarinChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [
    {
      'sender': 'harin',
      'text': '안녕하세요, 저는 문학 소녀 하린이에요 🌸\n오늘은 어떤 이야기를 나눠볼까요?',
    }
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = ''; // 초기값을 빈 문자열로 설정

  final Map<String, String> modeLabels = {
    'novel-helper': '소설 작성 도우미',
    'literary-analysis': '문학 분석',
    'poetry-play': '시 쓰기 놀이',
    'book-recommendation': '독서 추천 & 기록',
    'default': '기본',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 프로필 로드 함수 호출
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('harin');
    setState(() {
      systemPrompt = profile;
    });
  }

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;
    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final request = http.Request('POST', Uri.parse('${Config.baseUrl}/api/chat/generate-stream'));  // API Gateway URL 사용
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': input,
        'mode': mode == 'book-recommendation' ? 'book' : mode,
        'stream': true,
        'system': systemPrompt,
        'character': 'harin',
        'name': '하린'
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
            if (messages.isNotEmpty && messages.last['sender'] == 'harin') {
              messages.last['text'] = fullResponse + chunk;
            } else {
              messages.add({'sender': 'harin', 'text': chunk});
            }
            fullResponse += chunk;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'harin', 'text': '죄송합니다. 오류가 발생했습니다.'});
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
  void _changeMode(String newMode) async {
  setState(() {
    mode = newMode;
    messages = [
      {
        'sender': 'harin',
        'text': '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
      }
    ];
    _isLoading = true;
  });

  String initialPrompt = '';
  if (newMode == 'novel-helper') {
    initialPrompt = '소설 작성을 도와줘!';
  } else if (newMode == 'literary-analysis') {
    initialPrompt = '문학 분석을 도와줘!';
  } else if (newMode == 'poetry-play') {
    initialPrompt = '시 쓰기 놀이를 하자!';
  } else if (newMode == 'book-recommendation') {
    // 🔽 여기를 아래처럼 수정하세요
    setState(() {
      messages.add({
        'sender': 'harin',
        'text': '독서추천입니다! 원하는 종류의 책을 적어주시면 책 추천을 해줍니다! 키워드로 검색해보세요!',
      });
      _isLoading = false;
    });
    _scrollToBottom();
    return;
  } else {
    initialPrompt = '';
    setState(() {
      _isLoading = false;
    });
    return;
  }

    try {
      final request = http.Request('POST', Uri.parse('${Config.baseUrl}/api/chat/generate-stream'));  // API Gateway URL 사용
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': initialPrompt,
        'mode': newMode == 'book-recommendation' ? 'book' : newMode,
        'stream': true,
        'system': systemPrompt,
        'character': 'harin',
        'name': '하린'
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
            if (messages.isNotEmpty && messages.last['sender'] == 'harin') {
              messages.last['text'] = fullResponse + chunk;
            } else {
              messages.add({'sender': 'harin', 'text': chunk});
            }
            fullResponse += chunk;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'harin', 'text': '죄송합니다. 오류가 발생했습니다.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.goBack,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Text(
                    '하린',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                      ),
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/women/44.jpg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 채팅 헤더
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/harin_chat.jpg'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '하린',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // 채팅 메시지 영역
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final msg = messages[idx];
                  final isHarin = msg['sender'] == 'harin';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: isHarin ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isHarin ? Colors.white : Colors.purple[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isHarin ? Colors.black87 : Colors.deepPurple,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
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
                    onPressed: _isLoading ? null : () => _changeMode('novel-helper'),
                    child: const Text('📝 소설 작성 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('literary-analysis'),
                    child: const Text('📘 문학 분석'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('poetry-play'),
                    child: const Text('📄 시 쓰기 놀이'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('book-recommendation'),
                    child: const Text('📚 독서 추천 & 기록'),
                  ),
                ],
              ),
            ),
            // 입력창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('전송'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.deepPurple),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.deepPurple)),
      ],
    );
  }
}
