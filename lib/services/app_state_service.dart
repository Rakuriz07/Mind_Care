import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/database/app_database.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/firebase_auth_service.dart';
import 'package:mindcare/services/firebase_community_service.dart';
import 'package:mindcare/services/firebase_journal_service.dart';
import 'package:mindcare/services/firebase_messaging_service.dart';
import 'package:mindcare/services/firebase_screening_service.dart';
import 'package:mindcare/services/firebase_storage_service.dart';

/// ============================================================================
/// APP STATE SERVICE (Pusat Pengelola State & Sinkronisasi Data Utama)
/// ----------------------------------------------------------------------------
/// KEGUNAAN & FUNGSI:
/// Class ini adalah pusat kendali state (Central State Management) berbasis `ChangeNotifier`.
/// Berfungsi menghubungkan seluruh layar tampilan UI dengan Database Lokal (SQLite)
/// serta Cloud Backend (Firebase Firestore, Auth, Storage, & Cloud Messaging).
///
/// FITUR UTAMA:
/// 1. Autentikasi Pengguna & Manajemen Sesi Login/Logout.
/// 2. Manajer Profil Pengguna & Foto Profil (Offline & Firebase Storage).
/// 3. Manajer Jurnal Emosi Harian (`journals`).
/// 4. Manajer Hasil Skrining Kesehatan Mental DASS-21 (`screeningHistory`).
/// 5. Manajer Komunitas Real-Time (`realTimeCommunityStream`).
/// 6. Manajer Notifikasi & Pelukan Hangat (`realTimeNotificationsStream`).
/// 7. Keamanan Akses Kunci Biometrik (Fingerprint/FaceID).
/// ============================================================================
class AppStateService extends ChangeNotifier {
  // Singleton Pattern: Memastikan hanya ada 1 instance state yang aktif di seluruh aplikasi.
  static final AppStateService _instance = AppStateService._internal();
  static AppStateService get instance => _instance;

  AppStateService._internal() {
    _initDatabase();
  }

  bool _isReady = false;
  bool get isReady => _isReady;
  bool get isLoggedIn => AppDatabase.instance.hasActiveSession;

  // Profil pengguna aktif saat ini
  UserProfile _userProfile = UserProfile(
    name: 'Pengguna MindCare',
    email: 'user@mindcare.id',
    phone: '+62 812 3456 7890',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  );

  List<JournalEntry> _journals = [];
  List<ScreeningRecord> _screeningHistory = [];
  int _meditationCount = 0;

  // GETTER MEMBACA DATA STATE UNTUK UI
  UserProfile get userProfile => _userProfile;
  List<JournalEntry> get journals => List.unmodifiable(_journals);
  List<ScreeningRecord> get screeningHistory => List.unmodifiable(_screeningHistory);
  int get latestScreeningScore => _screeningHistory.isNotEmpty ? _screeningHistory.first.score : 85;

  /// Menghitung lencana suasana hati otomatis berdasarkan skor skrining paling baru
  String get calculatedScreeningMood {
    if (_screeningHistory.isEmpty) {
      return 'Kondisi Stabil 🔵';
    }
    final latest = _screeningHistory.first;
    final score = latest.score;
    if (score >= 80) {
      return 'Sangat Sehat & Bahagia 🟢';
    } else if (score >= 65) {
      return 'Kondisi Stabil 🔵';
    } else if (score >= 45) {
      return 'Sedang Cemas & Lelah 🟡';
    } else {
      return 'Butuh Perhatian & Dukungan 🔴';
    }
  }

  int get meditationCount => _meditationCount;
  List<CommunityPost> get realTimeCommunityPosts => AppDatabase.instance.getCommunityPosts();

