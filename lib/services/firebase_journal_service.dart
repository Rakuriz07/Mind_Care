import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';

class FirebaseJournalService {
  static final FirebaseJournalService _instance =
      FirebaseJournalService._internal();
  static FirebaseJournalService get instance => _instance;

  FirebaseJournalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _journalsRef =>
      _firestore.collection('journals');

  /// Simpan catatan jurnal emosi harian ke Cloud Firestore (Private per User)
  Future<void> saveJournal(JournalEntry entry) async {
    final cleanEmail = entry.userEmail.toLowerCase().trim();
    final docRef =
        entry.id.isNotEmpty ? _journalsRef.doc(entry.id) : _journalsRef.doc();

    await docRef.set({
      'id': docRef.id,
      'user_email': cleanEmail,
      'title': entry.title,
      'date': entry.date,
      'preview': entry.preview,
      'mood': entry.mood,
      'mood_color': entry.moodColor.toARGB32(),
      'mood_bg': entry.moodBg.toARGB32(),
      'tags': entry.tags,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ambil seluruh riwayat jurnal emosi user dari Cloud Firestore
  Future<List<JournalEntry>> getJournals(String userEmail) async {
    final cleanEmail = userEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return [];

    try {
      final snapshot = await _journalsRef
          .where('user_email', isEqualTo: cleanEmail)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return _mapToJournal(doc.id, doc.data());
      }).toList();
    } catch (_) {
      final snapshot = await _journalsRef
          .where('user_email', isEqualTo: cleanEmail)
          .get();

      final list = snapshot.docs.map((doc) {
        return _mapToJournal(doc.id, doc.data());
      }).toList();

      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    }
  }

  /// Stream riwayat jurnal emosi user secara Real-Time dari Cloud Firestore
  Stream<List<JournalEntry>> streamJournals(String userEmail) {
    final cleanEmail = userEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return Stream.value([]);

    return _journalsRef
        .where('user_email', isEqualTo: cleanEmail)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return _mapToJournal(doc.id, doc.data());
      }).toList();

      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    });
  }

  /// Hapus catatan jurnal dari Cloud Firestore berdasarkan ID
  Future<void> deleteJournal(String journalId) async {
    try {
      await _journalsRef.doc(journalId).delete();
    } catch (_) {}
  }

  JournalEntry _mapToJournal(String docId, Map<String, dynamic> data) {
    final moodColorInt = data['mood_color'] as int?;
    final moodBgInt = data['mood_bg'] as int?;

    return JournalEntry(
      id: docId,
      userEmail: data['user_email'] as String? ?? '',
      title: data['title'] as String? ?? '',
      date: data['date'] as String? ?? '',
      preview: data['preview'] as String? ?? '',
      mood: data['mood'] as String? ?? 'Senang 😊',
      moodColor: moodColorInt != null
          ? Color(moodColorInt)
          : AppColors.secondary,
      moodBg: moodBgInt != null
          ? Color(moodBgInt)
          : AppColors.secondaryContainer,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}
