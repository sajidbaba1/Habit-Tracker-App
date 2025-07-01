import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('habits.db');
      return _database!;
    } catch (e) {
      rethrow;
    }
  }

  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        streak INTEGER NOT NULL DEFAULT 0,
        completion_log TEXT NOT NULL DEFAULT '[]',
        checklistEnabled INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await db.execute('ALTER TABLE habits ADD COLUMN checklistEnabled INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    return await db.query('habits', orderBy: 'id DESC');
  }

  Future<int> updateHabit(int id, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update('habits', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getHabit(int id) async {
    final db = await database;
    final result = await db.query('habits', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : {};
  }
}