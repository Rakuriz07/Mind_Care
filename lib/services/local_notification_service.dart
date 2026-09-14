import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/screening_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ============================================================================
/// LOCAL NOTIFICATION SERVICE (Layanan Notifikasi & Alarm Lokal)
/// ----------------------------------------------------------------------------
/// KEGUNAAN & FUNGSI:
/// Layanan ini mengatur notifikasi lokal di perangkat Android & iOS tanpa memerlukan koneksi internet.
///
/// FITUR UTAMA:
/// 1. Inisialisasi Izin & Channel Notifikasi Android/iOS (`init`).
/// 2. Menampilkan Notifikasi Skrining Harian Langsung (`showDailyScreeningNotification`).
/// 3. Menjadwalkan Pengingat Skrining Pagi Berulang Setiap Hari (`scheduleDailyMorningNotification`).
/// 4. Menjadwalkan Alarm Bangun Pagi Presisi Tinggi (`scheduleWakeupAlarm`).
/// 5. Membatalkan Alarm Bangun Pagi (`cancelWakeupAlarm`).
/// 6. Menampilkan Spanduk Notifikasi Bergaya iOS/Android di Dalam Aplikasi (`showSystemStyleNotificationBanner`).
/// ============================================================================
class LocalNotificationService {
  // Singleton Pattern: Memastikan hanya ada 1 instance layanan di seluruh aplikasi.
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;

  LocalNotificationService._internal();

  // Plugin bawaan flutter_local_notifications untuk berkomunikasi dengan sistem Android & iOS
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// ==========================================================================
  /// 1. INISIALISASI LAYANAN NOTIFIKASI
  /// --------------------------------------------------------------------------
  /// Kegunaan: Mengkonfigurasi ikon aplikasi, waktu Zona (Timezone), serta meminta
  /// izin (*permission*) tampil notifikasi pada Android 13+ & iOS.
  /// ==========================================================================
  Future<void> init() async {
    if (_isInitialized) return;

    // Inisialisasi data timezone lokal perangkat
    tz.initializeTimeZones();

    // Ikon yang dipakai pada sistem Android (menggunakan ic_launcher bawaan)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Izin notifikasi untuk sistem iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Callback ketika pengguna menekan notifikasi yang muncul di HP
        },
      );

      // Meminta izin khusus pemberitahuan di Android 13+ (POST_NOTIFICATIONS)
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
      }
    } catch (_) {}

    _isInitialized = true;
  }

  /// ==========================================================================
  /// 2. MENAMPILKAN NOTIFIKASI LANGSUNG (INSTANT)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menampilkan notifikasi saat itu juga di status bar HP.
  /// ==========================================================================
  Future<void> showDailyScreeningNotification() async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'daily_screening_channel',
      'Skrining Harian MindCare',
      channelDescription: 'Pengingat skrining kesehatan mental harian',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        1001,
        'MindCare 🧠',
        'jangan lupa screening harian yaa',
        notificationDetails,
      );
    } catch (_) {}
  }

  /// ==========================================================================
  /// 3. MENJADWALKAN PENGINGAT SKRINING PAGI HARIAN
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menjadwalkan pengingat skrining otomatis setiap jam 07:00 pagi.
  /// ==========================================================================
  Future<void> scheduleDailyMorningNotification({int hour = 7, int minute = 0}) async {
    await init();

    // Menghitung jam berikutnya untuk eksekusi jadwal pengingat
    tz.TZDateTime nextInstanceOfMorningTime(int hour, int minute) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_screening_channel',
      'Skrining Harian MindCare',
      channelDescription: 'Pengingat skrining kesehatan mental harian setiap pagi',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        1001,
        'MindCare 🧠',
        'jangan lupa screening harian yaa',
        nextInstanceOfMorningTime(hour, minute),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Berulang setiap hari pada jam yang sama
      );
    } catch (_) {}
  }

  /// ==========================================================================
  /// 4. MENJADWALKAN ALARM BANGUN PAGI (EXACT ALARM)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menjadwalkan alarm tepat waktu sesuai jam yang diset oleh pengguna.
  /// Menggunakan mode `exactAllowWhileIdle` agar tetap berbunyi saat HP di posisi sleep.
  /// ==========================================================================
  Future<void> scheduleWakeupAlarm({
    required int hour,
    required int minute,
    String title = 'Alarm Bangun Pagi ☀️',
    String body = 'Waktunya bangun & menyambut hari dengan energi positif ✨',
  }) async {
    await init();

    tz.TZDateTime nextInstanceOfTime(int h, int m) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }

    const androidDetails = AndroidNotificationDetails(
      'wakeup_alarm_channel',
      'Alarm Bangun Pagi',
      channelDescription: 'Pengingat alarm bangun pagi otomatis',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm, // Menggunakan kategori suara Alarm sistem
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.cancel(1002);
      await _notificationsPlugin.zonedSchedule(
        1002,
        title,
        body,
        nextInstanceOfTime(hour, minute),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Presisi tinggi
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          1002,
          title,
          body,
          nextInstanceOfTime(hour, minute),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {}
    }
  }

  /// ==========================================================================
  /// 5. MEMBATALKAN ALARM BANGUN PAGI
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menghapus jadwal alarm bangun pagi dari sistem saat tombol diklik OFF.
  /// ==========================================================================
  Future<void> cancelWakeupAlarm() async {
    await init();
    try {
      await _notificationsPlugin.cancel(1002);
    } catch (_) {}
  }

  /// ==========================================================================
  /// 6. SPANDUK NOTIFIKASI DALAM APLIKASI (OVERLAY BANNER)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menampilkan banner notifikasi meluncur dari atas layar mirip iOS/Android.
  /// ==========================================================================
  void showSystemStyleNotificationBanner(
    BuildContext context, {
    VoidCallback? onTapScreening,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _SystemPushNotificationBanner(
          title: 'MindCare 🧠',
          body: 'jangan lupa screening harian yaa',
          onTap: () {
            entry.remove();
            if (onTapScreening != null) {
              onTapScreening();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreeningScreen(),
                ),
              );
            }
          },
          onDismiss: () {
            entry.remove();
          },
        );
      },
    );

    overlay.insert(entry);
  }
}

/// ============================================================================
/// WIDGET SPANDUK NOTIFIKASI MELUNCUR (_SystemPushNotificationBanner)
/// ----------------------------------------------------------------------------
/// Custom Stateful Widget animasi slide-down untuk memberikan efek notifikasi push bawaan.
/// ============================================================================
class _SystemPushNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _SystemPushNotificationBanner({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_SystemPushNotificationBanner> createState() => _SystemPushNotificationBannerState();
}

class _SystemPushNotificationBannerState extends State<_SystemPushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Hilang otomatis setelah 4 detik
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onTap();
                  });
                },
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null && details.primaryDelta! < -5) {
                    _dismiss();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismiss,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
