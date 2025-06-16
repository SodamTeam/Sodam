import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DiaryEntry {
  final String id;
  final String date;
  final String mood;
  final String category;
  final String content;
  final String? imageUrl;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.category,
    required this.content,
    this.imageUrl,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'].toString(),
      date: json['date'],
      mood: json['mood'] ?? '',
      category: json['category'] ?? '',
      content: json['content'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'mood': mood,
        'category': category,
        'content': content,
        'imageUrl': imageUrl,
      };
}

class EmotionDiary extends StatefulWidget {
  final VoidCallback onGoBack;
  const EmotionDiary({Key? key, required this.onGoBack}) : super(key: key);

  @override
  _EmotionDiaryState createState() => _EmotionDiaryState();
}

class _EmotionDiaryState extends State<EmotionDiary> {
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  String? _editingId;

  final String baseUrl = 'http://localhost:8005/api/diary';
  

  List<DiaryEntry> entries = [];
  List<DiaryEntry> filtered = [];

  final List<String> moods = ['행복', '우울', '즐거움'];
  final List<String> categories = ['일상', '가족', '기념'];
  String? selectedMood;
  String? selectedCategory;
  
  String selectedFont = 'Roboto';
  double fontSize = 14;
  bool isUnderline = false;
  bool isBold = false;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null).then((_) {
      _loadEntries();
    });
  }

  Future<void> _loadEntries() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final parsed = data.map((e) => DiaryEntry.fromJson(e)).toList();
        setState(() {
          entries = parsed;
          filtered = List.from(parsed);
        });
      }
    } catch (e) {
      print('불러오기 오류: $e');
    }
  }


  Future<void> _saveEntry() async {
    final bool isEditing = _editingId != null;
  
    final newEntry = DiaryEntry(
      id: _editingId ?? '0',
      date: selectedDate,
      mood: selectedMood ?? '',
      category: selectedCategory ?? '',
      content: _contentController.text,
    );

    try {
      final res = await (isEditing
          ? http.put(
              Uri.parse('$baseUrl/${_editingId}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(newEntry.toJson()),
            )
          : http.post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(newEntry.toJson()),
            ));

      if (res.statusCode == 200) {
        if (isEditing) {
          final updated = DiaryEntry.fromJson(jsonDecode(res.body));
          setState(() {
            final index = entries.indexWhere((e) => e.id == updated.id);
            if (index != -1) entries[index] = updated;
            filtered = List.from(entries);
            _editingId = null;
          });
        } else {
          final saved = DiaryEntry.fromJson(jsonDecode(res.body));
          setState(() {
            entries.insert(0, saved);
            filtered = List.from(entries);
          });
        }

        _contentController.clear();

        await _loadEntries();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEditing ? '일기가 수정되었습니다!' : '일기가 저장되었습니다!'),
          ));
        }
      }
    } catch (e) {
      print(isEditing ? '수정 오류: $e' : '저장 오류: $e');
    }
  }

  Future<void> _deleteEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final res = await http.delete(Uri.parse('$baseUrl/$id'));
        if (res.statusCode == 200) {
          await _loadEntries();
          if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('일기가 삭제되었습니다!')),
            );
          }
        }
      } catch (e) {
        print('삭제 오류: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: widget.onGoBack,
        ),
        title: Text('📔 감정일기 작성', style: TextStyle(color: Colors.pink[600])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            ListTile(
              title: Text('날짜: ${DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(DateTime.parse(selectedDate))}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  locale: const Locale('ko', 'KR'),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked.toIso8601String().split('T')[0]);
                }
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '오늘의 감정'),
              value: selectedMood,
              items: moods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedMood = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '카테고리'),
              value: selectedCategory,
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedFont,
                  items: ['Roboto', 'NanumGothic'].map((font) => DropdownMenuItem(value: font, child: Text(font))).toList(),
                  onChanged: (val) => setState(() => selectedFont = val!),
                ),
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () => setState(() => isBold = !isBold),
                  color: isBold ? Colors.pink : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.format_underline),
                  onPressed: () => setState(() => isUnderline = !isUnderline),
                  color: isUnderline ? Colors.pink : Colors.grey,
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                final edited = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContentPage(initialText: _contentController.text),
                  ),
                );
                if (edited != null && edited is String) {
                  setState(() {
                    _contentController.text = edited;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                constraints: const BoxConstraints(minHeight: 80),
                child: Text(
                  _contentController.text.isEmpty ? '내용을 입력하세요...' : _contentController.text,
                  style: TextStyle(
                    fontFamily: selectedFont,
                    fontSize: fontSize,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    decoration: isUnderline ? TextDecoration.underline : null,
                    color: _contentController.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),

              ),
            ElevatedButton(onPressed: _saveEntry, child: const Text('저장하기'), style: ElevatedButton.styleFrom(backgroundColor: Colors.pink)),
            const Divider(),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('작성된 감정일기가 없습니다.')),
              )
            else
              ...filtered.map((e) => Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiaryDetailPage(entry: e),
                      ),
                    );
                  },
                  title: Text('${e.date} • ${e.mood} • ${e.category}'),
                  subtitle: Text(e.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),

                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDiaryPage(entry: e),
                            ),
                          );
                          if (updated == true) {
                            await _loadEntries(); // 수정 후 목록 새로고침
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEntry(e.id),
                      ),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class EditDiaryPage extends StatefulWidget { // 수정 기능 새페이지 이동
  final DiaryEntry entry;
  const EditDiaryPage({super.key, required this.entry});

  @override
  State<EditDiaryPage> createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.content);
  }

  Future<void> _save() async {
    final updated = DiaryEntry(
      id: widget.entry.id,
      date: widget.entry.date,
      mood: widget.entry.mood,
      category: widget.entry.category,
      content: _controller.text,
      imageUrl: widget.entry.imageUrl,
    );

    final res = await http.put(
      Uri.parse('http://localhost:8005/api/diary/${widget.entry.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated.toJson()),
    );

    if (res.statusCode == 200 && context.mounted) {
      Navigator.pop(context, true); // 이전 페이지로 이동하면서 true 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✏️ 일기 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('날짜: ${widget.entry.date} | 감정: ${widget.entry.mood} | 카테고리: ${widget.entry.category}'),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '일기 내용을 수정하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditContentPage extends StatefulWidget { // 내용 버튼 누르면 새페이지 이동
  final String initialText;
  const EditContentPage({super.key, required this.initialText});

  @override
  State<EditContentPage> createState() => _EditContentPageState();
}

class _EditContentPageState extends State<EditContentPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 일기 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '일기 내용을 입력하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('완료'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryDetailPage extends StatelessWidget {   //저장된 일기 전체 내용 보기
  final DiaryEntry entry;

  const DiaryDetailPage({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📖 일기 상세 보기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('날짜: ${entry.date}', style: const TextStyle(fontSize: 16)),
            Text('감정: ${entry.mood}', style: const TextStyle(fontSize: 16)),
            Text('카테고리: ${entry.category}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryWritePage extends StatefulWidget { // 내용+사진 입력페이지
  final String initialText;
  final XFile? initialImage;

  const DiaryWritePage({Key? key, this.initialText = '', this.initialImage}) : super(key: key);

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  late TextEditingController _controller;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _image = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 일기 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '일기 내용을 입력하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'text': _controller.text});
              },
              child: const Text('완료'),
            ),
          ],
        ),
      ),
    );
  }
}
