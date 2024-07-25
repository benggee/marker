
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentDir = await getApplicationDocumentsDirectory();
    String path = join(documentDir.path, 'object_list.db');
    Database db = sqlite3.open(
      path,
    );

    _createDatabase(db);

    return db;
  }

 void _createDatabase(Database db) {
    db.execute('''
      CREATE TABLE ObjectList (
        id INTEGER PRIMARY KEY,
        identify TEXT,
        text TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getItems(String query) async {
    Database db = await database;
    final ResultSet res = db.select(query);

    List<Map<String, dynamic>> items = [];
    for (final Row row in res) {
      items.add(row);
    }

    return items;
  }

  Future<void> insertItems(List<Map<String, dynamic>> rows, String table) async {
    Database db = await database;

    final colums = rows.first.keys.join(', ');
    final placeholders = rows.first.keys.map((_) => '?').join(", ");

    String sql = 'INSERT INTO $table ($colums) VALUES ($placeholders)';

    for (var item in rows) {
      db.execute(sql, [item.values.toList().join(', ')]);
    }
  }

  Future<void> deleteByField(String field, String value, String table) async {
    Database db = await database;
    db.execute('DELETE FROM $table WHERE $field = ?', [value]);
  }
}