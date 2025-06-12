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
  final int userId = 1;

  List<Map<String, String>> messages = [
    {
      'sender': 'yuri',
      'text': '안녕하세요! 저는 과학 소녀 유리예요 🔬\n어떤 과학 현상에 대해 이야기해볼까요?',
    },
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = ''; // 초기값을 빈 문자열로 설정

  final Map<String, String> modeLabels = {
    'science-explainer': '과학 설명',
    'experiment-helper': '실험 도우미',
    'nature-explorer': '자연 탐험',
    'science-news': '과학 뉴스',
    'default': '기본',
  };

  String get _baseUrl =>
      'http://localhost:8000/generate'; // chat-service의 새로운 URL로 수정

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 프로필 로드 함수 호출
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final hist = await chatService.fetchHistory(userId, 'yuri');
      // 서버 히스토리를 Map 형태로 변환
      final List<Map<String, String>> loaded =
          hist
              .map(
                (e) => {
                  'sender': e['sender'] as String,
                  'text': e['content'] as String,
                },
              )
              .toList();

      setState(() {
        // 항상 인사말을 첫 번째로 두고, 그 뒤에 서버 히스토리를 붙인다
        messages = [
          {
            'sender': 'yuri',
            'text': '안녕하세요! 저는 과학 소녀 유리예요 🔬\n어떤 과학 현상에 대해 이야기해볼까요?',
          },
          ...loaded,
        ];
      });
    } catch (e) {
      print('히스토리 로드 에러: $e');
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('yuri');
    setState(() {
      systemPrompt = profile;
    });
  }

  Future<String> _generateResponse(
    String input, {
    String? systemPrompt,
    String mode = 'chat',
  }) async {
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
          'name': '유리',
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

    // ◆ 사용자 메시지 삽입 ◆
    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    await chatService.saveHistory(userId, 'yuri', 'user', input);

    // ③ AI 응답
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

    await chatService.saveHistory(userId, 'yuri', 'yuri', reply);
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
          'text':
              '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
        },
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
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 부분 전체를 이 코드로 교체하세요.
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
                    '유리',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('대화 내역'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    height: 300,
                                    child: ListView.builder(
                                      itemCount: messages.length,
                                      itemBuilder: (context, idx) {
                                        final msg = messages[idx];
                                        if (msg['sender'] == 'timestamp') {
                                          return Center(
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Text(msg['text']!),
                                            ),
                                          );
                                        }
                                        final isYuri = msg['sender'] == 'yuri';
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          alignment:
                                              isYuri
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isYuri
                                                      ? Colors.white
                                                      : Colors.purple[100],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              msg['text']!,
                                              style: TextStyle(
                                                color:
                                                    isYuri
                                                        ? Colors.black87
                                                        : Colors.purple[900],
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('닫기'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        padding: const EdgeInsets.only(right: 8.0),
                        iconSize: 32,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        padding: const EdgeInsets.only(right: 8.0),
                        iconSize: 32,
                        icon: const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/women/45.jpg',
                          ),
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
                    backgroundImage: AssetImage('/yuri_chat.jpg'),
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
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final msg = messages[idx];
                  final isYuri = msg['sender'] == 'yuri';
                  return Align(
                    alignment:
                        isYuri ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isYuri ? Colors.grey[200] : Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text']!),
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
                    onPressed:
                        _isLoading
                            ? null
                            : () => _changeMode('science-explainer'),
                    child: const Text('🔬 과학 설명'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _changeMode('experiment-helper'),
                    child: const Text('🧪 실험 도우미'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _changeMode('nature-explorer'),
                    child: const Text('🌱 자연 탐험'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _changeMode('science-news'),
                    child: const Text('📰 과학 뉴스'),
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
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
