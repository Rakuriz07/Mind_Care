import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

/// ============================================================================
/// 🔑 CONTROLLER AUTENTIKASI & PROFIL PENGGUNA (AUTH CONTROLLER)
/// ============================================================================
/// Class ini mengelola seluruh urusan login, registrasi akun baru, login SSO Google,
/// pembaruan foto profil (avatar), pembaruan data pengguna, serta penanganan error
/// dan indikator loading ([_isLoading]).
class AuthController extends ChangeNotifier {
  // Pattern Singleton: Menjamin hanya ada 1 instance AuthController di seluruh aplikasi
  static final AuthController _instance = AuthController._internal();
  static AuthController get instance => _instance;

  AuthController._internal();

  /// Status apakah proses autentikasi sedang berjalan (menampilkan loading spinner di UI)
  bool _isLoading = false;

  /// Pesan kesalahan autentikasi (misal: "Password salah", "Email tidak ditemukan")
  String? _errorMessage;

  /// Getter untuk membaca status loading saat ini
  bool get isLoading => _isLoading;

  /// Getter untuk membaca pesan error autentikasi saat ini
  String? get errorMessage => _errorMessage;

  /// Getter untuk mengambil data profil pengguna aktif dari [AppStateService]
  UserProfile get userProfile => AppStateService.instance.userProfile;

  /// Getter untuk mengecek apakah role pengguna adalah 'psychologist' (Psikolog/Teman Sebaya)
  bool get isPsychologist => AppStateService.instance.userProfile.role == 'psychologist';

  /// --------------------------------------------------------------------------
  /// 🔐 1. LOGIN PENGGUNA VIA EMAIL & PASSWORD ([READ])
  /// --------------------------------------------------------------------------
  /// Memeriksa verifikasi email dan password di database SQLite & Firebase Auth.
  Future<Map<String, dynamic>> loginPatient({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    // Verifikasi kredensial di database lokal SQLite via DbHelper
    final result = await DbHelper.instance.loginUser(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      // Jika berhasil, perbarui sesi pengguna aktif di AppStateService
      await AppStateService.instance.loginPatient(email: email, password: password);
    } else {
      _errorMessage = result['message'];
    }

    _setLoading(false);
    return result;
  }

  /// --------------------------------------------------------------------------
  /// 🌐 2. LOGIN SINGLE SIGN-ON (SSO) VIA GOOGLE ACCOUNT
  /// --------------------------------------------------------------------------
  /// Memungkinkan pengguna masuk dengan 1-klik menggunakan akun Google HP.
  Future<Map<String, dynamic>> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    final result = await AppStateService.instance.loginGoogleUser();

    if (result['success'] != true) {
      _errorMessage = result['message'];
    }

    _setLoading(false);
    return result;
  }

  /// --------------------------------------------------------------------------
  /// 📝 3. PENDAFTARAN AKUN BARU PENGGUNA ([CREATE])
  /// --------------------------------------------------------------------------
  /// Mengontak SQLite dan Firebase Auth untuk mendaftarkan nama, email, dan password.
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await DbHelper.instance.registerPatient(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    if (result['success'] == true) {
      await AppStateService.instance.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
    } else {
      _errorMessage = result['message'];
    }

    _setLoading(false);
    return result;
  }

  /// --------------------------------------------------------------------------
  /// 🚪 4. KELUAR AKUN / LOGOUT
  /// --------------------------------------------------------------------------
  /// Menghapus sesi aktif dari memori lokal HP dan mereset status pengguna ke Tamu.
  Future<void> logout() async {
    _setLoading(true);
    await DbHelper.instance.logout();
    await AppStateService.instance.logout();
    _setLoading(false);
  }

  /// --------------------------------------------------------------------------
  /// ✏️ 5. MEMPERBARUI DATA PROFIL PENGGUNA ([UPDATE])
  /// --------------------------------------------------------------------------
  /// Memperbarui rincian nama, nomor HP, peran (role), spesialisasi, dan tarif konsultasi.
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
    AppStateService.instance.updateProfile(
      name: name,
      email: email,
      phone: phone,
      role: role,
      specialization: specialization,
      licenseNumber: licenseNumber,
      experienceYears: experienceYears,
      consultationFee: consultationFee,
    );
    notifyListeners();
  }

  /// --------------------------------------------------------------------------
  /// 🖼️ 6. MEMPERBARUI FOTO AVATAR PROFIL
  /// --------------------------------------------------------------------------
  /// Mengganti foto avatar dengan data byte gambar atau file galeri HP.
  void updateAvatar(Uint8List bytes, [File? file]) {
    AppStateService.instance.updateAvatarBytes(bytes, file);
    notifyListeners();
  }

  /// --------------------------------------------------------------------------
  /// 🟢 7. TOGGLE STATUS ONLINE / TERSEDIA (KHUSUS PSIKOLOG)
  /// --------------------------------------------------------------------------
  /// Mengubah status ketersediaan penerimaan konsultasi pasien secara real-time.
  void toggleOnlineStatus() {
    AppStateService.instance.toggleOnlineAccepting();
    notifyListeners();
  }

  /// Helper internal untuk mengatur status loading spinner
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper internal untuk menghapus pesan kesalahan sebelumnya
  void _clearError() {
    _errorMessage = null;
  }
}

