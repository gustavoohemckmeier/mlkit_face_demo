
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

  Future<Map<String, List<double>>> getAllEmbeddings() async {
    final List<Map<String, dynamic>> maps = await _db!.query('face_embeddings');

    final Map<String, List<double>> allEmbeddings = {};

    for (var map in maps) {
      final String userId = map['user_id'];
      final List<double> embedding = (jsonDecode(map['embedding']) as List<dynamic>).cast<double>();

      allEmbeddings[userId] = embedding;
    }

    return allEmbeddings;
  }

  Future<Map<String, List<List<double>>>> getAllEmbeddingsGroupedByUser() async {
    final List<Map<String, dynamic>> maps = await _db!.query('face_embeddings');

    final Map<String, List<List<double>>> grouped = {};

    for (var map in maps) {
      final userId = map['user_id'] as String;
      final List<dynamic> jsonList = jsonDecode(map['embedding']);
      final embedding = jsonList.cast<double>();

      grouped.putIfAbsent(userId, () => []).add(embedding);
    }

    return grouped;
  }



  Future<void> close() async {
    await _db?.close();
  }
}