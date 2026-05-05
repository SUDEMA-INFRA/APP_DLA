import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_dla.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Exemplo: Criando uma tabela de Dados Auxiliares
    await db.execute('''
      CREATE TABLE funcionarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER NULL,
        nome TEXT NOT NULL,
        matricula TEXT NOT NULL,
        funcao TEXT NOT NULL,
        status TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  // Função para salvar no banco local
  Future<void> insertVistoria(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('vistorias', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
