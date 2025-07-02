import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habits.db');
    return await openDatabase(
      path,
      version: 2, // Increased version to trigger upgrade
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            category TEXT,
            icon INTEGER,
            color INTEGER,
            checklist_enabled INTEGER,
            streak INTEGER,
            completion_log TEXT,
            notes TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE habits ADD COLUMN checklist_enabled INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    return await db.query('habits');
  }

  Future<void> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    await db.insert('habits', habit);
  }

  Future<void> updateHabit(Map<String, dynamic> habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [habit['id']],
    );
  }

  Future<void> deleteHabit(int id) async {
    final db = await database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}