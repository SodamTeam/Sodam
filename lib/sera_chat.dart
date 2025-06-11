// Sodam/lib/sera_chart.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';
import 'package:flutter/foundation.dart';

class SeraChat extends StatefulWidget {
  final VoidCallback goBack;

  const SeraChat({super.key, required this.goBack});

  @override
  State<SeraChat> createState() => _SeraChatState();
}

class _SeraChatState extends State<SeraChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [
    {
      'sender': 'sera',
      'text': '안녕하세요! 저는 테크 소녀 세라예요 💻\n어떤 기술에 대해 이야기해볼까요?',
    }
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';  // 초기값을 빈 문자열로 설정

  final Map<String, String> modeLabels = {
    'coding-helper': '코딩 도우미',
    'tech-explainer': '기술 설명',
    'debug-assistant': '디버깅 도우미',
    'learning-path': '학습 로드맵',
    'default': '기본',
  };

  String get _baseUrl => 'http://localhost:8003/api/chat/generate';  // gateway URL로 수정

  @override
  void initState() {
    super.initState();
    _loadProfile();  // 프로필 로드 함수 호출
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('sera');
    setState(() {
      systemPrompt = profile;
    });
  }

  Future<String> _generateResponse(String prompt, {String? systemPrompt, String? mode}) async {
    try {
      final url = Uri.parse(_baseUrl);
      final body = {
        "model": "gemma3:4b",
        "prompt": prompt,
        "stream": false,
      };

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body["system"] = systemPrompt;
      }

      if (mode != null && mode.isNotEmpty) {
        body["mode"] = mode;
      }

      print('Sending request to: $url');
      print('Request body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("LLM 응답 원본: $data");
        return data['response'] ?? '응답을 이해하지 못했어요.';
      } else {
        return 'AI 서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      print('Error occurred: $e');
      return 'AI 연결 실패: $e';
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

    final reply = await _generateResponse(
      input,
      systemPrompt: systemPrompt,
      mode: mode,
    );

    setState(() {
      messages.add({'sender': 'sera', 'text': reply});
      _isLoading = false;
    });
    _scrollToBottom();
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
          'sender': 'sera',
          'text': '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
        }
      ];
    });

    String initialPrompt = '';
    if (newMode == 'coding-helper') {
      initialPrompt = '코딩을 도와줘!';
    } else if (newMode == 'tech-explainer') {
      initialPrompt = '기술을 설명해줘!';
    } else if (newMode == 'debug-assistant') {
      initialPrompt = '디버깅을 도와줘!';
    } else if (newMode == 'learning-path') {
      initialPrompt = '학습 로드맵을 만들어줘!';
    } else {
      initialPrompt = '';
    }

    if (initialPrompt.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final reply = await _generateResponse(
        initialPrompt,
        systemPrompt: systemPrompt,
        mode: newMode,
      );

      setState(() {
        messages.add({'sender': 'sera', 'text': reply});
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f8fa),
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
                    '세라',
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
                    backgroundImage: AssetImage('assets/sera_chat.jpg'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '세라',
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
                  final isSera = msg['sender'] == 'sera';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: isSera ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSera ? Colors.white : Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isSera ? Colors.black87 : Colors.blue[900],
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
                    onPressed: _isLoading ? null : () => _changeMode('coding-helper'),
                    child: const Text('💻 코딩 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('tech-explainer'),
                    child: const Text('🔧 기술 설명'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('debug-assistant'),
                    child: const Text('🐛 디버깅 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('learning-path'),
                    child: const Text('📚 학습 로드맵'),
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
                      backgroundColor: Colors.blue,
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
            // 하단 네비게이션
            Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.blue)),
      ],
    );
  }
}
