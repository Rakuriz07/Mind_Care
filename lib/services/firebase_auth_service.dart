import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindcare/models/user_model_firebase.dart';

/// ============================================================================
/// 🔐 LAYANAN AUTENTIKASI & PROFIL FIREBASE ([FirebaseAuthService])
/// ============================================================================
/// Kelas ini bertindak sebagai jembatan utama untuk mengelola seluruh operasi
/// autentikasi pengguna dan manajemen data profil berbasis **Firebase Authentication**
/// dan **Cloud Firestore**.
/// 
/// **Operasi CRUD & Fitur Utama:**
/// 1. **Register (Create)**: Pendaftaran akun baru via Email/Password & otomatis menyimpan profil ke Firestore `users/{uid}`.
/// 2. **Login (Read & Auth)**: Otentikasi masuk via Email/Password atau Single Sign-On (SSO) Google Sign-In.
/// 3. **Reset Password**: Mengirim email link pemulihan kata sandi.
/// 4. **Update Profile (Update)**: Memperbarui nama, foto avatar (`updatePhotoURL`), nomor telepon, dan preferensi alarm harian.
/// 5. **Logout (Delete Session)**: Mengeluarkan sesi autentikasi pengguna.
class FirebaseAuthService {
  /// Instance pemutar otentikasi akun Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Instance Cloud Firestore untuk penyimpanan basis data cloud
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Konfigurasi Google Sign-In dengan Web Client ID Firebase
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '250964083045-fatsns190gb4hsa0s59h9u7b1dlss6rl.apps.googleusercontent.com',
  );

  /// Referensi ke koleksi dokumen `users` di Cloud Firestore
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Stream perubahan status autentikasi pengguna secara real-time (Login / Logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mendapatkan User ID (UID) unik pengguna terautentikasi saat ini
  String? get currentUserId => _auth.currentUser?.uid;

  /// Mendapatkan objek akun pengguna terautentikasi saat ini
  User? get currentUser => _auth.currentUser;

  // ==========================================================================
  // 📝 1. REGISTER PENGGUNA (CREATE IN FIREBASE AUTH & FIRESTORE)
  // ==========================================================================

  /// Mendaftarkan pengguna baru menggunakan Email dan Kata Sandi.
  /// Setelah pendaftaran berhasil di Firebase Auth, profil pengguna awal akan
  /// otomatis disimpan ke dokumen Cloud Firestore `users/{user.uid}`.
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await _saveUserData(user: user, name: name, email: email.trim());
    }

    return userCredential;
  }

  /// Helper internal untuk menyimpan model profil awal pengguna baru ke Cloud Firestore
  Future<void> _saveUserData({
    required User user,
    required String name,
    required String email,
  }) async {
    final userModel = UserModelFirebase(
      uid: user.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await _usersRef.doc(user.uid).set(userModel.toMap());
  }

  // ==========================================================================
  // 🔑 2. LOGIN PENGGUNA (READ & AUTHENTICATE)
  // ==========================================================================

  /// Otentikasi masuk pengguna yang sudah terdaftar menggunakan Email dan Kata Sandi
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Mengirimkan email instruksi pemulihan (reset) kata sandi via Firebase Auth
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw Exception('Email wajib diisi untuk verifikasi reset kata sandi.');
    }
    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  /// Otentikasi masuk 1-klik menggunakan Akun Google (Google Sign-In).
  /// Jika pengguna baru pertama kali masuk via Google, dokumen profil akan otomatis dibuatkan.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Membersihkan sesi Google tersimpan untuk selalu menampilkan dialog pemilih akun
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Jika akun baru pertama kali login via Google, buatkan dokumen profil di Firestore
      if (user != null) {
        final doc = await _usersRef.doc(user.uid).get();
        if (!doc.exists) {
          await _saveUserData(
            user: user,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
          );
        }
      }

      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        return null;
      }
      if (e.code == 'sign_in_failed' ||
          e.message?.contains('10') == true ||
          e.toString().contains('10')) {
        throw Exception(
          'Konfigurasi SHA-1 Firebase belum lengkap (ApiException 10). Harap daftarkan SHA-1 Play Console di Firebase Console.',
        );
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 🔍 3. READ USER PROFILE DATA FROM FIRESTORE
  // ==========================================================================

  /// Mengambil rincian data profil pengguna dari dokumen Cloud Firestore berdasarkan UID
  Future<UserModelFirebase?> getUserDetails(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModelFirebase.fromMap(doc.data()!);
    }
    return null;
  }

  // ==========================================================================
  // ✏️ 4. UPDATE USER PROFILE & AVATAR (UPDATE)
  // ==========================================================================

  /// Memperbarui nama, nomor telepon, dan foto avatar pengguna di Firebase Auth & Cloud Firestore
  Future<void> updateUserProfileInFirestore({
    required String email,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user != null && name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
      if (user != null &&
          avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          avatarUrl.startsWith('http')) {
        await user.updatePhotoURL(avatarUrl);
      }

      final query = await _usersRef
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        final Map<String, dynamic> updateData = {};
        if (name != null && name.isNotEmpty) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;
        if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

        await _usersRef.doc(docId).update(updateData);
      } else if (user != null) {
        await _usersRef.doc(user.uid).set({
          'uid': user.uid,
          'name': name ?? user.displayName ?? 'Pengguna MindCare',
          'email': cleanEmail,
          'phone': phone ?? '',
          'avatar_url': avatarUrl ?? user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // ==========================================================================
  // 🚪 5. SIGNOUT (LOGOUT)
  // ==========================================================================

  /// Mengeluarkan sesi login pengguna dari Google Sign-In & Firebase Auth
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _auth.signOut();
  }

  // ==========================================================================
  // ⏰ 6. PREFERENSI ALARM & PENGINGAT HARIAN (CREATE / UPDATE & READ)
  // ==========================================================================

  /// Menyimpan preferensi jam alarm bangun pagi ke Cloud Firestore (`users/{uid}`)
  Future<void> saveAlarmPreferencesInFirestore({
    required String email,
    required int hour,
    required int minute,
    required bool enabled,
    required String sound,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    try {
      final user = _auth.currentUser;
      final alarmData = {
        'alarm_preferences': {
          'hour': hour,
          'minute': minute,
          'enabled': enabled,
          'sound': sound,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      };

      if (user != null) {
        await _usersRef.doc(user.uid).set(alarmData, SetOptions(merge: true));
      } else {
        final query = await _usersRef
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          await _usersRef
              .doc(query.docs.first.id)
              .set(alarmData, SetOptions(merge: true));
        }
      }
    } catch (_) {}
  }

  /// Mengambil preferensi jam alarm bangun pagi dari Cloud Firestore (`users/{uid}`)
  Future<Map<String, dynamic>?> getAlarmPreferencesFromFirestore(
    String email,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;

    try {
      final user = _auth.currentUser;
      DocumentSnapshot<Map<String, dynamic>>? doc;

      if (user != null) {
        doc = await _usersRef.doc(user.uid).get();
      }
      if (doc == null || !doc.exists) {
        final query = await _usersRef
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }

      if (doc != null && doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('alarm_preferences') &&
            data['alarm_preferences'] is Map) {
          return Map<String, dynamic>.from(data['alarm_preferences'] as Map);
        }
      }
    } catch (_) {}
    return null;
  }
}
