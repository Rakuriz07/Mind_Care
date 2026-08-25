import 'package:sqflite/sqflite.dart';

class ScreeningDbHelper {
  final Future<Database> Function() getDatabase;

  ScreeningDbHelper(this.getDatabase);

  // --- [READ] Membaca riwayat hasil skrining berdasarkan email user ---
  Future<List<Map<String, dynamic>>> getScreenings(String userEmail) async {
    final db = await getDatabase();
    final cleanEmail = userEmail.trim().toLowerCase();
    return await db.query(
      'screenings',
      where: 'LOWER(user_email) = ?',
      whereArgs: [cleanEmail],
      orderBy: 'created_at DESC',
    );
  }

  // --- [CREATE / UPDATE] Menyimpan catatan hasil skrining baru ---
  Future<void> insertScreening(Map<String, dynamic> screening) async {
    final db = await getDatabase();
    await db.insert('screenings', screening, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- [DELETE] Menghapus data skrining berdasarkan ID ---
  Future<void> deleteScreening(String id) async {
    final db = await getDatabase();
    await db.delete('screenings', where: 'id = ?', whereArgs: [id]);
  }
}
