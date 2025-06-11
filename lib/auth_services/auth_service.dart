// lib/screens/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  /// 실제 안드로이드 기기에서는 컴퓨터의 IP 주소를 사용
  /// 배포 시 --dart-define=BACKEND_URL=https://api.example.com 형태로 덮어쓸 수 있음.
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8003',  // API Gateway 포트로 수정
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// ────────────────────────── 저장된 액세스 토큰 얻기
  static Future<String?> get token => _storage.read(key: 'access_token');

  /// ────────────────────────── 로그인
  static Future<String?> login(String id, String pw) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': id,
          'password': pw,
          'grant_type': 'password',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        if (accessToken == null) {
          return '로그인 실패: 토큰이 응답에 없습니다.';
        }
        await _storage.write(key: 'access_token', value: accessToken);
        return null; // 성공
      }
      return '로그인 실패 [${response.statusCode}]';
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }

  /// ────────────────────────── 회원가입
  static Future<String?> signup(String id, String pw) async {
    try {
      print('회원가입 요청: username=$id, password=$pw');  // 디버깅용 로그
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': id,
          'password': pw,
        }),
      );

      print('회원가입 응답: ${response.statusCode} - ${response.body}');  // 디버깅용 로그

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // 성공
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = data['detail'] as String?;
      return '회원가입 실패: ${detail ?? '알 수 없는 오류'}';
    } catch (e) {
      print('회원가입 에러: $e');  // 디버깅용 로그
      return '네트워크 오류: $e';
    }
  }

  /// ────────────────────────── 로그인 상태 확인
  static Future<bool> isLoggedIn() async => (await token) != null;

  /// ────────────────────────── 로그아웃
  static Future<void> logout() async =>
      _storage.delete(key: 'access_token');
}
