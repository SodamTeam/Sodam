// Sodam/lib/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ProfileService {
  static String get _baseUrl => Config.baseUrl;

  static Future<String> getProfile(String character) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/$character'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['personality'] ?? '';
      } else {
        print('프로필 가져오기 실패: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('프로필 가져오기 실패: $e');
      return '';
    }
  }
}
