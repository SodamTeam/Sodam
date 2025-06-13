import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'chat_service.dart';

class HarinChat extends StatefulWidget {
  final VoidCallback goBack;
  const HarinChat({super.key, required this.goBack});

  @override
  State<HarinChat> createState() => _HarinChatState();
}

class _HarinChatState extends State<HarinChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int userId = 1;
  final ChatService chatService = ChatService();

  List<Map<String, String>> messages = [
    {'sender': 'harin', 'text': '안녕하세요, 저는 문학 소녀 하린이에요 🌸\n오늘은 어떤 이야기를 나눠볼까요?'},
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';

  final Map<String, String> modeLabels = {
    'novel-helper': '소설 작성 도우미',
    'literary-analysis': '문학 분석',
    'poetry-play': '시 쓰기 놀이',
    'book-recommendation': '독서 추천 & 기록',
    'default': '기본',
  };

  String get _baseUrl => '${Config.baseUrl}/api/chat/generate';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final hist = await chatService.fetchHistory(userId, 'harin');
      final loaded = hist
          .map((e) => {'sender': e['sender'] as String, 'text': e['content'] as String})
          .toList();

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

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('harin');
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
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma3:4b',
          'prompt': input,
          'mode': mode,
          'stream': false,
          'system': systemPrompt,
          'character': 'harin',
          'name': '하린',
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

    await chatService.saveHistory(userId, 'harin', 'user', input);

    String conversationHistory = '';
    for (var i = 0; i < messages.length - 1; i++) {
      final message = messages[i];
      if (message['sender'] == 'user') {
        conversationHistory += '사용자: ${message['text']}\n';
      } else {
        conversationHistory += '하린: ${message['text']}\n';
      }
    }
    conversationHistory += '사용자: $input';

    String promptWithPrefix = conversationHistory;
    if (mode == 'novel-helper') {
      promptWithPrefix = '소설 작성을 도와줘!\n$conversationHistory';
    } else if (mode == 'literary-analysis') {
      promptWithPrefix = '문학 작품을 분석해줘!\n$conversationHistory';
    } else if (mode == 'poetry-play') {
      promptWithPrefix = '시를 함께 써보자!\n$conversationHistory';
    }

    if (mode != 'chat') {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': promptWithPrefix,
        'mode': mode,
        'stream': true,
        'system': systemPrompt,
        'character': 'harin',
        'name': '하린',
      });

      final response = await request.send();
      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

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

      setState(() {
        _isLoading = false;
      });

      await chatService.saveHistory(userId, 'harin', 'harin', fullResponse);
      return;
    }

    final reply = await _generateResponse(
      promptWithPrefix,
      systemPrompt: systemPrompt,
      mode: mode,
    );

    setState(() {
      messages.add({'sender': 'harin', 'text': reply});
      _isLoading = false;
    });
    _scrollToBottom();

    await chatService.saveHistory(userId, 'harin', 'harin', reply);
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
        },
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
      setState(() {
        messages.add({
          'sender': 'harin',
          'text': '어떤 종류의 책을 찾고 계신가요? 제목, 저자, 주제 등 키워드를 입력해주세요!',
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    } else {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'gemma3:4b',
        'prompt': initialPrompt,
        'mode': newMode,
        'stream': true,
        'system': systemPrompt,
        'character': 'harin',
        'name': '하린',
      });

      final response = await request.send();
      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

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
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.goBack,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '하린',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 채팅 헤더
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/harin_chat.jpg'),
                  ),
                  SizedBox(width: 8),
                  Text(
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
}


  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.deepPurple),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.deepPurple),
        ),
      ],
    );
  }