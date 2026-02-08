import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local database helper wrapping an instance of SQLite
class LocalDbHelper {
  static final LocalDbHelper instance = LocalDbHelper._init();
  static Database? _database;

  LocalDbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('app.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future _createDb(Database db, int version) async {
    /// Create tables
    const userTable = '''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''';
    await db.execute(userTable);

    /// Seed db
    const userSeed = {
      'id': 1,
      'username': 'admin@test.mail',
      'password': 'tatatata',
    };
    await db.insert('users', userSeed);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