  /// Stream postingan komunitas yang menggabungkan postingan lokal SQLite & Cloud Firestore secara Real-Time
  Stream<List<CommunityPost>> get realTimeCommunityStream {
    try {
      return FirebaseCommunityService.instance
          .streamCommunityPosts(currentUserEmail: _userProfile.email)
          .map((cloudPosts) {
        final localPosts = AppDatabase.instance.getCommunityPosts();
        final combined = <CommunityPost>[...cloudPosts];

        for (var local in localPosts) {
          if (!combined.any((c) => c.id == local.id)) {
            combined.add(local);
          }
        }

        combined.sort((a, b) => b.id.compareTo(a.id));
        return combined;
      });
    } catch (_) {
      return AppDatabase.instance.communityPostsStream;
    }
  }

  /// Inisialisasi Database Lokal & Memuat Sesi Aktif saat Aplikasi Dibuka
  Future<void> _initDatabase() async {
    await AppDatabase.instance.init();
    _userProfile = AppDatabase.instance.getUserProfile();
    if (AppDatabase.instance.hasActiveSession) {
      await DbHelper.instance.setActiveSession(_userProfile.email);
    } else {
      await DbHelper.instance.logout();
    }
    _refreshUserData();
    _isReady = true;
    notifyListeners();

    try {
      await FirebaseMessagingService.instance
          .init(currentUserEmail: _userProfile.email);
    } catch (_) {}
  }

  /// Sinkronisasi Dua Arah (Two-Way Sync) antara SQLite Lokal & Cloud Firestore
  void _refreshUserData() async {
    _journals = AppDatabase.instance.getJournals(_userProfile.email);
    _screeningHistory = AppDatabase.instance.getScreenings(_userProfile.email);
    _meditationCount = AppDatabase.instance.getMeditationCount();

    if (_userProfile.email.isNotEmpty) {
      try {
        // 1. Unggah catatan skrining lokal ke Cloud Firestore
        for (var local in _screeningHistory) {
          final syncRecord = ScreeningRecord(
            id: local.id,
            userEmail: _userProfile.email,
            userName: _userProfile.name.isNotEmpty ? _userProfile.name : local.userName,
            title: local.title,
            date: local.date,
            score: local.score,
            color: local.color,
            bg: local.bg,
            image: local.image,
            answers: local.answers,
          );
          FirebaseScreeningService.instance.saveScreeningRecord(syncRecord);
        }

        // 2. Unggah jurnal lokal ke Cloud Firestore
        for (var localJournal in _journals) {
          FirebaseJournalService.instance.saveJournal(localJournal);
        }

        // 3. Unduh jurnal baru dari Cloud Firestore ke lokal
        final cloudJournals = await FirebaseJournalService.instance
            .getJournals(_userProfile.email);
        if (cloudJournals.isNotEmpty) {
          for (var cloud in cloudJournals) {
            if (!_journals.any((local) => local.id == cloud.id)) {
              _journals.add(cloud);
              AppDatabase.instance.insertJournal(cloud);
            }
          }
          _journals.sort((a, b) => b.id.compareTo(a.id));
        }

        // 4. Unduh riwayat skrining dari Cloud Firestore ke lokal
        final cloudScreenings = await FirebaseScreeningService.instance
            .getScreeningHistory(_userProfile.email);
        if (cloudScreenings.isNotEmpty) {
          for (var cloud in cloudScreenings) {
            if (!_screeningHistory.any((local) => local.id == cloud.id)) {
              _screeningHistory.add(cloud);
              AppDatabase.instance.insertScreening(cloud);
            }
          }
          _screeningHistory.sort((a, b) => b.id.compareTo(a.id));
        }
        notifyListeners();
      } catch (_) {}
    }
  }

  // ==========================================================================
  // MANAJEMEN AUTENTIKASI & LOGOUT
  // ==========================================================================

  /// Registrasi Akun Pasien Baru
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final res = await AppDatabase.instance.registerPatient(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    if (res['success'] == true) {
      _userProfile = AppDatabase.instance.getUserProfile();
      _refreshUserData();
      if (res['user'] != null && res['user'] is Map<String, dynamic>) {
        await DbHelper.instance.syncUser(res['user'] as Map<String, dynamic>);
      }
      await DbHelper.instance.setActiveSession(_userProfile.email);
      notifyListeners();
    }
    return res;
  }

