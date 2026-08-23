import 'package:sqflite/sqflite.dart';

class UserDbHelper {
  final Future<Database> Function() getDatabase;

  UserDbHelper(this.getDatabase);

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
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
    return null;
  }

  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final db = await getDatabase();
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final existingUser = await getUserByEmail(cleanEmail);
    if (existingUser != null) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar. Silakan masuk.',
      };
    }

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

    await db.insert('users', newUser, conflictAlgorithm: ConflictAlgorithm.replace);
    await setActiveSession(cleanEmail);

    return {
      'success': true,
      'message': 'Registrasi Pengguna berhasil!',
      'user': newUser,
    };
  }

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

  Future<void> setActiveSession(String email) async {
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
  }

  Future<Map<String, dynamic>?> getActiveUser() async {
    final db = await getDatabase();
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
    final db = await getDatabase();
    await db.update('active_session', {'user_email': ''}, where: 'id = 1');
  }

  Future<void> updateUser(String email, Map<String, dynamic> updates) async {
    final db = await getDatabase();
    final cleanEmail = email.trim().toLowerCase();
    await db.update(
      'users',
      updates,
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
  }

  Future<void> syncUser(Map<String, dynamic> userMap) async {
    final db = await getDatabase();
    final cleanEmail = (userMap['email'] ?? '').toString().trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    final existing = await getUserByEmail(cleanEmail);
    if (existing == null) {
      final newUser = Map<String, dynamic>.from(userMap);
      newUser['email'] = cleanEmail;
      await db.insert('users', newUser, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update(
        'users',
        userMap,
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
      );
    }
    await setActiveSession(cleanEmail);
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
