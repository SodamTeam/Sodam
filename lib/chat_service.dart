// Sodam/lib/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;
  final String model;

  ChatService({
    this.baseUrl = 'http://localhost:8000',  // chat-service의 기본 포트
    this.model = 'gemma3:4b',
  });

  Future<String> generate(String prompt, {String? systemPrompt}) async {
    try {
      final url = Uri.parse('$baseUrl/generate');
      final body = {
        "model": model,
        "prompt": prompt,
        "stream": false,
        "mode": "chat"  // 기본 모드 추가
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
}
