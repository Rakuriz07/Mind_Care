import 'package:sqflite/sqflite.dart';

class JournalDbHelper {
  final Future<Database> Function() getDatabase;

  JournalDbHelper(this.getDatabase);

  Future<List<Map<String, dynamic>>> getJournals(String userEmail) async {
    final db = await getDatabase();
    final cleanEmail = userEmail.trim().toLowerCase();
    return await db.query(
      'journals',
      where: 'LOWER(user_email) = ?',
      whereArgs: [cleanEmail],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> insertJournal(Map<String, dynamic> journal) async {
    final db = await getDatabase();
    await db.insert('journals', journal, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteJournal(String id) async {
    final db = await getDatabase();
    await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }
}
