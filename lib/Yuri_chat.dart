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
  const YuriChat({super.key, required this.goBack, Map<String, dynamic>? preferences});

  @override
  State<YuriChat> createState() => _YuriChatState();
}

class _YuriChatState extends State<YuriChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  final ChatService chatService = ChatService();
  final int userId = 2;

  List<Map<String, String>> messages = [
    {
      'sender': 'yuri',
      'text': '안녕하세요! 저는 과학 소녀 유리예요 🔬\n어떤 과학 현상에 대해 이야기해볼까요?',
    },
  ];

  String mode = 'default';
  bool _isLoading = false;
  String systemPrompt = '';

  final Map<String, String> modeLabels = {
    'science-explainer': '과학 설명',
    'experiment-helper': '실험 도우미',
    'nature-explorer': '자연 탐험',
    'science-news': '과학 뉴스',
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
      final hist = await chatService.fetchHistory(userId, 'yuri');
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
    final profile = await ProfileService.getProfile('yuri');
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

    await chatService.saveHistory(userId, 'yuri', 'user', input);

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

    String promptWithPrefix = conversationHistory;
    if (mode == 'book-recommendation') {
      promptWithPrefix = '책을 추천해줘!\n$conversationHistory';
    } else if (mode == 'reading-companion') {
      promptWithPrefix = '독서를 도와줘!\n$conversationHistory';
    } else if (mode == 'literary-discussion') {
      promptWithPrefix = '문학 토론을 해보자!\n$conversationHistory';
    } else if (mode == 'writing-assistant') {
      promptWithPrefix = '글쓰기를 도와줘!\n$conversationHistory';
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
        'character': 'yuri',
        'name': '유리',
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
            if (messages.isNotEmpty && messages.last['sender'] == 'yuri') {
              messages.last['text'] = fullResponse + chunk;
            } else {
              messages.add({'sender': 'yuri', 'text': chunk});
            }
            fullResponse += chunk;
          });
          _scrollToBottom();
        }
      }
      setState(() {
        _isLoading = false;
      });
      await chatService.saveHistory(userId, 'yuri', 'yuri', fullResponse);
    } catch (e) {
      print('Error in _sendMessage: $e');
      setState(() {
        messages.add({
          'sender': 'yuri',
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

  void _changeMode(String newMode) async {
    setState(() {
      mode = newMode;
      messages = [
        {
          'sender': 'yuri',
          'text': '현재 모드는 ${modeLabels[newMode] ?? newMode}입니다. 이 모드에 대해 이야기해볼까요?',
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
          'character': 'yuri',
          'name': '유리',
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
              if (messages.isNotEmpty && messages.last['sender'] == 'yuri') {
                messages.last['text'] = fullResponse + chunk;
              } else {
                messages.add({'sender': 'yuri', 'text': chunk});
              }
              fullResponse += chunk;
            });
            _scrollToBottom();
          }
        }
        await chatService.saveHistory(userId, 'yuri', 'yuri', fullResponse);
      } catch (e) {
        print('Error in _changeMode: $e');
        setState(() {
          messages.add({
            'sender': 'yuri',
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
                  IconButton(
                    onPressed: widget.goBack,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                  child: Center(
                  child: const Text(
                    '유리',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final msg = messages[idx];
                  final isYuri = msg['sender'] == 'yuri';
                  return Align(
                    alignment: isYuri ? Alignment.centerLeft : Alignment.centerRight,
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
                      child: Text(msg['text'] ?? ''),
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
            )
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
