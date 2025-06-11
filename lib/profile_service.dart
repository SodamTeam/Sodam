// Sodam/lib/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String _baseUrl = 'http://localhost:8002';  // profile-service의 기본 포트

  static Future<String> getProfile(String character) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$character'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prompt'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      print('프로필 가져오기 실패: $e');
      return '';
    }
  }
}
