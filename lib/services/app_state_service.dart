import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/database/app_database.dart';
import 'package:mindcare/models/app_models.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  static AppStateService get instance => _instance;

  AppStateService._internal() {
    _initDatabase();
  }

  bool _isReady = false;
  bool get isReady => _isReady;

  UserProfile _userProfile = UserProfile(
    name: 'Anindya Kirana',
    email: 'anindya.kirana@example.com',
    phone: '+62 812 3456 7890',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  );

  List<JournalEntry> _journals = [];
  List<ScreeningRecord> _screeningHistory = [];
  List<PsychologistAppointment> _appointments = [];
  int _meditationCount = 12;

  UserProfile get userProfile => _userProfile;
  List<JournalEntry> get journals => List.unmodifiable(_journals);
  List<ScreeningRecord> get screeningHistory => List.unmodifiable(_screeningHistory);
  List<PsychologistAppointment> get appointments => List.unmodifiable(_appointments);
  int get latestScreeningScore => _screeningHistory.isNotEmpty ? _screeningHistory.first.score : 85;
  int get meditationCount => _meditationCount;
  bool get isPsychologist => _userProfile.role == 'psychologist';

  Future<void> _initDatabase() async {
    await AppDatabase.instance.init();
    _userProfile = AppDatabase.instance.getUserProfile();
    _refreshUserData();
    _appointments = AppDatabase.instance.getAppointments();
    _meditationCount = AppDatabase.instance.getMeditationCount();
    _isReady = true;
    notifyListeners();
  }

  void _refreshUserData() {
    _journals = AppDatabase.instance.getJournals(_userProfile.email);
    _screeningHistory = AppDatabase.instance.getScreenings(_userProfile.email);
  }

  // ==========================================
  // AUTHENTICATION STATE & USER DATA REFRESH
  // ==========================================

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
      notifyListeners();
    }
    return res;
  }

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
      notifyListeners();
    }
    return res;
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
    final res = await AppDatabase.instance.registerPsychologist(
      name: name,
      email: email,
      password: password,
      licenseNumber: licenseNumber,
      experienceYears: experienceYears,
      specialization: specialization,
      consultationFee: consultationFee,
      phone: phone,
    );

    if (res['success'] == true) {
      _userProfile = AppDatabase.instance.getUserProfile();
      _refreshUserData();
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> loginPsychologist({
    required String email,
    required String password,
  }) async {
    final res = await AppDatabase.instance.loginPsychologist(
      email: email,
      password: password,
    );

    if (res['success'] == true) {
      _userProfile = AppDatabase.instance.getUserProfile();
      _refreshUserData();
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    await AppDatabase.instance.logout();
    _journals = [];
    _screeningHistory = [];
    notifyListeners();
  }

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

  // --- Profile Operations ---
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
    notifyListeners();
  }

  void toggleOnlineAccepting() {
    _userProfile.isOnlineAccepting = !_userProfile.isOnlineAccepting;
    AppDatabase.instance.saveUserProfile(
      isOnlineAccepting: _userProfile.isOnlineAccepting,
    );
    notifyListeners();
  }

  void updateAvatarBytes(Uint8List bytes, [File? file]) {
    _userProfile.avatarBytes = bytes;
    _userProfile.avatarFile = file;

    AppDatabase.instance.saveUserProfile(
      avatarBytes: bytes,
    );
    notifyListeners();
  }

  void updateAvatarUrl(String url) {
    _userProfile.avatarUrl = url;
    _userProfile.avatarBytes = null;
    _userProfile.avatarFile = null;

    AppDatabase.instance.saveUserProfile(
      avatarUrl: url,
    );
    notifyListeners();
  }

  // --- Psychologist Appointments Operations ---
  void updateAppointmentStatus(String id, String status) {
    for (var appt in _appointments) {
      if (appt.id == id) {
        appt.status = status;
        break;
      }
    }
    AppDatabase.instance.updateAppointmentStatus(id, status);
    notifyListeners();
  }

  // --- Journal Operations (Attached to Logged-in User) ---
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
    notifyListeners();
  }

  void deleteJournal(String id) {
    _journals.removeWhere((item) => item.id == id);
    AppDatabase.instance.deleteJournal(id);
    notifyListeners();
  }

  // --- Screening Operations (Attached to Logged-in User) ---
  void addScreeningRecord(ScreeningRecord record) {
    final recordWithUser = ScreeningRecord(
      id: record.id,
      userEmail: _userProfile.email,
      userName: _userProfile.name,
      title: record.title,
      date: record.date,
      score: record.score,
      color: record.color,
      bg: record.bg,
      image: record.image,
    );

    _screeningHistory.insert(0, recordWithUser);
    AppDatabase.instance.insertScreening(recordWithUser);
    notifyListeners();
  }

  Future<void> deleteScreeningRecord(int index) async {
    if (index >= 0 && index < _screeningHistory.length) {
      final record = _screeningHistory[index];
      _screeningHistory.removeAt(index);
      await AppDatabase.instance.deleteScreening(record.id);
      notifyListeners();
    }
  }

  Future<void> deleteScreeningRecordById(String id) async {
    final cleanId = id.trim().toLowerCase();
    _screeningHistory.removeWhere((item) => item.id.trim().toLowerCase() == cleanId);
    await AppDatabase.instance.deleteScreening(id);
    notifyListeners();
  }

  // --- Meditation Operations ---
  void incrementMeditation() {
    _meditationCount++;
    AppDatabase.instance.incrementMeditationCount();
    notifyListeners();
  }
}
