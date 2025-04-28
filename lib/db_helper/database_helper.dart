import 'package:absen_sqflite/models/model_absen.dart';
import 'package:absen_sqflite/models/model_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await initDB();
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'absen_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        await db.execute('''
  CREATE TABLE absensi(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    type TEXT,
    date TEXT,
    time TEXT,
    latitude REAL,
    longitude REAL
  )
''');
      },
    );
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertAbsensi(AbsensiModel data) async {
    final db = await database;
    return await db.insert('absensi', data.toMap());
  }

  Future<List<AbsensiModel>> getAbsensiByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'absensi',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
    return result.map((e) => AbsensiModel.fromMap(e)).toList();
  }

  Future<List<AbsensiModel>> getAbsensiTodayByUser(int userId) async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await db.query(
      'absensi',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, today],
      orderBy: 'time ASC',
    );

    return result.map((e) => AbsensiModel.fromMap(e)).toList();
  }

  Future<bool> hasAbsenToday(int userId, String type) async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.query(
      'absensi',
      where: 'userId = ? AND type = ? AND date = ?',
      whereArgs: [userId, type, today],
    );
    return result.isNotEmpty;
  }

  Future<void> deleteAbsensi(int id) async {
    final db = await database;
    await db.delete('absensi', where: 'id = ?', whereArgs: [id]);
  }
}
