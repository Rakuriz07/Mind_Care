import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  static AuthController get instance => _instance;

  AuthController._internal();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile get userProfile => AppStateService.instance.userProfile;
  bool get isPsychologist => AppStateService.instance.userProfile.role == 'psychologist';

  /// Login General Patient User
  Future<Map<String, dynamic>> loginPatient({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await DbHelper.instance.loginUser(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      await AppStateService.instance.loginPatient(email: email, password: password);
    } else {
      _errorMessage = result['message'];
    }

    _setLoading(false);
    return result;
  }

  /// Register New Patient Account
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

  /// Logout Active User Session
  Future<void> logout() async {
    _setLoading(true);
    await DbHelper.instance.logout();
    await AppStateService.instance.logout();
    _setLoading(false);
  }

  /// Update Active User Profile Details
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

  /// Update Profile Avatar Image
  void updateAvatar(Uint8List bytes, [File? file]) {
    AppStateService.instance.updateAvatarBytes(bytes, file);
    notifyListeners();
  }

  /// Toggle Online Status for Psychologists
  void toggleOnlineStatus() {
    AppStateService.instance.toggleOnlineAccepting();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
