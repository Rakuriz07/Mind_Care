import 'dart:convert';
import 'package:mindcare/constants/app_colors.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  static Database? _database;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mindcare_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // 1. Table Users (Patients & Psychologists)
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

    // 5. Table Bookings / Appointments
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        patient_name TEXT NOT NULL,
        patient_age TEXT NOT NULL,
        patient_avatar TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        issue_summary TEXT NOT NULL,
        screening_score INTEGER NOT NULL,
        screening_category TEXT NOT NULL,
        consultation_type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // Seed default database records
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Seed Patients
    await db.insert('users', {
      'id': 'usr_1',
      'name': 'Anindya Kirana',
      'email': 'anindya.kirana@example.com',
      'password': 'password123',
      'phone': '+62 812 3456 7890',
      'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      'member_since': 'Anggota sejak Agustus 2024',
      'role': 'patient',
      'created_at': now,
    });

    await db.insert('users', {
      'id': 'usr_2',
      'name': 'Budi Santoso',
      'email': 'user@mindcare.id',
      'password': 'password123',
      'phone': '+62 813 9876 5432',
      'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      'member_since': 'Anggota sejak Januari 2025',
      'role': 'patient',
      'created_at': now,
    });

    // Seed Psychologists
    await db.insert('users', {
      'id': 'psy_1',
      'name': 'Dr. Sarah Doe, M.Psi',
      'email': 'sarah.doe@clinic.com',
      'password': 'password123',
      'phone': '+62 821 7788 9900',
      'license_number': 'SIPP. 1984/HIMPSI/2023',
      'experience_years': '5 Tahun',
      'specialization': 'Psikologi Klinis & Terapi Stres',
      'hospital_clinic': 'RS Jiwa Menur & MindCare Clinic',
      'consultation_fee': 'Rp 150.000',
      'avatar_url': 'https://images.unsplash.com/photo-1594824813580-496a798b3f4f?auto=format&fit=crop&w=300&q=80',
      'is_online_accepting': 1,
      'rating': '4.9',
      'total_reviews': 98,
      'role': 'psychologist',
      'created_at': now,
    });

    await db.insert('users', {
      'id': 'psy_2',
      'name': 'Dr. Hendra Wijaya, Sp.KJ',
      'email': 'psikolog@mindcare.id',
      'password': 'password123',
      'phone': '+62 856 1234 5678',
      'license_number': 'STR. 4452/IDI/2022',
      'experience_years': '8 Tahun',
      'specialization': 'Psikiatri & Manajemen Depresi',
      'hospital_clinic': 'Klinik Sehat Jiwa',
      'consultation_fee': 'Rp 200.000',
      'avatar_url': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=300&q=80',
      'is_online_accepting': 1,
      'rating': '5.0',
      'total_reviews': 120,
      'role': 'psychologist',
      'created_at': now,
    });

    // Seed Active Session
    await db.insert('active_session', {
      'id': 1,
      'user_email': 'anindya.kirana@example.com',
      'updated_at': now,
    });

    // Seed Initial Journals
    await db.insert('journals', {
      'id': '1',
      'user_email': 'anindya.kirana@example.com',
      'user_name': 'Anindya Kirana',
      'title': 'Ketenangan di Tengah Kesibukan',
      'date': 'Hari ini, 08:30 WIB',
      'preview': 'Hari ini saya mencoba teknik pernapasan 4-7-8 sebelum memulai rapat kerja penting. Rasanya jauh lebih fokus dan tenang...',
      'mood': 'Tenang',
      'mood_color': AppColors.secondary.value,
      'mood_bg': AppColors.secondaryContainer.value,
      'tags': jsonEncode(['#Mindfulness', '#Kerja', '#Napas']),
      'created_at': now,
    });

    // Seed Initial Screenings
    await db.insert('screenings', {
      'id': '1',
      'user_email': 'anindya.kirana@example.com',
      'user_name': 'Anindya Kirana',
      'title': 'Sangat Baik',
      'date': 'Hari ini, 08:45 WIB',
      'score': 85,
      'color': AppColors.secondary.value,
      'bg': AppColors.secondaryContainer.value,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAD0xZM5CV0Z_4RpRFRQoub2kd51IOVm_WsspJKkZoBRRYRhk8lmLLHhAaksl7E6BdIXPrQ6zGAopmCE71llnm1VD00FOn2HcuUV7GY2K5kdaYRIcMCkdErQWs1yEq9ULH6uE62Rdhf6LipJ-nYPHYE2QcCFR_jX-Z5B_ps_-SMN5BzABSKFp7bTdMT_haqSHxDG3l9u5jmw55ubypNln296gLmoDupZsJvMqSTlLFM9cytzOVz14JL7S56UW10tgRP-VY',
      'created_at': now,
    });

    // Seed Bookings
    await db.insert('bookings', {
      'id': '1',
      'patient_name': 'Rian Pratama',
      'patient_age': '24 Tahun',
      'patient_avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'date': 'Hari ini, 19 Agu 2026',
      'time': '14:00 - 15:00 WIB',
      'issue_summary': 'Gejala insomnia & kecemasan menghadapi ujian skripsi.',
      'screening_score': 54,
      'screening_category': 'Kecemasan Sedang',
      'consultation_type': 'Online Video Call',
      'status': 'Upcoming',
      'created_at': now,
    });
  }

  // ========================================================
  // USER & AUTH METHODS
  // ========================================================

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    final results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
    if (results.isNotEmpty) {
      return Map<String, dynamic>.from(results.first);
    }
    return null;
  }

  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final existingUser = await getUserByEmail(cleanEmail);
    if (existingUser != null) {
      final role = existingUser['role'] == 'psychologist' ? 'Psikolog' : 'Pengguna';
      return {
        'success': false,
        'message': 'Email sudah terdaftar sebagai $role. Silakan masuk.',
      };
    }

    final newUser = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName.isNotEmpty ? cleanName : 'Pengguna MindCare',
      'email': cleanEmail,
      'password': password,
      'phone': phone?.trim() ?? '+62 812 3456 7890',
      'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      'member_since': 'Anggota sejak ${_getCurrentMonthYear()}',
      'role': 'patient',
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insert('users', newUser, conflictAlgorithm: ConflictAlgorithm.replace);
    await setActiveSession(cleanEmail);

    return {
      'success': true,
      'message': 'Registrasi Pengguna berhasil!',
      'user': newUser,
    };
  }

  Future<Map<String, dynamic>> registerPsychologist({
    required String name,
    required String email,
    required String password,
    required String licenseNumber,
    required String experienceYears,
    String? specialization,
    String? consultationFee,
    String? phone,
  }) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final existingUser = await getUserByEmail(cleanEmail);
    if (existingUser != null) {
      final role = existingUser['role'] == 'psychologist' ? 'Psikolog' : 'Pengguna';
      return {
        'success': false,
        'message': 'Email sudah terdaftar sebagai $role. Silakan masuk.',
      };
    }

    final newPsychologist = {
      'id': 'psy_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName.isNotEmpty ? cleanName : 'Dr. Psikolog, M.Psi',
      'email': cleanEmail,
      'password': password,
      'phone': phone?.trim() ?? '+62 821 5566 7788',
      'license_number': licenseNumber.trim().isNotEmpty ? licenseNumber.trim() : 'SIPP. ${DateTime.now().year}/HIMPSI',
      'experience_years': experienceYears.trim().isNotEmpty ? experienceYears.trim() : '3 Tahun',
      'specialization': specialization?.trim().isNotEmpty == true ? specialization!.trim() : 'Psikologi Klinis & Konseling Mental',
      'hospital_clinic': 'Klinik MindCare Mitra',
      'consultation_fee': consultationFee?.trim().isNotEmpty == true ? consultationFee!.trim() : 'Rp 150.000',
      'avatar_url': 'https://images.unsplash.com/photo-1594824813580-496a798b3f4f?auto=format&fit=crop&w=300&q=80',
      'is_online_accepting': 1,
      'rating': '5.0',
      'total_reviews': 1,
      'role': 'psychologist',
      'member_since': 'Anggota sejak ${_getCurrentMonthYear()}',
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insert('users', newPsychologist, conflictAlgorithm: ConflictAlgorithm.replace);
    await setActiveSession(cleanEmail);

    return {
      'success': true,
      'message': 'Pendaftaran Psikolog berhasil! Akun Anda aktif.',
      'user': newPsychologist,
    };
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final user = await getUserByEmail(email);

    if (user == null) {
      return {
        'success': false,
        'message': 'Akun tidak ditemukan. Silakan mendaftar terlebih dahulu.',
      };
    }

    if (user['role'] != expectedRole) {
      final actualRole = user['role'] == 'psychologist' ? 'Psikolog' : 'Pengguna Umum';
      return {
        'success': false,
        'message': 'Email ini terdaftar sebagai $actualRole. Silakan pilih tab "$actualRole" untuk masuk.',
      };
    }

    if (user['password'] != password) {
      return {
        'success': false,
        'message': 'Kata sandi salah. Silakan coba lagi.',
      };
    }

    await setActiveSession(user['email'] as String);

    return {
      'success': true,
      'message': 'Selamat datang kembali, ${user['name']}!',
      'user': user,
    };
  }

  Future<void> setActiveSession(String email) async {
    final db = await database;
    await db.insert(
      'active_session',
      {
        'id': 1,
        'user_email': email,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getActiveUser() async {
    final db = await database;
    final sessionRes = await db.query('active_session', where: 'id = 1');
    if (sessionRes.isNotEmpty) {
      final email = sessionRes.first['user_email'] as String?;
      if (email != null && email.isNotEmpty) {
        return await getUserByEmail(email);
      }
    }
    return null;
  }

  Future<void> logout() async {
    final db = await database;
    await db.update('active_session', {'user_email': ''}, where: 'id = 1');
  }

  Future<void> updateUser(String email, Map<String, dynamic> updates) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    await db.update(
      'users',
      updates,
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
  }

  // ========================================================
  // JOURNAL METHODS
  // ========================================================

  Future<List<Map<String, dynamic>>> getJournals(String userEmail) async {
    final db = await database;
    final cleanEmail = userEmail.trim().toLowerCase();
    return await db.query(
      'journals',
      where: 'LOWER(user_email) = ?',
      whereArgs: [cleanEmail],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> insertJournal(Map<String, dynamic> journal) async {
    final db = await database;
    await db.insert('journals', journal, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteJournal(String id) async {
    final db = await database;
    await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================================
  // SCREENING METHODS
  // ========================================================

  Future<List<Map<String, dynamic>>> getScreenings(String userEmail) async {
    final db = await database;
    final cleanEmail = userEmail.trim().toLowerCase();
    return await db.query(
      'screenings',
      where: 'LOWER(user_email) = ?',
      whereArgs: [cleanEmail],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> insertScreening(Map<String, dynamic> screening) async {
    final db = await database;
    await db.insert('screenings', screening, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteScreening(String id) async {
    final db = await database;
    await db.delete('screenings', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================================
  // BOOKING METHODS
  // ========================================================

  Future<List<Map<String, dynamic>>> getBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'created_at DESC');
  }

  Future<void> updateBookingStatus(String id, String status) async {
    final db = await database;
    await db.update('bookings', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
