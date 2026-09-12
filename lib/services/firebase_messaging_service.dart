import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mindcare/services/local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background Message Received: ${message.messageId}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  static FirebaseMessagingService get instance => _instance;

  FirebaseMessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Inisialisasi Firebase Cloud Messaging (FCM) & Izin Push Notification
  Future<void> init({String? currentUserEmail}) async {
    if (_isInitialized) return;

    try {
      // 1. Request Permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Permission status: ${settings.authorizationStatus}');

      // 2. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Get FCM Token & Save to Firestore
      String? token = await _fcm.getToken();
      if (token != null && currentUserEmail != null && currentUserEmail.isNotEmpty) {
        await _saveFcmTokenToFirestore(currentUserEmail, token);
      }

      // 4. Listen to Token Refresh
      _fcm.onTokenRefresh.listen((newToken) {
        if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
          _saveFcmTokenToFirestore(currentUserEmail, newToken);
        }
      });

      // 5. Subscribe to Topics (Daily Reminders 07:00 & Community Updates)
      await _fcm.subscribeToTopic('daily_reminders');
      await _fcm.subscribeToTopic('community_updates');

      // 6. Handle Foreground Push Notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LocalNotificationService.instance.showDailyScreeningNotification();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Simpan Token FCM Pengguna ke Cloud Firestore
  Future<void> _saveFcmTokenToFirestore(String email, String token) async {
    final cleanEmail = email.toLowerCase().trim();
    if (cleanEmail.isEmpty) return;

    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final query = await usersRef.where('email', isEqualTo: cleanEmail).limit(1).get();
      if (query.docs.isNotEmpty) {
        await usersRef.doc(query.docs.first.id).update({
          'fcmToken': token,
          'fcmLastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }
}
