import 'package:mindcare/database/modules/journal_db_helper.dart';
import 'package:mindcare/database/modules/screening_db_helper.dart';
import 'package:mindcare/database/modules/user_db_helper.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// ============================================================================
/// 🗄️ MANAJER DATABASE LOKAL SQLITE ([DbHelper])
/// ============================================================================
/// Kelas ini bertindak sebagai *Central Singleton Access Point* untuk mengelola 
/// basis data lokal berbasis SQLite (`sqflite`) pada aplikasi MindCare.
/// 
/// **Fitur Utama & Arsitektur:**
/// 1. **Singleton Pattern**: Memastikan hanya ada satu instance database aktif.
/// 2. **Modular Helper Delegation**: Membagi fungsi CRUD ke dalam modul terpisah:
///    - [UserDbHelper] untuk Otentikasi & Profil Pengguna.
///    - [JournalDbHelper] untuk Catatan Jurnal Emosi Harian.
///    - [ScreeningDbHelper] untuk Riwayat Tes Kesehatan Mental.
/// 3. **Skema Tabel**: Menginisialisasi 4 tabel utama (`users`, `active_session`, `journals`, `screenings`).
class DbHelper {
  /// Instance tunggal (Singleton) dari [DbHelper]
  static final DbHelper instance = DbHelper._internal();

  /// Objek koneksi database SQLite aktif
  static Database? _database;

  /// Modul Helper khusus transaksi data pengguna & sesi login
  late final UserDbHelper userDb;

  /// Modul Helper khusus transaksi data jurnal emosi
  late final JournalDbHelper journalDb;

  /// Modul Helper khusus transaksi data hasil skrining kesehatan mental
  late final ScreeningDbHelper screeningDb;

  /// Private constructor untuk inisialisasi modul helper dengan lazy getter database
  DbHelper._internal() {
    userDb = UserDbHelper(() => database);
    journalDb = JournalDbHelper(() => database);
    screeningDb = ScreeningDbHelper(() => database);
  }

  /// Getter asinkron untuk mendapatkan koneksi database SQLite.
  /// Jika belum terinisialisasi, method [_initDatabase] akan dipanggil terlebih dahulu.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Membuka file database SQLite `mindcare_app.db` dari direktori penyimpanan perangkat
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mindcare_app.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  /// Membuat skema tabel awal saat database pertama kali dibuat di perangkat pengguna
  Future<void> _createDb(Database db, int version) async {
    // ------------------------------------------------------------------------
    // 1. Tabel Users: Menyimpan data kredensial, profil, dan statistik pengguna
    // ------------------------------------------------------------------------
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

    // ------------------------------------------------------------------------
    // 2. Tabel Active Session: Menyimpan email pengguna yang sedang login
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE active_session (
        id INTEGER PRIMARY KEY DEFAULT 1,
        user_email TEXT,
        updated_at TEXT
      )
    ''');

    // ------------------------------------------------------------------------
    // 3. Tabel Journals: Menyimpan catatan emosi, mood, dan tag harian
    // ------------------------------------------------------------------------
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

    // ------------------------------------------------------------------------
    // 4. Tabel Screenings: Menyimpan hasil evaluasi skrining mandiri
    // ------------------------------------------------------------------------
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

    // Membersihkan data dummy bawaan saat inisialisasi awal
    await _seedDatabase(db);
  }

  /// Membersihkan record dummy awal jika ada
  Future<void> _seedDatabase(Database db) async {
    await db.delete(
      'users',
      where: "id IN ('usr_1', 'usr_2') OR role = 'psychologist'",
    );
    await db.delete('journals', where: "id IN ('1', '2', '3')");
    await db.delete('screenings', where: "id IN ('1', '2', '3')");
  }

  // ==========================================================================
  // 👤 METODE PENGGUNA & AUTENTIKASI (Didelegasikan ke [UserDbHelper])
  // ==========================================================================

  /// Mengambil data pengguna berdasarkan alamat email
  Future<Map<String, dynamic>?> getUserByEmail(String email) =>
      userDb.getUserByEmail(email);

  /// Mendaftarkan pengguna baru (Pasien) ke database lokal
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

  /// Melakukan otentikasi login pengguna berdasarkan email dan kata sandi
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) => userDb.loginUser(email: email, password: password);

  /// Menyimpan email pengguna yang aktif ke tabel `active_session`
  Future<void> setActiveSession(String email) => userDb.setActiveSession(email);

  /// Mengambil data profil dari pengguna yang sedang aktif/login saat ini
  Future<Map<String, dynamic>?> getActiveUser() => userDb.getActiveUser();

  /// Menghapus sesi login aktif (Logout)
  Future<void> logout() => userDb.logout();

  /// Memperbarui informasi profil pengguna berdasarkan email
  Future<void> updateUser(String email, Map<String, dynamic> updates) =>
      userDb.updateUser(email, updates);

  /// Menyinkronkan data pengguna dari Cloud Firebase ke database lokal
  Future<void> syncUser(Map<String, dynamic> userMap) =>
      userDb.syncUser(userMap);

  // ==========================================================================
  // 📓 METODE JURNAL EMOSI (Didelegasikan ke [JournalDbHelper])
  // ==========================================================================

  /// Mengambil seluruh riwayat jurnal pengguna berdasarkan email
  Future<List<Map<String, dynamic>>> getJournals(String userEmail) =>
      journalDb.getJournals(userEmail);

  /// Menambahkan atau menyimpan catatan jurnal emosi baru
  Future<void> insertJournal(Map<String, dynamic> journal) =>
      journalDb.insertJournal(journal);

  /// Menghapus catatan jurnal emosi berdasarkan ID
  Future<void> deleteJournal(String id) => journalDb.deleteJournal(id);

  // ==========================================================================
  // 📊 METODE SKRINING KESEHATAN MENTAL (Didelegasikan ke [ScreeningDbHelper])
  // ==========================================================================

  /// Mengambil riwayat hasil skrining kesehatan mental pengguna berdasarkan email
  Future<List<Map<String, dynamic>>> getScreenings(String userEmail) =>
      screeningDb.getScreenings(userEmail);

  /// Menambahkan hasil tes skrining kesehatan mental baru
  Future<void> insertScreening(Map<String, dynamic> screening) =>
      screeningDb.insertScreening(screening);

  /// Menghapus riwayat skrining berdasarkan ID
  Future<void> deleteScreening(String id) => screeningDb.deleteScreening(id);
}
