import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class UserDbHelper {
  final Future<Database> Function() getDatabase;

  UserDbHelper(this.getDatabase);

  // --- [READ] Membaca data user dari tabel SQLite `users` berdasarkan email ---
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await getDatabase();
      final cleanEmail = email.trim().toLowerCase();
      final results = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
      );
      if (results.isNotEmpty) {
        return Map<String, dynamic>.from(results.first);
      }
    } catch (e) {
      debugPrint('UserDbHelper.getUserByEmail warning: $e');
    }
    return null;
  }

  // --- [CREATE] Mendaftarkan user baru ke tabel SQLite `users` ---
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final newUser = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName.isNotEmpty ? cleanName : 'Pengguna MindCare',
      'email': cleanEmail,
      'password': password,
      'phone': phone?.trim() ?? '+62 812 3456 7890',
      'avatar_url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      'member_since': 'Anggota sejak ${_getCurrentMonthYear()}',
      'role': 'patient',
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      final db = await getDatabase();
      final existingUser = await getUserByEmail(cleanEmail);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar. Silakan masuk.',
        };
      }

      await db.insert('users', newUser, conflictAlgorithm: ConflictAlgorithm.replace);
      await setActiveSession(cleanEmail);
    } catch (e) {
      debugPrint('UserDbHelper.registerPatient warning: $e');
    }

    return {
      'success': true,
      'message': 'Registrasi Pengguna berhasil!',
      'user': newUser,
    };
  }

  // --- [READ] Memeriksa kredensial login user di SQLite ---
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final user = await getUserByEmail(email);

    if (user == null) {
      return {
        'success': false,
        'message': 'Akun tidak ditemukan. Silakan mendaftar terlebih dahulu.',
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

  // --- [CREATE / UPDATE] Menyimpan / memperbarui email sesi aktif ---
  Future<void> setActiveSession(String email) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'active_session',
        {
          'id': 1,
          'user_email': email,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('UserDbHelper.setActiveSession warning: $e');
    }
  }

  // --- [READ] Membaca data user yang sedang aktif dari sesi SQLite ---
  Future<Map<String, dynamic>?> getActiveUser() async {
    try {
      final db = await getDatabase();
      final sessionRes = await db.query('active_session', where: 'id = 1');
      if (sessionRes.isNotEmpty) {
        final email = sessionRes.first['user_email'] as String?;
        if (email != null && email.isNotEmpty) {
          return await getUserByEmail(email);
        }
      }
    } catch (e) {
      debugPrint('UserDbHelper.getActiveUser warning: $e');
    }
    return null;
  }

  // --- [UPDATE / DELETE] Mengosongkan sesi aktif saat logout ---
  Future<void> logout() async {
    try {
      final db = await getDatabase();
      await db.update('active_session', {'user_email': ''}, where: 'id = 1');
    } catch (e) {
      debugPrint('UserDbHelper.logout warning: $e');
    }
  }

  // --- [UPDATE] Memperbarui data profil user di tabel SQLite ---
  Future<void> updateUser(String email, Map<String, dynamic> updates) async {
    try {
      final db = await getDatabase();
      final cleanEmail = email.trim().toLowerCase();
      await db.update(
        'users',
        updates,
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
      );
    } catch (e) {
      debugPrint('UserDbHelper.updateUser warning: $e');
    }
  }

  // --- [CREATE / UPDATE] Menyinkronkan data user dari AppDatabase ke SQLite ---
  Future<void> syncUser(Map<String, dynamic> userMap) async {
    final cleanEmail = (userMap['email'] ?? '').toString().trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    final validColumns = {
      'id', 'name', 'email', 'password', 'phone', 'role',
      'license_number', 'experience_years', 'specialization',
      'hospital_clinic', 'consultation_fee', 'avatar_url',
      'avatar_bytes_base64', 'member_since', 'is_online_accepting',
      'rating', 'total_reviews', 'created_at'
    };

    final filteredMap = <String, dynamic>{};
    userMap.forEach((key, value) {
      if (validColumns.contains(key) && value != null) {
        filteredMap[key] = value;
      }
    });

    if (!filteredMap.containsKey('id')) {
      filteredMap['id'] = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    }
    if (!filteredMap.containsKey('name')) {
      filteredMap['name'] = 'Pengguna MindCare';
    }
    if (!filteredMap.containsKey('role')) {
      filteredMap['role'] = 'patient';
    }
    if (!filteredMap.containsKey('password')) {
      filteredMap['password'] = 'password123';
    }
    filteredMap['email'] = cleanEmail;

    try {
      final db = await getDatabase();
      final existing = await getUserByEmail(cleanEmail);
      if (existing == null) {
        await db.insert('users', filteredMap, conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        await db.update(
          'users',
          filteredMap,
          where: 'LOWER(email) = ?',
          whereArgs: [cleanEmail],
        );
      }
      await setActiveSession(cleanEmail);
    } catch (e) {
      debugPrint('UserDbHelper.syncUser warning: $e');
    }
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
