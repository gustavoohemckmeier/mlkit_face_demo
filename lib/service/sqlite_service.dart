
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'face_embeddings.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE face_embeddings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            image_path TEXT,
            embedding TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertEmbedding({
    required String userId,
    required String imagePath,
    required List<double> embedding,
  }) async {
    await _db?.insert('face_embeddings', {
      'user_id': userId,
      'image_path': imagePath,
      'embedding': jsonEncode(embedding),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<List<double>>> getAllEmbeddingsForUser(String userId) async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      'face_embeddings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map<List<double>>((map) {
      final List<dynamic> jsonList = jsonDecode(map['embedding']);
      return jsonList.cast<double>();
    }).toList();
  }

  Future<void> close() async {
    await _db?.close();
  }
}