  /// Login Pasien dengan Email & Password
  Future<Map<String, dynamic>> loginPatient({
    required String email,
    required String password,
  }) async {
    final res = await AppDatabase.instance.loginPatient(
      email: email,
      password: password,
    );

    if (res['success'] == true) {
      _userProfile = AppDatabase.instance.getUserProfile();
      _refreshUserData();
      if (res['user'] != null && res['user'] is Map<String, dynamic>) {
        await DbHelper.instance.syncUser(res['user'] as Map<String, dynamic>);
      }
      await DbHelper.instance.setActiveSession(_userProfile.email);
      notifyListeners();
    }
    return res;
  }

  /// Login dengan Akun Google
  Future<Map<String, dynamic>> loginGoogleUser({
    String email = 'user.google@gmail.com',
    String name = 'Pengguna Google',
    String? avatarUrl,
  }) async {
    final res = await AppDatabase.instance.loginGoogleUser(
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );

    if (res['success'] == true) {
      _userProfile = AppDatabase.instance.getUserProfile();
      _refreshUserData();
      if (res['user'] != null && res['user'] is Map<String, dynamic>) {
        await DbHelper.instance.syncUser(res['user'] as Map<String, dynamic>);
      }
      await DbHelper.instance.setActiveSession(_userProfile.email);
      notifyListeners();
    }
    return res;
  }

  /// Keluar dari Akun (Logout)
  Future<void> logout() async {
    try {
      await FirebaseAuthService().signOut();
    } catch (_) {}
    await AppDatabase.instance.logout();
    await DbHelper.instance.logout();
    _journals = [];
    _screeningHistory = [];
    notifyListeners();
  }

