// Sodam/lib/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ChatService {
  final String baseUrl;
  final String model;

  ChatService({String? baseUrl, this.model = 'gemma3:4b'})
    : baseUrl = baseUrl ?? Config.baseUrl;

  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return 'https://9b0b-121-135-57-14.ngrok-free.app'; // ngrok URL
    }
    return 'http://localhost:8000';
  }

  Future<String> generate(String prompt, {String? systemPrompt}) async {
    try {
      final url = Uri.parse('$baseUrl/generate');
      final body = {
        "model": model,
        "prompt": prompt,
        "stream": false,
        "mode": "chat", // 기본 모드 추가
      };
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body["system"] = systemPrompt;
      }
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '응답을 이해하지 못했어요.';
      } else {
        return 'AI 서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      return 'AI 연결 실패: $e';
    }
  }

  Future<void> saveHistory(
    int userId,
    String room,
    String sender,
    String content,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/history');
    final body = {
      'user_id': userId,
      'room': room,
      'sender': sender,
      'content': content,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('히스토리 저장 실패: ${res.statusCode}');
    }
  }

  /// chat-history-service 에서 과거 대화 불러오기
  Future<List<Map<String, dynamic>>> fetchHistory(
    int userId,
    String room,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/history/$userId/$room');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    throw Exception('히스토리 불러오기 실패: ${res.statusCode}');
  }
}
