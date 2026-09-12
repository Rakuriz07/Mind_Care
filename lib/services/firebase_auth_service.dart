import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindcare/models/user_model_firebase.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '250964083045-fatsns190gb4hsa0s59h9u7b1dlss6rl.apps.googleusercontent.com',
  );

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  // Step 4: Register dengan Email & Password
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
      await _saveUserData(
        user: user,
        name: name,
        email: email.trim(),
      );
    }

    return userCredential;
  }

  // Step 5: Save User Data ke Cloud Firestore
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

  // Step 6: Login dengan Email & Password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Step 6: Login dengan Google (Google Sign-In)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Clear previous cached Google session to force account picker
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
      if (e.code == 'sign_in_failed' || e.message?.contains('10') == true) {
        throw Exception(
          'Konfigurasi SHA-1 Firebase belum lengkap (ApiException 10). Harap daftarkan SHA-1 di Firebase Console.',
        );
      }
      rethrow;
    }
  }

  // Step 9: Function GET User Details dari Firestore
  Future<UserModelFirebase?> getUserDetails(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModelFirebase.fromMap(doc.data()!);
    }
    return null;
  }

  // Update User Profile & Avatar di Cloud Firestore & Firebase Auth
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

      final query =
          await _usersRef.where('email', isEqualTo: cleanEmail).limit(1).get();
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

  // Sign Out (Logout)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _auth.signOut();
  }
}
