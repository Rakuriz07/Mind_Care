import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal();

  File? _dbFile;
  bool _isInitialized = false;

  // In-Memory Separated Tables
  List<Map<String, dynamic>> _patientsTable = [];
  List<Map<String, dynamic>> _psychologistsTable = [];
  Map<String, dynamic> _activeSession = {};

  List<Map<String, dynamic>> _journalsTable = [];
  List<Map<String, dynamic>> _screeningsTable = [];
  List<Map<String, dynamic>> _bookingsTable = [];
  Map<String, dynamic> _preferencesTable = {};

  /// Initialize local database storage
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = Directory.current;
      final dbDir = Directory('${dir.path}/.mindcare_db');
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      _dbFile = File('${dbDir.path}/mindcare_database.json');

      if (_dbFile!.existsSync()) {
        final content = await _dbFile!.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> dbData = jsonDecode(content);
          _patientsTable = List<Map<String, dynamic>>.from(dbData['patients'] ?? []);
          _psychologistsTable = List<Map<String, dynamic>>.from(dbData['psychologists'] ?? []);
          _activeSession = Map<String, dynamic>.from(dbData['active_session'] ?? {});
          _journalsTable = List<Map<String, dynamic>>.from(dbData['journals'] ?? []);
          _screeningsTable = List<Map<String, dynamic>>.from(dbData['screenings'] ?? []);
          _bookingsTable = List<Map<String, dynamic>>.from(dbData['bookings'] ?? []);
          _preferencesTable = Map<String, dynamic>.from(dbData['preferences'] ?? {});

          // Ensure default seed if tables are empty
          if (_patientsTable.isEmpty || _psychologistsTable.isEmpty) {
            await _seedDefaultDatabase();
          }
        } else {
          await _seedDefaultDatabase();
        }
      } else {
        await _seedDefaultDatabase();
      }
    } catch (e) {
      debugPrint('Database initialization warning: $e');
      await _seedDefaultDatabase();
    }

    _isInitialized = true;
  }

  Future<void> _seedDefaultDatabase() async {
    // 1. Separate Table: Patients / General Users
    _patientsTable = [
      {
        'id': 'usr_1',
        'name': 'Anindya Kirana',
        'email': 'anindya.kirana@example.com',
        'password': 'password123',
        'phone': '+62 812 3456 7890',
        'avatar_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAlWoq5VzxXf-IyO9yzfNOIz49MEs3p-M_-c9pS-DpQcGMD2A2EcCtht6EMIhlRDBKJuEXjgsnALbQtDrvUUGTiPmLnQhb1bKSTxmRZr18_8UTPlkeB4QU2CmMebW7E8NKg5QL_QPwGJrcYh4pdSqfet01IBc2jSSVHB9MhW15GMUVkLxiSE6xhw_y_WHCVGU40-R_SI2kRclQQ39kFxtAMh6IF7sV7yyR-79KZuJYuRw3GkHRbs0Mghw',
        'member_since': 'Member since Aug 2024',
        'role': 'patient',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'usr_2',
        'name': 'Budi Santoso',
        'email': 'user@mindcare.id',
        'password': 'password123',
        'phone': '+62 813 9876 5432',
        'avatar_url':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        'member_since': 'Member since Jan 2025',
        'role': 'patient',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    // 2. Separate Table: Psychologists / Therapists
    _psychologistsTable = [
      {
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
        'avatar_url':
            'https://images.unsplash.com/photo-1594824813580-496a798b3f4f?auto=format&fit=crop&w=300&q=80',
        'is_online_accepting': true,
        'rating': '4.9',
        'total_reviews': 98,
        'role': 'psychologist',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
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
        'avatar_url':
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=300&q=80',
        'is_online_accepting': true,
        'rating': '5.0',
        'total_reviews': 120,
        'role': 'psychologist',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    // 3. Active default session (Patient)
    _activeSession = Map<String, dynamic>.from(_patientsTable.first);

    // 4. Seed Journals with User Ownership
    _journalsTable = [
      {
        'id': '1',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Ketenangan di Tengah Kesibukan',
        'date': 'Hari ini, 08:30 WIB',
        'preview':
            'Hari ini saya mencoba teknik pernapasan 4-7-8 sebelum memulai rapat kerja penting. Rasanya jauh lebih fokus dan tenang...',
        'mood': 'Tenang',
        'mood_color': AppColors.secondary.value,
        'mood_bg': AppColors.secondaryContainer.value,
        'tags': ['#Mindfulness', '#Kerja', '#Napas'],
      },
      {
        'id': '2',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Refleksi Akhir Pekan',
        'date': 'Kemarin, 21:15 WIB',
        'preview':
            'Menghabiskan waktu berjalan santai di taman kota tanpa gadget. Sangat menyegarkan pikiran setelah sepekan penuh deadline...',
        'mood': 'Senang',
        'mood_color': AppColors.primary.value,
        'mood_bg': AppColors.primaryContainer.value,
        'tags': ['#SelfCare', '#Healing', '#Nature'],
      },
      {
        'id': '3',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Menghadapi Rasa Cemas',
        'date': '14 Agu 2026, 19:40 WIB',
        'preview':
            'Sempat merasa overwhelmed dengan banyaknya tugas, tapi mendengarkan audio relaksasi malam sangat membantu menurunkan detak jantung...',
        'mood': 'Cemas',
        'mood_color': AppColors.tertiary.value,
        'mood_bg': AppColors.softSunshine.value,
        'tags': ['#Relaksasi', '#Burnout'],
      },
    ];

    // 5. Seed Screenings with User Ownership
    _screeningsTable = [
      {
        'id': '1',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Sangat Baik',
        'date': 'Hari ini, 08:45 WIB',
        'score': 85,
        'color': AppColors.secondary.value,
        'bg': AppColors.secondaryContainer.value,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAD0xZM5CV0Z_4RpRFRQoub2kd51IOVm_WsspJKkZoBRRYRhk8lmLLHhAaksl7E6BdIXPrQ6zGAopmCE71llnm1VD00FOn2HcuUV7GY2K5kdaYRIcMCkdErQWs1yEq9ULH6uE62Rdhf6LipJ-nYPHYE2QcCFR_jX-Z5B_ps_-SMN5BzABSKFp7bTdMT_haqSHxDG3l9u5jmw55ubypNln296gLmoDupZsJvMqSTlLFM9cytzOVz14JL7S56UW10tgRP-VY',
      },
      {
        'id': '2',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Stres Ringan',
        'date': '12 Agu 2026, 20:15 WIB',
        'score': 58,
        'color': AppColors.tertiary.value,
        'bg': AppColors.tertiaryContainer.value,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBUD8y86yr3Iby6BIRJpr3nuL0uriCU1ZZIUR_Pen-a4ZEozm8tDnQ-rmCtYUgd7F0fHncgT5tMFJp_CXHZCmBp4pzOz3J6ukWb5aefHP8s_wfDFzh3hCHcX1Pn8W1xCFHWEk1-g6Kondm2a-aWzWqdnqizrb0Cp9qjtgOUVXDBsOVDuOEAE4xnLTVeu1DobT9Lx7hP5oZQB0IWoEitqLmS_B7iQGutGnDMRNEBcBdjrTF4rgTfVOpnfdqyuX5o6YQz2PA',
      },
      {
        'id': '3',
        'user_email': 'anindya.kirana@example.com',
        'user_name': 'Anindya Kirana',
        'title': 'Butuh Perhatian',
        'date': '05 Agu 2026, 07:10 WIB',
        'score': 40,
        'color': AppColors.error.value,
        'bg': AppColors.errorContainer.value,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBrKQ7cDsFv9FHsaCLI1xjQx7Odrg5JoRmBlXx-qBsXDVYVBLSlU7aIGpuhmCBvu-1jdCY-CI8fp3rR7UW5mZpEVrR1k864yBteVkLUZoKKMmTd4ziF-ukiXNQ3SYaop9nKs-4rw2tYcbrbeEgkIhKGb6UeCfEtFonw3gzEauZu8-x9Dzphy2fRHrjraI51CyYIDxAWIrP5FbrA7fcOdBKEHm-KncXXVSnGe99ttanBjah3Q1TJrmBDcowaIBW5Lv7dcKY',
      },
    ];

    // 6. Seed Psychologist Bookings
    _bookingsTable = [
      {
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
      },
      {
        'id': '2',
        'patient_name': 'Nadia Safitri',
        'patient_age': '29 Tahun',
        'patient_avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
        'date': 'Hari ini, 19 Agu 2026',
        'time': '16:30 - 17:30 WIB',
        'issue_summary': 'Burnout pekerjaan dan kesulitan manajemen emosi harian.',
        'screening_score': 42,
        'screening_category': 'Stres Tinggi',
        'consultation_type': 'Tatap Muka di Klinik',
        'status': 'Upcoming',
      },
      {
        'id': '3',
        'patient_name': 'Dimas Anggara',
        'patient_age': '32 Tahun',
        'patient_avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
        'date': 'Kemarin, 18 Agu 2026',
        'time': '10:00 - 11:00 WIB',
        'issue_summary': 'Sesi evaluasi terapi CBT minggu ke-3 untuk relaksasi.',
        'screening_score': 78,
        'screening_category': 'Membaik / Ringan',
        'consultation_type': 'Online Video Call',
        'status': 'Completed',
      },
    ];

    // 7. Seed Preferences
    _preferencesTable = {
      'morning_reminder': true,
      'night_reminder': true,
      'weekly_report': false,
      'biometric_enabled': true,
      'meditation_count': 12,
    };

    await _flush();
  }

  Future<void> _flush() async {
    try {
      if (_dbFile != null) {
        final data = {
          'patients': _patientsTable,
          'psychologists': _psychologistsTable,
          'active_session': _activeSession,
          'journals': _journalsTable,
          'screenings': _screeningsTable,
          'bookings': _bookingsTable,
          'preferences': _preferencesTable,
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

    // 1. Check if email exists in either table
    final patientExists = _patientsTable.any(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );
    if (patientExists) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar sebagai Pengguna. Silakan masuk atau gunakan email lain.',
      };
    }

    final psychologistExists = _psychologistsTable.any(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );
    if (psychologistExists) {
      return {
        'success': false,
        'message': 'Email ini sudah terdaftar sebagai akun Psikolog. Silakan masuk melalui tab Psikolog.',
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
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAlWoq5VzxXf-IyO9yzfNOIz49MEs3p-M_-c9pS-DpQcGMD2A2EcCtht6EMIhlRDBKJuEXjgsnALbQtDrvUUGTiPmLnQhb1bKSTxmRZr18_8UTPlkeB4QU2CmMebW7E8NKg5QL_QPwGJrcYh4pdSqfet01IBc2jSSVHB9MhW15GMUVkLxiSE6xhw_y_WHCVGU40-R_SI2kRclQQ39kFxtAMh6IF7sV7yyR-79KZuJYuRw3GkHRbs0Mghw',
      'member_since': 'Member since ${_getCurrentMonthYear()}',
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
      final isPsychologist = _psychologistsTable.any(
        (p) => (p['email'] as String).toLowerCase() == cleanEmail,
      );
      if (isPsychologist) {
        return {
          'success': false,
          'message': 'Email terdaftar sebagai Psikolog. Silakan pilih tab "Psikolog" untuk masuk.',
        };
      }

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

  /// Register a new Psychologist into `_psychologistsTable`
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
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final psychologistExists = _psychologistsTable.any(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );
    if (psychologistExists) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar sebagai Psikolog. Silakan masuk.',
      };
    }

    final patientExists = _patientsTable.any(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );
    if (patientExists) {
      return {
        'success': false,
        'message': 'Email ini sudah terdaftar sebagai akun Pengguna.',
      };
    }

    final newPsychologist = {
      'id': 'psy_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName.isNotEmpty ? cleanName : 'Dr. Psikolog, M.Psi',
      'email': cleanEmail,
      'password': password,
      'phone': phone?.trim() ?? '+62 821 5566 7788',
      'license_number': licenseNumber.trim().isNotEmpty
          ? licenseNumber.trim()
          : 'SIPP. ${DateTime.now().year}/HIMPSI',
      'experience_years': experienceYears.trim().isNotEmpty
          ? experienceYears.trim()
          : '3 Tahun',
      'specialization': specialization?.trim().isNotEmpty == true
          ? specialization!.trim()
          : 'Psikologi Klinis & Konseling Mental',
      'hospital_clinic': 'Klinik MindCare Mitra',
      'consultation_fee': consultationFee?.trim().isNotEmpty == true
          ? consultationFee!.trim()
          : 'Rp 150.000',
      'avatar_url':
          'https://images.unsplash.com/photo-1594824813580-496a798b3f4f?auto=format&fit=crop&w=300&q=80',
      'is_online_accepting': true,
      'rating': '5.0',
      'total_reviews': 1,
      'role': 'psychologist',
      'created_at': DateTime.now().toIso8601String(),
    };

    _psychologistsTable.insert(0, newPsychologist);
    _activeSession = Map<String, dynamic>.from(newPsychologist);
    await _flush();

    return {
      'success': true,
      'message': 'Pendaftaran Psikolog berhasil! Akun Anda aktif.',
      'user': newPsychologist,
    };
  }

  /// Login Psychologist from `_psychologistsTable`
  Future<Map<String, dynamic>> loginPsychologist({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final psyIndex = _psychologistsTable.indexWhere(
      (p) => (p['email'] as String).toLowerCase() == cleanEmail,
    );

    if (psyIndex == -1) {
      final isPatient = _patientsTable.any(
        (p) => (p['email'] as String).toLowerCase() == cleanEmail,
      );
      if (isPatient) {
        return {
          'success': false,
          'message': 'Email terdaftar sebagai Pengguna Umum. Silakan pilih tab "Pengguna" untuk masuk.',
        };
      }

      return {
        'success': false,
        'message': 'Akun Psikolog tidak ditemukan. Silakan daftar terlebih dahulu.',
      };
    }

    final psychologist = _psychologistsTable[psyIndex];
    if (psychologist['password'] != password) {
      return {
        'success': false,
        'message': 'Kata sandi salah. Silakan periksa kembali.',
      };
    }

    _activeSession = Map<String, dynamic>.from(psychologist);
    await _flush();

    return {
      'success': true,
      'message': 'Selamat bertugas, ${psychologist['name']}!',
      'user': psychologist,
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
      name: _activeSession['name'] ?? 'Anindya Kirana',
      email: _activeSession['email'] ?? 'anindya.kirana@example.com',
      phone: _activeSession['phone'] ?? '+62 812 3456 7890',
      avatarUrl: _activeSession['avatar_url'] ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAlWoq5VzxXf-IyO9yzfNOIz49MEs3p-M_-c9pS-DpQcGMD2A2EcCtht6EMIhlRDBKJuEXjgsnALbQtDrvUUGTiPmLnQhb1bKSTxmRZr18_8UTPlkeB4QU2CmMebW7E8NKg5QL_QPwGJrcYh4pdSqfet01IBc2jSSVHB9MhW15GMUVkLxiSE6xhw_y_WHCVGU40-R_SI2kRclQQ39kFxtAMh6IF7sV7yyR-79KZuJYuRw3GkHRbs0Mghw',
      avatarBytes: avatarBytes,
      memberSince: _activeSession['member_since'] ?? 'Member since Aug 2024',
      role: _activeSession['role'] ?? 'patient',
      specialization: _activeSession['specialization'] ?? 'Psikologi Klinis & Terapi Stres',
      licenseNumber: _activeSession['license_number'] ?? 'SIPP. 1984/HIMPSI/2023',
      experienceYears: _activeSession['experience_years'] ?? '6 Tahun',
      consultationFee: _activeSession['consultation_fee'] ?? 'Rp 150.000',
      isOnlineAccepting: _activeSession['is_online_accepting'] ?? true,
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
    if (specialization != null) _activeSession['specialization'] = specialization;
    if (licenseNumber != null) _activeSession['license_number'] = licenseNumber;
    if (experienceYears != null) _activeSession['experience_years'] = experienceYears;
    if (consultationFee != null) _activeSession['consultation_fee'] = consultationFee;
    if (isOnlineAccepting != null) _activeSession['is_online_accepting'] = isOnlineAccepting;

    // Also sync back to respective table
    final currentEmail = _activeSession['email'] as String?;
    if (currentEmail != null) {
      if (_activeSession['role'] == 'psychologist') {
        for (var p in _psychologistsTable) {
          if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
            p.addAll(_activeSession);
            break;
          }
        }
      } else {
        for (var p in _patientsTable) {
          if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
            p.addAll(_activeSession);
            break;
          }
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
      if (_activeSession['role'] == 'psychologist') {
        for (var p in _psychologistsTable) {
          if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
            p['password'] = newPassword;
            break;
          }
        }
      } else {
        for (var p in _patientsTable) {
          if (p['email'] == currentEmail || p['id'] == _activeSession['id']) {
            p['password'] = newPassword;
            break;
          }
        }
      }
    }

    await _flush();
    return {
      'success': true,
      'message': 'Kata sandi berhasil diperbarui!',
    };
  }

  // --- Psychologist Appointments CRUD ---
  List<PsychologistAppointment> getAppointments() {
    return _bookingsTable.map((map) {
      return PsychologistAppointment(
        id: map['id'] as String,
        patientName: map['patient_name'] as String,
        patientAge: map['patient_age'] as String,
        patientAvatar: map['patient_avatar'] as String,
        date: map['date'] as String,
        time: map['time'] as String,
        issueSummary: map['issue_summary'] as String,
        screeningScore: map['screening_score'] as int,
        screeningCategory: map['screening_category'] as String,
        consultationType: map['consultation_type'] as String,
        status: map['status'] as String? ?? 'Upcoming',
      );
    }).toList();
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    for (var booking in _bookingsTable) {
      if (booking['id'] == id) {
        booking['status'] = status;
        break;
      }
    }
    await _flush();
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
        moodColor: Color(map['mood_color'] as int? ?? AppColors.secondary.value),
        moodBg: Color(map['mood_bg'] as int? ?? AppColors.secondaryContainer.value),
        tags: List<String>.from(map['tags'] ?? []),
      );
    }).toList();
  }

  Future<void> insertJournal(JournalEntry entry) async {
    final activeEmail = entry.userEmail.isNotEmpty
        ? entry.userEmail
        : (_activeSession['email'] ?? 'anindya.kirana@example.com').toString();

    _journalsTable.insert(0, {
      'id': entry.id,
      'user_email': activeEmail.toLowerCase().trim(),
      'user_name': _activeSession['name'] ?? 'Pengguna MindCare',
      'title': entry.title,
      'date': entry.date,
      'preview': entry.preview,
      'mood': entry.mood,
      'mood_color': entry.moodColor.value,
      'mood_bg': entry.moodBg.value,
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
        id: map['id'] as String,
        userEmail: map['user_email'] as String? ?? targetEmail,
        userName: map['user_name'] as String? ?? (_activeSession['name'] ?? ''),
        title: map['title'] as String,
        date: map['date'] as String,
        score: map['score'] as int,
        color: Color(map['color'] as int? ?? AppColors.secondary.value),
        bg: Color(map['bg'] as int? ?? AppColors.secondaryContainer.value),
        image: map['image'] as String,
      );
    }).toList();
  }

  Future<void> insertScreening(ScreeningRecord record) async {
    final activeEmail = record.userEmail.isNotEmpty
        ? record.userEmail
        : (_activeSession['email'] ?? 'anindya.kirana@example.com').toString();

    final activeName = record.userName.isNotEmpty
        ? record.userName
        : (_activeSession['name'] ?? 'Pengguna MindCare').toString();

    _screeningsTable.insert(0, {
      'id': record.id,
      'user_email': activeEmail.toLowerCase().trim(),
      'user_name': activeName,
      'title': record.title,
      'date': record.date,
      'score': record.score,
      'color': record.color.value,
      'bg': record.bg.value,
      'image': record.image,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _flush();
  }

  Future<void> deleteScreening(String id) async {
    _screeningsTable.removeWhere((item) => item['id'] == id);
    await _flush();
  }

  // --- Preferences & Meditation Stats ---
  int getMeditationCount() => _preferencesTable['meditation_count'] as int? ?? 12;

  Future<void> incrementMeditationCount() async {
    final current = getMeditationCount();
    _preferencesTable['meditation_count'] = current + 1;
    await _flush();
  }

  Map<String, dynamic> getPreferences() => Map.unmodifiable(_preferencesTable);

  Future<void> savePreferences(Map<String, dynamic> prefs) async {
    _preferencesTable.addAll(prefs);
    await _flush();
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
