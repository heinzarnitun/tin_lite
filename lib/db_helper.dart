import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//class to manage the SQL lite database
class DatabaseHelper {
  //create a single instance of database helper
  static final DatabaseHelper instance = DatabaseHelper._init();
//private variable to hold database instance
  static Database? _database;
//private constructor
  DatabaseHelper._init();

  //getter to get the database instance and return existing one
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messages.db');
    return _database!;
  }
//method to open database from the file path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
//open db, and create one if it doesn't exist
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
//method to create the table structure
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        image TEXT
      )
    ''');
  }
}
