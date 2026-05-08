import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_dla.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0 for false, 1 for true

    await db.execute('''
CREATE TABLE users_local (
  id INTEGER PRIMARY KEY,
  cpf TEXT NOT NULL UNIQUE,
  nome TEXT NOT NULL,
  email TEXT,
  last_login TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE vistorias_local (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  local_id TEXT NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  data TEXT NOT NULL,
  synced INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users_local (id) ON DELETE CASCADE
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
