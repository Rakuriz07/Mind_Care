import 'package:mindcare/database/modules/journal_db_helper.dart';
import 'package:mindcare/database/modules/screening_db_helper.dart';
import 'package:mindcare/database/modules/user_db_helper.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  static Database? _database;

  late final UserDbHelper userDb;
  late final JournalDbHelper journalDb;
  late final ScreeningDbHelper screeningDb;

  DbHelper._internal() {
    userDb = UserDbHelper(() => database);
    journalDb = JournalDbHelper(() => database);
    screeningDb = ScreeningDbHelper(() => database);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mindcare_app.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // 1. Table Users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        license_number TEXT,
        experience_years TEXT,
        specialization TEXT,
        hospital_clinic TEXT,
        consultation_fee TEXT,
        avatar_url TEXT,
        avatar_bytes_base64 TEXT,
        member_since TEXT,
        is_online_accepting INTEGER DEFAULT 1,
        rating TEXT,
        total_reviews INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // 2. Table Active Session
    await db.execute('''
      CREATE TABLE active_session (
        id INTEGER PRIMARY KEY DEFAULT 1,
        user_email TEXT,
        updated_at TEXT
      )
    ''');

    // 3. Table Journals
    await db.execute('''
      CREATE TABLE journals (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        user_name TEXT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        preview TEXT NOT NULL,
        mood TEXT NOT NULL,
        mood_color INTEGER NOT NULL,
        mood_bg INTEGER NOT NULL,
        tags TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // 4. Table Screenings
    await db.execute('''
      CREATE TABLE screenings (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        user_name TEXT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        score INTEGER NOT NULL,
        color INTEGER NOT NULL,
        bg INTEGER NOT NULL,
        image TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // Seed default database records
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Clear all dummy records
    await db.delete(
      'users',
      where: "id IN ('usr_1', 'usr_2') OR role = 'psychologist'",
    );
    await db.delete('journals', where: "id IN ('1', '2', '3')");
    await db.delete('screenings', where: "id IN ('1', '2', '3')");
  }

  // ========================================================
  // USER & AUTH METHODS (Delegated to UserDbHelper)
  // ========================================================
  Future<Map<String, dynamic>?> getUserByEmail(String email) =>
      userDb.getUserByEmail(email);

  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => userDb.registerPatient(
    name: name,
    email: email,
    password: password,
    phone: phone,
  );

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) => userDb.loginUser(email: email, password: password);

  Future<void> setActiveSession(String email) => userDb.setActiveSession(email);

  Future<Map<String, dynamic>?> getActiveUser() => userDb.getActiveUser();

  Future<void> logout() => userDb.logout();

  Future<void> updateUser(String email, Map<String, dynamic> updates) =>
      userDb.updateUser(email, updates);

  Future<void> syncUser(Map<String, dynamic> userMap) =>
      userDb.syncUser(userMap);

  // ========================================================
  // JOURNAL METHODS (Delegated to JournalDbHelper)
  // ========================================================
  Future<List<Map<String, dynamic>>> getJournals(String userEmail) =>
      journalDb.getJournals(userEmail);

  Future<void> insertJournal(Map<String, dynamic> journal) =>
      journalDb.insertJournal(journal);

  Future<void> deleteJournal(String id) => journalDb.deleteJournal(id);

  // ========================================================
  // SCREENING METHODS (Delegated to ScreeningDbHelper)
  // ========================================================
  Future<List<Map<String, dynamic>>> getScreenings(String userEmail) =>
      screeningDb.getScreenings(userEmail);

  Future<void> insertScreening(Map<String, dynamic> screening) =>
      screeningDb.insertScreening(screening);

  Future<void> deleteScreening(String id) => screeningDb.deleteScreening(id);
}
