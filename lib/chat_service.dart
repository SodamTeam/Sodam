// Sodam/lib/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;
  final String model;

  ChatService({
    this.baseUrl = 'http://10.0.2.2:8000/api/generate', // ← 이렇게 수정!
    this.model = 'gemma3:4b',
  });

  Future<String> generate(
    String prompt, {
    String? systemPrompt,
    String? mode,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      final body = {"model": model, "prompt": prompt, "stream": false};

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body["system"] = systemPrompt;
      }

      if (mode != null && mode.isNotEmpty) {
        body["mode"] = mode;
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
