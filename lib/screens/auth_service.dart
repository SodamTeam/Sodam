import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  /// 실제 안드로이드 기기에서는 컴퓨터의 IP 주소를 사용
  /// 배포 시 --dart-define=BACKEND_URL=https://api.example.com 형태로 덮어쓸 수 있음.
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://192.168.46.163:8003',  // 실제 안드로이드 기기용 IP
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 저장된 액세스 토큰을 직접 얻어야 할 때 사용
  static Future<String?> get token => _storage.read(key: 'access_token');

  /// ───────────────────────────────── 로그인
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
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
        return null; // success
      }
      return '로그인 실패 [${response.statusCode}]';
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }

  /// ───────────────────────────────── 회원가입
  static Future<String?> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // success
      }
      final detail =
          (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
      return '회원가입 실패: $detail';
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }

  /// ───────────────────────────────── 로그인 상태 확인
  static Future<bool> isLoggedIn() async => (await token) != null;

  /// ───────────────────────────────── 로그아웃
  static Future<void> logout() async =>
      _storage.delete(key: 'access_token');
} 