import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  final _dateController = TextEditingController();
  final _moodController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  List<DiaryEntry> entries = [];
  List<DiaryEntry> filtered = [];

  final String baseUrl = 'http://192.168.0.16:8000/api/diary';
  final String imageUploadUrl = 'http://192.168.0.16:8000/api/diary/upload-image/';

  String selectedMonth = '';
  String selectedMood = '';
  String selectedCategory = '';
  String selectedFont = 'Roboto';
  double fontSize = 14;
  bool isUnderline = false;
  bool isBold = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
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

  Future<String?> _uploadImage(XFile image) async {
    final request = http.MultipartRequest('POST', Uri.parse(imageUploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final resString = await response.stream.bytesToString();
      final jsonRes = jsonDecode(resString);
      return jsonRes['image_url'];
    } else {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    String? uploadedImageUrl;
    if (_pickedImage != null) {
      uploadedImageUrl = await _uploadImage(_pickedImage!);
    }

    final newEntry = DiaryEntry(
      id: '0',
      date: _dateController.text,
      mood: _moodController.text,
      category: _categoryController.text,
      content: _contentController.text,
      imageUrl: uploadedImageUrl,
    );

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newEntry.toJson()),
      );

      if (res.statusCode == 200) {
        final saved = DiaryEntry.fromJson(jsonDecode(res.body));
        setState(() {
          entries.insert(0, saved);
          filtered = List.from(entries);
          _pickedImage = null;
        });
        _moodController.clear();
        _categoryController.clear();
        _contentController.clear();
      }
    } catch (e) {
      print('저장 오류: $e');
    }
  }

  void _filterBy(String key, String value) {
    setState(() {
      filtered = entries.where((e) {
        if (key == 'month') return e.date.startsWith(value);
        if (key == 'mood') return e.mood == value;
        return e.category == value;
      }).toList();
    });
  }

  Widget _outlinedImagePreview() {
    if (_pickedImage == null) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Image.file(File(_pickedImage!.path), height: 150),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: widget.onGoBack,
        ),
        title: Text('📔 감정일기 작성', style: TextStyle(color: Colors.pink[600])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: '날짜', border: OutlineInputBorder()),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  _dateController.text = picked.toIso8601String().split('T')[0];
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _moodController,
              decoration: InputDecoration(labelText: '오늘의 감정', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: '카테고리', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedFont,
                  items: ['Roboto', 'Arial', 'Nanum Gothic'].map((font) {
                    return DropdownMenuItem(value: font, child: Text(font));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedFont = value!),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.format_bold),
                  onPressed: () => setState(() => isBold = !isBold),
                  color: isBold ? Colors.pink : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.format_underline),
                  onPressed: () => setState(() => isUnderline = !isUnderline),
                  color: isUnderline ? Colors.pink : Colors.grey,
                ),
              ],
            ),
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: TextStyle(
                fontFamily: selectedFont,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                decoration: isUnderline ? TextDecoration.underline : null,
              ),
              decoration: InputDecoration(labelText: '내용', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            _outlinedImagePreview(),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('사진 선택'),
            ),
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: Text('저장하기'),
            ),
            Divider(height: 30),
            Text('🗂 일기 목록 필터', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: Text('4월'), selected: selectedMonth == '2025-04', onSelected: (selected) => setState(() => _filterBy('month', selected ? '2025-04' : ''))),
                FilterChip(label: Text('5월'), selected: selectedMonth == '2025-05', onSelected: (selected) => setState(() => _filterBy('month', selected ? '2025-05' : ''))),
                FilterChip(label: Text('행복'), selected: selectedMood == '행복', onSelected: (selected) => setState(() => _filterBy('mood', selected ? '행복' : ''))),
                FilterChip(label: Text('우울'), selected: selectedMood == '우울', onSelected: (selected) => setState(() => _filterBy('mood', selected ? '우울' : ''))),
                FilterChip(label: Text('가족'), selected: selectedCategory == '가족', onSelected: (selected) => setState(() => _filterBy('category', selected ? '가족' : ''))),
                FilterChip(label: Text('일'), selected: selectedCategory == '일', onSelected: (selected) => setState(() => _filterBy('category', selected ? '일' : ''))),
              ],
            ),
            SizedBox(height: 20),
            ...filtered.map((entry) => Card(
              child: ListTile(
                title: Text('${entry.date} • ${entry.mood} • ${entry.category}'),
                subtitle: Text(entry.content),
                trailing: entry.imageUrl != null ? Image.network(entry.imageUrl!, width: 60, fit: BoxFit.cover) : null,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
