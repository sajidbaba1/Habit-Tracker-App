import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _currentVersion = 3;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
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
      category TEXT NOT NULL DEFAULT 'Other',
      streak INTEGER NOT NULL,
      completion_log TEXT NOT NULL,
      checklistEnabled INTEGER NOT NULL DEFAULT 0
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE habits ADD COLUMN checklistEnabled INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE habits ADD COLUMN category TEXT NOT NULL DEFAULT \'Other\'');
    }
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    return await db.insert('habits', {
      ...habit,
      'checklistEnabled': habit['checklistEnabled'] is bool ? (habit['checklistEnabled'] ? 1 : 0) : habit['checklistEnabled'] ?? 0,
      'category': habit['category'] ?? 'Other',
    });
  }

  Future<int> updateHabit(int id, Map<String, dynamic> habit) async {
    final db = await database;
    return await db.update('habits', {
      ...habit,
      'checklistEnabled': habit['checklistEnabled'] is bool ? (habit['checklistEnabled'] ? 1 : 0) : habit['checklistEnabled'] ?? 0,
      'category': habit['category'] ?? 'Other',
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    final habits = await db.query('habits');
    return habits.map((habit) => {
      ...habit,
      'checklistEnabled': habit['checklistEnabled'] == 1,
    }).toList();
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    _database = null;
    await db.close();
  }
}