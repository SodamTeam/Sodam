// Sodam/lib/Yuri_chat.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'chat_service.dart';
import 'profile_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class YuriChat extends StatefulWidget {
  final VoidCallback goBack;
  const YuriChat({super.key, required this.goBack});

  @override
  State<YuriChat> createState() => _YuriChatState();
}

class _YuriChatState extends State<YuriChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  final ChatService chatService = ChatService();

  List<Map<String, String>> messages = [
    {
      'sender': 'yuri',
      'text': '안녕하세요! 저는 예술가 유리예요 🎨\n어떤 예술에 대해 이야기해볼까요?',
    }
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';  // 초기값을 빈 문자열로 설정

  final Map<String, String> modeLabels = {
    'art-critic': '예술 비평',
    'art-history': '예술사',
    'art-technique': '기법 설명',
    'art-inspiration': '영감 찾기',
    'default': '기본',
  };

  String get _baseUrl => 'http://localhost:8003/api/chat/generate';  // gateway URL로 수정

  @override
  void initState() {
    super.initState();
    _loadProfile();  // 프로필 로드 함수 호출
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('yuri');
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
      messages.add({'sender': 'yuri', 'text': reply});
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
          'sender': 'yuri',
          'text': '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
        }
      ];
    });

    String initialPrompt = '';
    if (newMode == 'art-critic') {
      initialPrompt = '예술 작품을 비평해줘!';
    } else if (newMode == 'art-history') {
      initialPrompt = '예술사에 대해 설명해줘!';
    } else if (newMode == 'art-technique') {
      initialPrompt = '예술 기법을 설명해줘!';
    } else if (newMode == 'art-inspiration') {
      initialPrompt = '예술적 영감을 찾아줘!';
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
        messages.add({'sender': 'yuri', 'text': reply});
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
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
                    '유리',
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
                          'https://randomuser.me/api/portraits/women/45.jpg',
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
                    backgroundImage: AssetImage('assets/yuri_chat.jpg'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '유리',
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
                  final isYuri = msg['sender'] == 'yuri';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: isYuri ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isYuri ? Colors.white : Colors.purple[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isYuri ? Colors.black87 : Colors.purple[900],
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
                    onPressed: _isLoading ? null : () => _changeMode('art-critic'),
                    child: const Text('🎨 예술 비평'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('art-history'),
                    child: const Text('📚 예술사'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('art-technique'),
                    child: const Text('🖌️ 기법 설명'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('art-inspiration'),
                    child: const Text('✨ 영감 찾기'),
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
        Icon(icon, size: 24, color: Colors.purple),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.purple)),
      ],
    );
  }
}
