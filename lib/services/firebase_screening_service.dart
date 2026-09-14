import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';

class FirebaseScreeningService {
  static final FirebaseScreeningService _instance =
      FirebaseScreeningService._internal();
  static FirebaseScreeningService get instance => _instance;

  FirebaseScreeningService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _screeningsRef =>
      _firestore.collection('screenings');

  /// Simpan hasil skrining kesehatan mental ke Cloud Firestore
  Future<void> saveScreeningRecord(ScreeningRecord record) async {
    try {
      final cleanEmail = record.userEmail.toLowerCase().trim();
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final docRef = record.id.isNotEmpty
          ? _screeningsRef.doc(record.id)
          : _screeningsRef.doc();

      await docRef.set({
        'id': docRef.id,
        'userId': currentUid,
        'user_id': currentUid,
        'user_email': cleanEmail,
        'user_name': record.userName,
        'title': record.title,
        'date': record.date,
        'score': record.score,
        'color': record.color.toARGB32(),
        'bg': record.bg.toARGB32(),
        'image': record.image,
        'answers': record.answers,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving screening record to Firebase: $e');
    }
  }

  /// Ambil seluruh riwayat skrining user tertentu dari Cloud Firestore
  Future<List<ScreeningRecord>> getScreeningHistory(String userEmail) async {
    final cleanEmail = userEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return [];

    try {
      final snapshot = await _screeningsRef
          .where('user_email', isEqualTo: cleanEmail)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _mapToRecord(doc.id, data);
      }).toList();
    } catch (_) {
      // Fallback query without orderBy if index is building
      final snapshot = await _screeningsRef
          .where('user_email', isEqualTo: cleanEmail)
          .get();

      final list = snapshot.docs.map((doc) {
        return _mapToRecord(doc.id, doc.data());
      }).toList();

      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    }
  }

  /// Stream riwayat skrining user secara Real-Time dari Cloud Firestore
  Stream<List<ScreeningRecord>> streamScreeningHistory(String userEmail) {
    final cleanEmail = userEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return Stream.value([]);

    return _screeningsRef
        .where('user_email', isEqualTo: cleanEmail)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return _mapToRecord(doc.id, doc.data());
      }).toList();

      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    });
  }

  /// Hapus data skrining dari Cloud Firestore berdasarkan ID
  Future<void> deleteScreeningRecord(String recordId) async {
    try {
      await _screeningsRef.doc(recordId).delete();
    } catch (_) {}
  }

  ScreeningRecord _mapToRecord(String docId, Map<String, dynamic> data) {
    final score = data['score'] as int? ?? 85;
    final colorInt = data['color'] as int?;
    final bgInt = data['bg'] as int?;
    final image = data['image'] as String? ?? 'assets/images/senang.png';
    final rawAnswers = data['answers'] as List?;
    final answersList = rawAnswers != null
        ? List<Map<String, dynamic>>.from(
            rawAnswers.map((x) => Map<String, dynamic>.from(x as Map)))
        : <Map<String, dynamic>>[];

    return ScreeningRecord(
      id: docId,
      userEmail: data['user_email'] as String? ?? '',
      userName: data['user_name'] as String? ?? '',
      title: data['title'] as String? ?? 'Skrining Mandiri',
      date: data['date'] as String? ?? '',
      score: score,
      color: colorInt != null ? Color(colorInt) : AppColors.secondary,
      bg: bgInt != null ? Color(bgInt) : AppColors.secondaryContainer,
      image: image,
      answers: answersList,
    );
  }
}
