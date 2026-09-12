import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();
  static FirebaseStorageService get instance => _instance;

  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mengunggah foto profil pengguna ke Firebase Storage & mengembalikan Download URL resmi
  Future<String?> uploadProfileImage({
    required String userEmail,
    required Uint8List imageBytes,
    File? file,
  }) async {
    final cleanEmail =
        userEmail.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    if (cleanEmail.isEmpty) return null;

    final ref = _storage.ref().child('profile_photos/${cleanEmail}_avatar.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    try {
      if (file != null && await file.exists()) {
        final uploadTask = await ref.putFile(file, metadata);
        return await uploadTask.ref.getDownloadURL();
      } else {
        final uploadTask = await ref.putData(imageBytes, metadata);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Error uploading profile photo to Firebase Storage: $e');
      return null;
    }
  }
}
