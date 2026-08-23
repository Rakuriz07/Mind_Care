import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal();

  File? _dbFile;
  bool _isInitialized = false;

  final StreamController<List<CommunityPost>> _communityStreamController =
      StreamController<List<CommunityPost>>.broadcast();

  /// Real-Time Stream of Anonymous Community Posts
  Stream<List<CommunityPost>> get communityPostsStream async* {
    yield getCommunityPosts();
    yield* _communityStreamController.stream;
  }

  void _notifyCommunityChanged() {
    if (!_communityStreamController.isClosed) {
      _communityStreamController.add(getCommunityPosts());
    }
  }

  // In-Memory Separated Tables
  List<Map<String, dynamic>> _patientsTable = [];
  Map<String, dynamic> _activeSession = {};

  List<CommunityPost> _communityPostsTable = [];

  List<Map<String, dynamic>> _journalsTable = [];
  List<Map<String, dynamic>> _screeningsTable = [];
  Map<String, dynamic> _preferencesTable = {};

  /// Initialize local database storage
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      Directory dbDir;
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        dbDir = Directory('${appDocDir.path}/.mindcare_db');
      } catch (_) {
        final dir = Directory.current;
        dbDir = Directory('${dir.path}/.mindcare_db');
      }

      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      _dbFile = File('${dbDir.path}/mindcare_database.json');

      if (_dbFile!.existsSync()) {
        final content = await _dbFile!.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> dbData = jsonDecode(content);
          _patientsTable = List<Map<String, dynamic>>.from(dbData['patients'] ?? []);
          _activeSession = Map<String, dynamic>.from(dbData['active_session'] ?? {});
          _journalsTable = List<Map<String, dynamic>>.from(dbData['journals'] ?? []);
          _screeningsTable = List<Map<String, dynamic>>.from(dbData['screenings'] ?? []);
          _preferencesTable = Map<String, dynamic>.from(dbData['preferences'] ?? {});

          final rawPosts = dbData['community_posts'] as List? ?? [];
          _communityPostsTable = rawPosts
              .map((item) => CommunityPost.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          // Merge seeds safely without overwriting registered accounts
          await _seedDefaultDatabase(mergeOnly: true);
        } else {
          await _seedDefaultDatabase();
        }
      } else {
        await _seedDefaultDatabase();
      }
    } catch (e) {
      debugPrint('Database initialization warning: $e');
      await _seedDefaultDatabase(mergeOnly: true);
    }

    _isInitialized = true;
    _patientsTable.removeWhere((p) => p['id'] == 'usr_1' || p['id'] == 'usr_2');
    _journalsTable.removeWhere((j) => j['id'] == '1' || j['id'] == '2' || j['id'] == '3');
    _screeningsTable.removeWhere((s) => s['id'] == '1' || s['id'] == '2' || s['id'] == '3');
    await _flush();
  }

  Future<void> _seedDefaultDatabase({bool mergeOnly = false}) async {
    // Clear any legacy dummy records
    _patientsTable.removeWhere((p) => p['id'] == 'usr_1' || p['id'] == 'usr_2');
    _journalsTable.removeWhere((j) => j['id'] == '1' || j['id'] == '2' || j['id'] == '3');
    _screeningsTable.removeWhere((s) => s['id'] == '1' || s['id'] == '2' || s['id'] == '3');

    // Default Preferences
    if (!mergeOnly || _preferencesTable.isEmpty) {
      _preferencesTable = {
        'morning_reminder': true,
        'night_reminder': true,
        'weekly_report': false,
        'biometric_enabled': true,
        'meditation_count': 0,
      };
    }

    // 8. Anonymous Community Posts (Preserve all user posts)
    // Filter out only explicit legacy dummy IDs if existing
    _communityPostsTable.removeWhere((p) =>
        p.id == 'post_1' ||
        p.id == 'post_2' ||
        p.id == 'post_3' ||
        p.id == 'post_4' ||
        p.id == 'post_dummy');

    await _flush();
  }

  bool get hasActiveSession =>
      _activeSession.isNotEmpty &&
      _activeSession['email'] != null &&
      (_activeSession['email'] as String).trim().isNotEmpty;

  Future<void> _flush() async {
    try {
      if (_dbFile == null) {
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          final dbDir = Directory('${appDocDir.path}/.mindcare_db');
          if (!dbDir.existsSync()) {
            dbDir.createSync(recursive: true);
          }
          _dbFile = File('${dbDir.path}/mindcare_database.json');
        } catch (_) {
          final dir = Directory.current;
          final dbDir = Directory('${dir.path}/.mindcare_db');
          if (!dbDir.existsSync()) {
            dbDir.createSync(recursive: true);
          }
          _dbFile = File('${dbDir.path}/mindcare_database.json');
        }
      }

      if (_dbFile != null) {
        final data = {
          'patients': _patientsTable,
          'active_session': _activeSession,
          'journals': _journalsTable,
          'screenings': _screeningsTable,
          'preferences': _preferencesTable,
          'community_posts': _communityPostsTable.map((p) => p.toJson()).toList(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        await _dbFile!.writeAsString(jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Error flushing DB to storage: $e');
    }
  }

  // ==========================================
  // AUTHENTICATION & SEPARATE DATABASE METHODS
  // ==========================================

  /// Register a new Patient / General User into `_patientsTable`
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    // 1. Check if email exists
    final patientExists = _patientsTable.any(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );
    if (patientExists) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar sebagai Pengguna. Silakan masuk atau gunakan email lain.',
      };
    }

    // 2. Create Patient Record
    final newPatient = {
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

    _patientsTable.insert(0, newPatient);
    _activeSession = Map<String, dynamic>.from(newPatient);
    await _flush();

    return {
      'success': true,
      'message': 'Registrasi Pengguna berhasil!',
      'user': newPatient,
    };
  }

  /// Login Patient from `_patientsTable`
  Future<Map<String, dynamic>> loginPatient({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Look up in patients table
    final patientIndex = _patientsTable.indexWhere(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );

    if (patientIndex == -1) {
      return {
        'success': false,
        'message': 'Akun Pengguna tidak ditemukan. Silakan daftar terlebih dahulu.',
      };
    }

    final patient = _patientsTable[patientIndex];
    if (patient['password'] != password) {
      return {
        'success': false,
        'message': 'Kata sandi salah. Silakan coba lagi.',
      };
    }

    _activeSession = Map<String, dynamic>.from(patient);
    await _flush();

    return {
      'success': true,
      'message': 'Selamat datang kembali, ${patient['name']}!',
      'user': patient,
    };
  }

  /// Logout active session
  Future<void> logout() async {
    _activeSession = {};
    await _flush();
  }

  // --- Active User Profile Mapping ---
  UserProfile getUserProfile() {
    Uint8List? avatarBytes;
    if (_activeSession['avatar_bytes_base64'] != null) {
      try {
        avatarBytes = base64Decode(_activeSession['avatar_bytes_base64'] as String);
      } catch (_) {}
    }

    return UserProfile(
      name: _activeSession['name'] ?? 'Pengguna MindCare',
      email: _activeSession['email'] ?? '',
      phone: _activeSession['phone'] ?? '+62 812 3456 7890',
      avatarUrl: _activeSession['avatar_url'] ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      avatarBytes: avatarBytes,
      memberSince: _activeSession['member_since'] ?? 'Anggota sejak ${_getCurrentMonthYear()}',
      role: _activeSession['role'] ?? 'patient',
    );
  }

  Future<void> saveUserProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    Uint8List? avatarBytes,
    String? role,
    String? specialization,
    String? licenseNumber,
    String? experienceYears,
    String? consultationFee,
    bool? isOnlineAccepting,
  }) async {
    if (name != null) _activeSession['name'] = name;
    if (email != null) _activeSession['email'] = email;
    if (phone != null) _activeSession['phone'] = phone;
    if (avatarUrl != null) {
      _activeSession['avatar_url'] = avatarUrl;
      _activeSession.remove('avatar_bytes_base64');
    }
    if (avatarBytes != null) {
      _activeSession['avatar_bytes_base64'] = base64Encode(avatarBytes);
    }
    if (role != null) _activeSession['role'] = role;

    // Sync back to patients table
    final currentEmail = _activeSession['email'] as String?;
    if (currentEmail != null) {
      for (var p in _patientsTable) {
        if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
          p.addAll(_activeSession);
          break;
        }
      }
    }

    await _flush();
  }

  /// Change Password for logged in user
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final currentPassword = _activeSession['password'] as String? ?? 'password123';
    if (oldPassword != currentPassword) {
      return {
        'success': false,
        'message': 'Kata sandi lama Anda tidak sesuai.',
      };
    }

    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': 'Kata sandi baru minimal 6 karakter.',
      };
    }

    _activeSession['password'] = newPassword;

    final currentEmail = _activeSession['email'] as String?;
    if (currentEmail != null) {
      for (var p in _patientsTable) {
        if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
          p['password'] = newPassword;
          break;
        }
      }
    }

    await _flush();
    return {
      'success': true,
      'message': 'Kata sandi berhasil diperbarui!',
    };
  }



  // --- Journals CRUD (Filtered per Logged-in User) ---
  List<JournalEntry> getJournals([String? userEmail]) {
    final targetEmail = (userEmail ?? _activeSession['email'] ?? '').toString().toLowerCase().trim();
    if (targetEmail.isEmpty) return [];

    final userJournals = _journalsTable.where((map) {
      final recordEmail = (map['user_email'] ?? '').toString().toLowerCase().trim();
      return recordEmail == targetEmail;
    }).toList();

    return userJournals.map((map) {
      return JournalEntry(
        id: map['id'] as String,
        userEmail: map['user_email'] as String? ?? targetEmail,
        title: map['title'] as String,
        date: map['date'] as String,
        preview: map['preview'] as String,
        mood: map['mood'] as String,
        moodColor: Color(map['mood_color'] as int? ?? AppColors.secondary.toARGB32()),
        moodBg: Color(map['mood_bg'] as int? ?? AppColors.secondaryContainer.toARGB32()),
        tags: List<String>.from(map['tags'] ?? []),
      );
    }).toList();
  }

  Future<void> insertJournal(JournalEntry entry) async {
    final activeEmail = entry.userEmail.isNotEmpty
        ? entry.userEmail
        : (_activeSession['email'] ?? '').toString();

    _journalsTable.insert(0, {
      'id': entry.id,
      'user_email': activeEmail.toLowerCase().trim(),
      'user_name': _activeSession['name'] ?? 'Pengguna MindCare',
      'title': entry.title,
      'date': entry.date,
      'preview': entry.preview,
      'mood': entry.mood,
      'mood_color': entry.moodColor.toARGB32(),
      'mood_bg': entry.moodBg.toARGB32(),
      'tags': entry.tags,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _flush();
  }

  Future<void> deleteJournal(String id) async {
    _journalsTable.removeWhere((item) => item['id'] == id);
    await _flush();
  }

  // --- Screenings CRUD (Filtered per Logged-in User) ---
  List<ScreeningRecord> getScreenings([String? userEmail]) {
    final targetEmail = (userEmail ?? _activeSession['email'] ?? '').toString().toLowerCase().trim();
    if (targetEmail.isEmpty) return [];

    final userScreenings = _screeningsTable.where((map) {
      final recordEmail = (map['user_email'] ?? '').toString().toLowerCase().trim();
      return recordEmail == targetEmail;
    }).toList();

    return userScreenings.map((map) {
      return ScreeningRecord(
        id: (map['id'] ?? '').toString(),
        userEmail: map['user_email'] as String? ?? targetEmail,
        userName: map['user_name'] as String? ?? (_activeSession['name'] ?? ''),
        title: map['title'] as String,
        date: map['date'] as String,
        score: map['score'] as int,
        color: Color(map['color'] as int? ?? AppColors.secondary.toARGB32()),
        bg: Color(map['bg'] as int? ?? AppColors.secondaryContainer.toARGB32()),
        image: map['image'] as String,
      );
    }).toList();
  }

  Future<void> insertScreening(ScreeningRecord record) async {
    final activeEmail = record.userEmail.isNotEmpty
        ? record.userEmail
        : (_activeSession['email'] ?? '').toString();

    final activeName = record.userName.isNotEmpty
        ? record.userName
        : (_activeSession['name'] ?? 'Pengguna MindCare').toString();

    _screeningsTable.insert(0, {
      'id': record.id.toString(),
      'user_email': activeEmail.toLowerCase().trim(),
      'user_name': activeName,
      'title': record.title,
      'date': record.date,
      'score': record.score,
      'color': record.color.toARGB32(),
      'bg': record.bg.toARGB32(),
      'image': record.image,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _flush();
  }

  Future<void> deleteScreening(String id) async {
    final cleanId = id.trim().toLowerCase();
    _screeningsTable.removeWhere((item) => (item['id'] ?? '').toString().trim().toLowerCase() == cleanId);
    await _flush();
  }



  // --- Preferences & Meditation Stats ---
  int getMeditationCount() => _preferencesTable['meditation_count'] as int? ?? 0;

  Future<void> incrementMeditationCount() async {
    final current = getMeditationCount();
    _preferencesTable['meditation_count'] = current + 1;
    await _flush();
  }

  bool isBiometricEnabled() => _preferencesTable['biometric_enabled'] as bool? ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    _preferencesTable['biometric_enabled'] = enabled;
    await _flush();
  }

  Map<String, dynamic> getPreferences() => Map.unmodifiable(_preferencesTable);

  // --- Anonymous Community CRUD ---
  List<CommunityPost> getCommunityPosts() {
    return List<CommunityPost>.from(_communityPostsTable);
  }

  Future<void> insertCommunityPost(CommunityPost post) async {
    _communityPostsTable.insert(0, post);
    _notifyCommunityChanged();
    await _flush();
  }

  Future<void> deleteCommunityPost(String postId) async {
    _communityPostsTable.removeWhere((p) => p.id == postId);
    _notifyCommunityChanged();
    await _flush();
  }

  Future<void> deleteCommunityComment(String postId, String commentId) async {
    for (var post in _communityPostsTable) {
      if (post.id == postId) {
        post.comments.removeWhere((c) => c.id == commentId);
        post.commentsCount = post.comments.length;
        break;
      }
    }
    _notifyCommunityChanged();
    await _flush();
  }

  Future<void> toggleLikeCommunityPost(String postId) async {
    for (var post in _communityPostsTable) {
      if (post.id == postId) {
        post.isLiked = !post.isLiked;
        if (post.isLiked) {
          post.likesCount += 1;
        } else {
          post.likesCount = (post.likesCount - 1).clamp(0, 99999);
        }
        break;
      }
    }
    _notifyCommunityChanged();
    await _flush();
  }

  Future<void> addCommunityComment(String postId, CommunityComment comment) async {
    for (var post in _communityPostsTable) {
      if (post.id == postId) {
        post.comments.insert(0, comment);
        post.commentsCount += 1;
        break;
      }
    }
    _notifyCommunityChanged();
    await _flush();
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
