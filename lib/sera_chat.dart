import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'chat_service.dart';
import 'chat_service.dart';

class SeraChat extends StatefulWidget {
  final VoidCallback goBack;
  const SeraChat({super.key, required this.goBack, Map<String, dynamic>? preferences});

  @override
  State<SeraChat> createState() => _SeraChatState();
}

class _SeraChatState extends State<SeraChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int userId = 1;
  final ChatService chatService = ChatService();

  List<Map<String, String>> messages = [
    {'sender': 'sera', 'text': '안녕하세요, 저는 기술 챗봇 세라에요 🤖\n무엇을 도와드릴까요?'},
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';

  final Map<String, String> modeLabels = {
    'code-helper': '코딩 도우미',
    'tech-explainer': '기술 설명',
    'debugging': '디버깅 도우미',
    'learning-roadmap': '학습 로드맵 추천',
    'default': '기본',
  };

  String get _baseUrl => '${Config.baseUrl}/api/chat/generate';
  String get _baseUrl => '${Config.baseUrl}/api/chat/generate';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadProfile();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final hist = await chatService.fetchHistory(userId, 'sera');
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

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile('sera');
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

    await chatService.saveHistory(userId, 'sera', 'user', input);

    // 이전 대화 내용을 포함한 프롬프트 생성
    String conversationHistory = '';
    for (var i = 0; i < messages.length - 1; i++) {
      final message = messages[i];
      if (message['sender'] == 'user') {
        conversationHistory += '사용자: ${message['text']}\n';
      } else {
        conversationHistory += '세라: ${message['text']}\n';
      }
    }
    conversationHistory += '사용자: $input';

    // 모드에 따라 prefix 추가
    String promptWithPrefix = conversationHistory;
    if (mode == 'coding-helper') {
      promptWithPrefix = '코딩을 도와줘!\n$conversationHistory';
    } else if (mode == 'tech-explainer') {
      promptWithPrefix = '기술을 설명해줘!\n$conversationHistory';
    } else if (mode == 'debug-assistant') {
      promptWithPrefix = '디버깅을 도와줘!\n$conversationHistory';
    } else if (mode == 'learning-path') {
      promptWithPrefix = '학습 로드맵을 만들어줘!\n$conversationHistory';
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
        'character': 'sera',
        'name': '세라',
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
            if (messages.isNotEmpty && messages.last['sender'] == 'sera') {
              messages.last['text'] = fullResponse + chunk;
            } else {
              messages.add({'sender': 'sera', 'text': chunk});
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
      await chatService.saveHistory(userId, 'sera', 'sera', fullResponse);
    } catch (e) {
      setState(() {
        messages.add({'sender': 'sera', 'text': '죄송합니다. 오류가 발생했습니다.'});
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

  void _changeMode(String newMode) async {
    setState(() {
      mode = newMode;
      messages = [
        {
          'sender': 'sera',
          'text':
              '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
        },
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

      try {
        final request = http.Request('POST', Uri.parse(_baseUrl));
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode({
          'model': 'gemma3:4b',
          'prompt': initialPrompt,
          'mode': newMode,
          'stream': true,
          'system': systemPrompt,
          'character': 'sera',
          'name': '세라',
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
              if (messages.isNotEmpty && messages.last['sender'] == 'sera') {
                messages.last['text'] = fullResponse + chunk;
              } else {
                messages.add({'sender': 'sera', 'text': chunk});
              }
              fullResponse += chunk;
            });
            _scrollToBottom();
          }
        }
        await chatService.saveHistory(userId, 'sera', 'sera', fullResponse);
      } catch (e) {
        print('Error in _changeMode: $e');
        setState(() {
          messages.add({
            'sender': 'sera',
            'text': '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
          });
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      backgroundColor: const Color(0xfff0f4f8),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
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
                    '세라',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/65.jpg'),
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
                children: const [
                  CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/sera_chat.jpg')),
                  SizedBox(width: 8),
                  Text(
                    '세라',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // 채팅 메시지 영역
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final msg = messages[idx];
                  final isSera = msg['sender'] == 'sera';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment:
                        isSera ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSera ? Colors.white : Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isSera ? Colors.black87 : Colors.indigo,
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
                    onPressed: _isLoading ? null : () => _changeMode('code-helper'),
                    child: const Text('👩‍💻 코딩 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('tech-explainer'),
                    child: const Text('📘 기술 설명'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('debugging'),
                    child: const Text('🛠️ 디버깅'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _changeMode('learning-roadmap'),
                    child: const Text('📚 학습 로드맵'),
                  ),
                ],
              ),
            ),
            // 입력창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
