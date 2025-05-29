// Sodam/lib/Yuri_chat.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'chat_service.dart';
import 'profile_service.dart';

class YuriChat extends StatefulWidget {
  final VoidCallback goBack;
  const YuriChat({Key? key, required this.goBack}) : super(key: key);

  @override
  _YuriChatState createState() => _YuriChatState();
}

class _YuriChatState extends State<YuriChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  final ChatService chatService = ChatService();

  Database? _db; // SQLite 데이터베이스
  List<Map<String, String>> messages = [
    {'sender': 'yuri', 'text': '안녕하세요, 저는 유리입니다 🌸\n오늘은 어떤 이야기를 나눠볼까요?'},
  ];

  bool _isLoading = false;
  final String systemPrompt = ProfileService.getProfile('yuri');

  @override
  void initState() {
    super.initState();
    _initializeChatHistory(); // SQLite 초기화 및 메시지 로드
  }

  // SQLite 데이터베이스 초기화 및 과거 메시지 불러오기
  Future<void> _initializeChatHistory() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final path = join(docsDir.path, 'chat.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE chat_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sender TEXT NOT NULL,
              message TEXT NOT NULL,
              created_at TEXT
            )
          ''');
        },
      );

      final List<Map<String, Object?>> results = await _db!.query(
        'chat_history',
        orderBy: 'id ASC',
      );
      final history =
          results
              .map(
                (row) => {
                  'sender': row['sender'] as String,
                  'text': row['message'] as String,
                },
              )
              .toList();
      if (history.isNotEmpty) {
        setState(() => messages = history);
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('SQLite init error: \$e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // 메시지 전송 및 SQLite 저장
  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;

    // 1) 사용자 메시지 UI 반영
    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    // 2) SQLite에 사용자 메시지 저장
    try {
      await _db?.insert('chat_history', {
        'sender': 'user',
        'message': input,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SQLite insert user error: \$e');
    }

    // 3) AI 서버 호출
    final reply = await chatService.generate(input, systemPrompt: systemPrompt);

    // 4) AI 응답 UI 반영
    setState(() {
      messages.add({'sender': 'yuri', 'text': reply});
      _isLoading = false;
    });
    _scrollToBottom();

    // 5) SQLite에 AI 응답 저장
    try {
      await _db?.insert('chat_history', {
        'sender': 'yuri',
        'message': reply,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SQLite insert yuri error: \$e');
    }
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isYuri = msg['sender'] == 'yuri';
    return Align(
      alignment: isYuri ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isYuri ? Colors.white : Colors.purple[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(
            color: isYuri ? Colors.black87 : Colors.deepPurple,
            fontSize: 15,
          ),
        ),
      ),
    );
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
                    children: const [
                      Icon(Icons.notifications),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage('assets/yuri_profile.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 프로필
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/yuri_profile.png'),
                  ),
                  SizedBox(width: 8),
                  Text(
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

            // 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: messages.length,
                itemBuilder: (_, idx) => _buildBubble(messages[idx]),
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
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Text('📝 소설 작성 도우미'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Text('📘 문학 분석'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Text('📄 시 쓰기 놀이'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
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
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: Scrollbar(
                        child: RawKeyboardListener(
                          focusNode: _textFieldFocus,
                          onKey: (e) {
                            if (e is RawKeyDownEvent &&
                                e.logicalKey == LogicalKeyboardKey.enter &&
                                !e.isShiftPressed &&
                                !_isLoading) {
                              _sendMessage();
                            }
                          },
                          child: TextField(
                            controller: _controller,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('전송'),
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
