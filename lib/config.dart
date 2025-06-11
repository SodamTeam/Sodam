import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class Config {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return 'https://910b-121-135-57-14.ngrok-free.app';  // ngrok URL (포트 제거)
    }
    return 'http://localhost:8000';
  }
} 