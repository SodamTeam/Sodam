import 'package:flutter/material.dart';

class SeraChat extends StatefulWidget {
  final VoidCallback goBack;

  const SeraChat({super.key, required this.goBack});

  @override
  State<SeraChat> createState() => _SeraChatState();
}

class _SeraChatState extends State<SeraChat> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': '세라',
      'type': 'intro',
      'text': '안녕하세요!\n전 세라라고 해요.',
      'image': 'assets/girl2.png',
    },
  ];

  final TextEditingController _textController = TextEditingController();

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': '나',
        'text': _textController.text,
      });
      _textController.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add({
          'sender': '세라',
          'text': 'example response',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 네비게이션
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
                  '캐릭터 챗',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications),
                    ),
                    const CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 채팅 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._messages.map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: msg['sender'] == '세라'
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg['sender'] == '세라') ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundImage: AssetImage('assets/girl2_icon.png'),
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
                              const SizedBox(height: 4),
                              _buildBubble(msg, isSera: true),
                            ],
                          ),
                        ] else ...[
                          _buildBubble(msg, isSera: false),
                        ],
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),

          // 선택지 버튼
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                "앱/웹 아이디어",
                "IT 용어 쉽게 풀기",
                "유용한 앱 소개",
                "코딩 놀이",
              ].map((text) => ElevatedButton(
                onPressed: () {
                  setState(() {
                    _messages.add({
                      'sender': '나',
                      'text': text,
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(text),
              )).toList(),
            ),
          ),

          // 입력창
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '대화 시작하기',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('보내기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, {required bool isSera}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 250,
      ),
      decoration: BoxDecoration(
        color: isSera ? Colors.grey[100] : Colors.purple[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: msg['type'] == 'intro' && msg['image'] != null
          ? Column(
              children: [
                Text(msg['text'].split('\n')[0]),
                const SizedBox(height: 8),
                Image.asset(
                  msg['image'],
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 8),
                Text(msg['text'].split('\n')[1]),
              ],
            )
          : Text(msg['text']),
    );
  }
} 