  /// Mengubah Kata Sandi Akun
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await AppDatabase.instance.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    notifyListeners();
    return res;
  }

  // ==========================================================================
  // MANAJEMEN PROFIL & FOTO PROFIL
  // ==========================================================================

  /// Memperbarui Data Profil Pengguna (Nama, Email, No HP)
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? specialization,
    String? licenseNumber,
    String? experienceYears,
    String? consultationFee,
  }) {
    if (name != null && name.isNotEmpty) _userProfile.name = name;
    if (email != null && email.isNotEmpty) _userProfile.email = email;
    if (phone != null && phone.isNotEmpty) _userProfile.phone = phone;
    if (role != null && role.isNotEmpty) _userProfile.role = role;
    if (specialization != null) _userProfile.specialization = specialization;
    if (licenseNumber != null) _userProfile.licenseNumber = licenseNumber;
    if (experienceYears != null) _userProfile.experienceYears = experienceYears;
    if (consultationFee != null) _userProfile.consultationFee = consultationFee;

    AppDatabase.instance.saveUserProfile(
      name: _userProfile.name,
      email: _userProfile.email,
      phone: _userProfile.phone,
      role: _userProfile.role,
      specialization: _userProfile.specialization,
      licenseNumber: _userProfile.licenseNumber,
      experienceYears: _userProfile.experienceYears,
      consultationFee: _userProfile.consultationFee,
    );

    FirebaseAuthService().updateUserProfileInFirestore(
      email: _userProfile.email,
      name: _userProfile.name,
      phone: _userProfile.phone,
    );

    notifyListeners();
  }

  void toggleOnlineAccepting() {
    _userProfile.isOnlineAccepting = !_userProfile.isOnlineAccepting;
    AppDatabase.instance.saveUserProfile(
      isOnlineAccepting: _userProfile.isOnlineAccepting,
    );
    notifyListeners();
  }

  /// Mengunggah Foto Profil Baru dalam Bentuk Byte/File ke Firebase Storage
  void updateAvatarBytes(Uint8List bytes, [File? file]) async {
    _userProfile.avatarBytes = bytes;
    _userProfile.avatarFile = file;

    AppDatabase.instance.saveUserProfile(
      avatarBytes: bytes,
    );
    notifyListeners();

    try {
      final downloadUrl = await FirebaseStorageService.instance.uploadProfileImage(
        userEmail: _userProfile.email,
        imageBytes: bytes,
        file: file,
      );

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        _userProfile.avatarUrl = downloadUrl;
        AppDatabase.instance.saveUserProfile(avatarUrl: downloadUrl);
        FirebaseAuthService().updateUserProfileInFirestore(
          email: _userProfile.email,
          avatarUrl: downloadUrl,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Memperbarui URL Foto Profil
  void updateAvatarUrl(String url) {
    _userProfile.avatarUrl = url;
    _userProfile.avatarBytes = null;
    _userProfile.avatarFile = null;

    AppDatabase.instance.saveUserProfile(
      avatarUrl: url,
    );

    FirebaseAuthService().updateUserProfileInFirestore(
      email: _userProfile.email,
      avatarUrl: url,
    );

    notifyListeners();
  }

  // ==========================================================================
  // MANAJEMEN JURNAL HARIAN (JURNAL EMOSI)
  // ==========================================================================

  /// [CREATE] Menambahkan Catatan Jurnal Emosi Baru
  void addJournal(JournalEntry entry) {
    final entryWithUser = JournalEntry(
      id: entry.id,
      userEmail: _userProfile.email,
      title: entry.title,
      date: entry.date,
      preview: entry.preview,
      mood: entry.mood,
      moodColor: entry.moodColor,
      moodBg: entry.moodBg,
      tags: entry.tags,
    );

    _journals.insert(0, entryWithUser);
    AppDatabase.instance.insertJournal(entryWithUser);
    FirebaseJournalService.instance.saveJournal(entryWithUser);
    notifyListeners();
  }

  /// [DELETE] Menghapus Catatan Jurnal berdasarkan ID
  void deleteJournal(String id) {
    _journals.removeWhere((item) => item.id == id);
    AppDatabase.instance.deleteJournal(id);
    FirebaseJournalService.instance.deleteJournal(id);
    notifyListeners();
  }

  // ==========================================================================
  // MANAJEMEN SKRINING KESEHATAN MENTAL DASS-21
  // ==========================================================================

  /// [CREATE] Menyimpan Catatan Hasil Skrining Baru
  void addScreeningRecord(ScreeningRecord record) {
    final activeEmail = _userProfile.email.trim().toLowerCase();
    final cleanEmail = activeEmail.isNotEmpty ? activeEmail : 'pasien@mindcare.com';
    final cleanName = _userProfile.name.isNotEmpty ? _userProfile.name : 'Pengguna MindCare';

    final recordWithUser = ScreeningRecord(
      id: record.id.isNotEmpty ? record.id : 'scr_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: cleanEmail,
      userName: cleanName,
      title: record.title,
      date: record.date,
      score: record.score,
      color: record.color,
      bg: record.bg,
      image: record.image,
      answers: record.answers,
    );

    _screeningHistory.insert(0, recordWithUser);
    AppDatabase.instance.insertScreening(recordWithUser);
    FirebaseScreeningService.instance.saveScreeningRecord(recordWithUser);
    notifyListeners();
  }

  /// [DELETE] Menghapus Catatan Skrining berdasarkan Indeks
  Future<void> deleteScreeningRecord(int index) async {
    if (index >= 0 && index < _screeningHistory.length) {
      final record = _screeningHistory[index];
      _screeningHistory.removeAt(index);
      notifyListeners();
      try {
        await AppDatabase.instance.deleteScreening(record.id);
        await FirebaseScreeningService.instance.deleteScreeningRecord(record.id);
      } catch (_) {}
    }
  }

  /// [DELETE] Menghapus Catatan Skrining berdasarkan ID Dokumen
  Future<void> deleteScreeningRecordById(String id) async {
    final cleanId = id.trim().toLowerCase();
    _screeningHistory.removeWhere((item) => item.id.trim().toLowerCase() == cleanId);
    notifyListeners();
    try {
      await AppDatabase.instance.deleteScreening(id);
      await FirebaseScreeningService.instance.deleteScreeningRecord(id);
    } catch (_) {}
  }

  // ==========================================================================
  // MANAJEMEN MEDITASI & FITUR LAINNYA
  // ==========================================================================

  void incrementMeditation() {
    _meditationCount++;
    AppDatabase.instance.incrementMeditationCount();
    notifyListeners();
  }

  // Operasi Keamanan Kunci Biometrik (Fingerprint/FaceID)
  bool get isBiometricEnabled => AppDatabase.instance.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) async {
    await AppDatabase.instance.setBiometricEnabled(enabled);
    notifyListeners();
  }

  // ==========================================================================
  // MANAJEMEN KOMUNITAS & NOTIFIKASI
  // ==========================================================================

  /// [CREATE] Membagikan Postingan Cerita Baru ke Komunitas
  void addCommunityPost(CommunityPost post) {
    AppDatabase.instance.insertCommunityPost(post);
    FirebaseCommunityService.instance.createPost(post);
    notifyListeners();
  }

  /// [DELETE] Menghapus Postingan Cerita dari Komunitas
  void deleteCommunityPost(String postId) {
    AppDatabase.instance.deleteCommunityPost(postId);
    FirebaseCommunityService.instance.deletePost(postId);
    notifyListeners();
  }

  /// [DELETE] Menghapus Komentar dari Postingan
  void deleteCommunityComment(String postId, String commentId) {
    AppDatabase.instance.deleteCommunityComment(postId, commentId);
    FirebaseCommunityService.instance.deleteComment(postId, commentId);
    notifyListeners();
  }

  /// [READ] Membaca Daftar Notifikasi Pengguna
  List<AppNotification> get notifications {
    return AppDatabase.instance.getNotifications(_userProfile.email);
  }

  /// Stream Notifikasi Real-Time dari Cloud Firestore
  Stream<List<AppNotification>> get realTimeNotificationsStream {
    try {
      return FirebaseCommunityService.instance
          .streamNotifications(userEmail: _userProfile.email);
    } catch (_) {
      return Stream.value(AppDatabase.instance.getNotifications(_userProfile.email));
    }
  }

  int get unreadNotificationsCount {
    return AppDatabase.instance.getUnreadNotificationsCount(_userProfile.email);
  }

  /// Tandai Semua Notifikasi Sudah Dibaca
  Future<void> markAllNotificationsAsRead() async {
    await AppDatabase.instance.markNotificationsAsRead(_userProfile.email);
    notifyListeners();
  }

  /// Toggle Like / Pelukan Hangat pada Postingan
  void toggleLikePost(
    String postId, {
    String senderPseudonym = 'Teman MindCare',
    String senderAvatar = '',
  }) {
    AppDatabase.instance.toggleLikeCommunityPost(
      postId,
      senderPseudonym: senderPseudonym,
      senderAvatar: senderAvatar,
    );
    FirebaseCommunityService.instance.toggleLike(
      postId,
      _userProfile.email,
      senderPseudonym: senderPseudonym,
      senderAvatar: senderAvatar,
    );
    notifyListeners();
  }

  /// Memberikan Komentar Dukungan pada Postingan Komunitas
  void addCommentToPost(String postId, CommunityComment comment) {
    AppDatabase.instance.addCommunityComment(postId, comment);

    final posts = AppDatabase.instance.getCommunityPosts();
    final postAuthorEmail = posts
        .firstWhere(
          (p) => p.id == postId,
          orElse: () => CommunityPost(
            id: postId,
            authorPseudonym: '',
            authorAvatar: '',
            content: '',
            categoryTag: '',
            likesCount: 0,
            commentsCount: 0,
            date: '',
          ),
        )
        .authorEmail;

    FirebaseCommunityService.instance.addComment(
      postId,
      comment,
      postAuthorEmail: postAuthorEmail,
    );
    notifyListeners();
  }
}
