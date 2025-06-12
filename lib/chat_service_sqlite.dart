// Sodam/lib//db_service_sqite.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'chat.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate:
          (db, _) => db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sender TEXT NOT NULL,
          message TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      '''),
    );
  }

  Future<void> insertMessage(String sender, String text) async {
    await _db!.insert('chat_history', {'sender': sender, 'message': text});
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    return await _db!.query('chat_history', orderBy: 'id ASC');
  }
}
