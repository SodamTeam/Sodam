// Sodam/lib/Yuri_chat.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'chat_service.dart';
import 'profile_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

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
      'text': '안녕하세요! 저는 과학 소녀 유리예요 🔬\n어떤 과학 현상에 대해 이야기해볼까요?',
    }
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';  // 초기값을 빈 문자열로 설정

  final Map<String, String> modeLabels = {
    'science-explainer': '과학 설명',
    'experiment-helper': '실험 도우미',
    'nature-explorer': '자연 탐험',
    'science-news': '과학 뉴스',
    'default': '기본',
  };

  String get _baseUrl => 'http://localhost:8000/generate';  // chat-service의 새로운 URL로 수정

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

  Future<String> _generateResponse(String input, {String? systemPrompt, String mode = 'chat'}) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma3:4b',
          'prompt': input,
          'mode': mode,
          'stream': false,
          'system': systemPrompt,
          'character': 'yuri',
          'name': '유리'
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
      _isLoading = true;
    });

    try {
      final String apiUrl = '${Config.baseUrl}/api/chat/generate';

      // 이전 대화 내용을 포함한 프롬프트 생성
      String conversationHistory = '';
      for (var i = 0; i < messages.length - 1; i++) {
        final message = messages[i];
        if (message['sender'] == 'user') {
          conversationHistory += '사용자: ${message['text']}\n';
        } else {
          conversationHistory += '유리: ${message['text']}\n';
        }
      }
      conversationHistory += '사용자: $input';

      // 모드에 따라 prefix 추가
      String promptWithPrefix = conversationHistory;
      if (mode == 'science-explainer') {
        promptWithPrefix = '과학 현상을 설명해줘!\n$conversationHistory';
      } else if (mode == 'experiment-helper') {
        promptWithPrefix = '실험을 도와줘!\n$conversationHistory';
      } else if (mode == 'nature-explorer') {
        promptWithPrefix = '자연 현상을 탐험해보자!\n$conversationHistory';
      } else if (mode == 'science-news') {
        promptWithPrefix = '최신 과학 뉴스를 알려줘!\n$conversationHistory';
      }

      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': promptWithPrefix,
        'mode': mode,
        'stream': true,
        'system': systemPrompt,
        'character': 'yuri',
        'name': '유리'
      });

      final response = await request.send();
      
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        print('Server Error Body: $errorBody');
        throw Exception('서버 오류: ${response.statusCode} - $errorBody');
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      String fullResponse = '';
      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          try {
            final data = jsonDecode(line.substring(6));
            if (data['response'] != null) {
              final chunk = data['response'] as String;
              fullResponse += chunk;
              setState(() {
                if (messages.isNotEmpty && messages.last['sender'] == 'yuri') {
                  messages.last['text'] = fullResponse;
                } else {
                  messages.add({'sender': 'yuri', 'text': fullResponse});
                }
              });
              _scrollToBottom();
            }
          } catch (e) {
            print('Error parsing JSON for streaming: $e - Line: $line');
          }
        }
      }
    } catch (e) {
      print('Error in _sendMessage: $e');
      setState(() {
        messages.add({'sender': 'yuri', 'text': '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.'});
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
          'sender': 'yuri',
          'text': '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
        }
      ];
    });

    String initialPrompt = '';
    if (newMode == 'science-explainer') {
      initialPrompt = '과학 현상을 설명해줘!';
    } else if (newMode == 'experiment-helper') {
      initialPrompt = '실험을 도와줘!';
    } else if (newMode == 'nature-explorer') {
      initialPrompt = '자연 현상을 탐험해보자!';
    } else if (newMode == 'science-news') {
      initialPrompt = '최신 과학 뉴스를 알려줘!';
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
                    onPressed: _isLoading ? null : () => _changeMode('science-explainer'),
                    child: const Text('🔬 과학 설명'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('experiment-helper'),
                    child: const Text('🧪 실험 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('nature-explorer'),
                    child: const Text('🌱 자연 탐험'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('science-news'),
                    child: const Text('📰 과학 뉴스'),
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
