import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/services/firebase_auth_service.dart';
import 'package:mindcare/views/tips_pola_makan_screen.dart';
import 'package:mindcare/views/meditasi_tidur_screen.dart';
import 'package:mindcare/views/game_relaksasi_screen.dart';
import 'package:mindcare/views/profile_screen.dart';
import 'package:mindcare/views/tulis_jurnal_screen.dart';
import 'package:mindcare/views/daftar_jurnal_screen.dart';
import 'package:mindcare/views/screening_screen.dart';
import 'package:mindcare/views/history_screen.dart';
import 'package:mindcare/views/community/community_screen.dart';
import 'package:mindcare/views/ai_chat_screen.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:mindcare/services/local_notification_service.dart';

/// ============================================================================
/// 🏠 LAYAR DASHBOARD UTAMA MINDCARE ([HomeScreen])
/// ============================================================================
/// Berada di pusat aplikasi sebagai hub utama navigasi:
/// 1. Ringkasan Kebugaran Emosional Hari Ini (skor DASS-21).
/// 2. Akses Cepat fitur Skrining, Jurnal, Komunitas, AI Chat, & Relaksasi.
/// 3. Sistem Alarm Bangun Pagi Presisi Tinggi (Exact Alarm) dengan pilihan audio menenangkan.
class HomeScreen extends StatefulWidget {
  final bool isRootTab;
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.isRootTab = false, this.onSelectTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Indeks tab navigasi bawah yang sedang aktif
  int _selectedNavIndex = 0;

  /// Jam alarm bangun pagi (Default 06:00 WIB)
  TimeOfDay _alarmTime = const TimeOfDay(hour: 6, minute: 0);

  /// Status apakah alarm bangun pagi sedang diaktifkan
  bool _isAlarmEnabled = false;

  /// Pilihan variasi nada suara alarm ('segar', 'senang', 'up', 'standard')
  String _selectedAlarmSound = 'segar';

  /// Daftar opsi nada suara alarm bangun pagi
  final List<Map<String, dynamic>> _alarmSoundOptions = const [
    {
      'id': 'segar',
      'title': 'Hutan & Gemercik Air 🌿',
      'subtitle': 'Suara gemercik air & kicau burung pagi yang menenangkan',
      'icon': Icons.forest_rounded,
      'audioAsset': 'audio/segar.mp3',
    },
    {
      'id': 'senang',
      'title': 'Melodi Lembut 🎹',
      'subtitle': 'Alunan piano akustik lembut penyegar suasana',
      'icon': Icons.music_note_rounded,
      'audioAsset': 'audio/senang.mp3',
    },
    {
      'id': 'up',
      'title': 'Semangat Pagi ☀️',
      'subtitle': 'Irama riang membangunkan energi positif',
      'icon': Icons.wb_sunny_rounded,
      'audioAsset': 'audio/up.mp3',
    },
    {
      'id': 'standard',
      'title': 'Lonceng Standar 🔔',
      'subtitle': 'Nada sistem bawaan standar',
      'icon': Icons.notifications_active_rounded,
      'audioAsset': null,
    },
  ];

  Map<String, dynamic> _getSoundInfo(String id) {
    return _alarmSoundOptions.firstWhere(
      (item) => item['id'] == id,
      orElse: () => _alarmSoundOptions.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedAlarmSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleMorningNotification();
    });
  }

  Future<void> _scheduleMorningNotification() async {
    try {
      if (_isAlarmEnabled) {
        await LocalNotificationService.instance.scheduleWakeupAlarm(
          hour: _alarmTime.hour,
          minute: _alarmTime.minute,
          title: 'Alarm Bangun Pagi ☀️',
          body: 'Waktunya bangun & menyambut hari dengan energi positif ✨',
        );
      } else {
        await LocalNotificationService.instance.cancelWakeupAlarm();
      }
      await LocalNotificationService.instance.scheduleDailyMorningNotification(hour: 7, minute: 0);
    } catch (_) {}
  }

  Future<void> _loadSavedAlarmSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int hour = prefs.getInt('wakeup_alarm_hour') ?? 6;
      int minute = prefs.getInt('wakeup_alarm_minute') ?? 0;
      bool enabled = prefs.getBool('wakeup_alarm_enabled') ?? false;
      String sound = prefs.getString('wakeup_alarm_sound') ?? 'segar';

      // Sinkronisasi ambil setelan alarm dari Cloud Firestore jika tersedia
      final currentUserEmail = AppStateService.instance.userProfile.email;
      if (currentUserEmail.isNotEmpty) {
        final cloudPrefs = await FirebaseAuthService()
            .getAlarmPreferencesFromFirestore(currentUserEmail);
        if (cloudPrefs != null) {
          hour = cloudPrefs['hour'] as int? ?? hour;
          minute = cloudPrefs['minute'] as int? ?? minute;
          enabled = cloudPrefs['enabled'] as bool? ?? enabled;
          sound = cloudPrefs['sound'] as String? ?? sound;

          await prefs.setInt('wakeup_alarm_hour', hour);
          await prefs.setInt('wakeup_alarm_minute', minute);
          await prefs.setBool('wakeup_alarm_enabled', enabled);
          await prefs.setString('wakeup_alarm_sound', sound);
        }
      }

      if (mounted) {
        setState(() {
          _alarmTime = TimeOfDay(hour: hour, minute: minute);
          _isAlarmEnabled = enabled;
          _selectedAlarmSound = sound;
        });
        _scheduleMorningNotification();
      }
    } catch (_) {}
  }

  Future<void> _saveAlarmSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wakeup_alarm_hour', _alarmTime.hour);
      await prefs.setInt('wakeup_alarm_minute', _alarmTime.minute);
      await prefs.setBool('wakeup_alarm_enabled', _isAlarmEnabled);
      await prefs.setString('wakeup_alarm_sound', _selectedAlarmSound);

      // Unggah setelan alarm terbaru ke Cloud Firestore
      final currentUserEmail = AppStateService.instance.userProfile.email;
      if (currentUserEmail.isNotEmpty) {
        FirebaseAuthService().saveAlarmPreferencesInFirestore(
          email: currentUserEmail,
          hour: _alarmTime.hour,
          minute: _alarmTime.minute,
          enabled: _isAlarmEnabled,
          sound: _selectedAlarmSound,
        );
      }

      await _scheduleMorningNotification();
    } catch (_) {}
  }

  void _showAlarmSoundSelectorModal() {
    AudioPlayer? modalAudioPlayer;
    String tempSelectedSound = _selectedAlarmSound;
    String? playingSoundId;

    Future<void> stopAndDisposePlayer() async {
      final player = modalAudioPlayer;
      modalAudioPlayer = null;
      if (player != null) {
        try {
          await player.stop();
          await player.dispose();
        } catch (_) {}
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Suara Alarm Bangun Pagi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await stopAndDisposePlayer();
                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                          }
                        },
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  Text(
                    'Nada yang menenangkan membantu Anda bangun tanpa rasa kaget & stres.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._alarmSoundOptions.map((item) {
                    final isSelected = tempSelectedSound == item['id'];
                    final isPlaying = playingSoundId == item['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.softSkyBlue.withValues(alpha: 0.25)
                            : AppColors.surfaceCanvas,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.skyBlueAccent
                              : AppColors.outlineVariant.withValues(alpha: 0.3),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setModalState(() {
                            tempSelectedSound = item['id'];
                          });
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.softSkyBlue
                                : AppColors.surfaceVariant.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isSelected
                                ? AppColors.skyBlueAccent
                                : AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          item['subtitle'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item['audioAsset'] != null)
                              IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? Icons.stop_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: AppColors.skyBlueAccent,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  if (isPlaying) {
                                    await stopAndDisposePlayer();
                                    setModalState(() {
                                      playingSoundId = null;
                                    });
                                  } else {
                                    await stopAndDisposePlayer();
                                    final newPlayer = AudioPlayer();
                                    modalAudioPlayer = newPlayer;
                                    try {
                                      await newPlayer.play(
                                        AssetSource(item['audioAsset'] as String),
                                      );
                                    } catch (_) {}
                                    setModalState(() {
                                      playingSoundId = item['id'] as String;
                                    });
                                  }
                                },
                              ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? AppColors.skyBlueAccent
                                  : AppColors.outlineVariant.withValues(alpha: 0.6),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await stopAndDisposePlayer();
                        setState(() {
                          _selectedAlarmSound = tempSelectedSound;
                        });
                        _saveAlarmSettings();
                        if (modalContext.mounted) {
                          Navigator.pop(modalContext);
                        }

                        final soundTitle = _getSoundInfo(_selectedAlarmSound)['title'];
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎵 Suara alarm bangun pagi diubah ke "$soundTitle"',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'SIMPAN NADA ALARM',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) async {
      await stopAndDisposePlayer();
    });
  }

  Future<void> _selectCustomAlarmTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime,
      helpText: 'PILIH JAM ALARM BANGUN PAGI ANDA',
      confirmText: 'SIMPAN',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _alarmTime) {
      setState(() {
        _alarmTime = picked;
        _isAlarmEnabled = true;
      });
      _saveAlarmSettings();

      if (mounted) {
        final formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '☀️ Alarm bangun pagi berhasil diatur untuk jam $formattedTime WIB',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 16.0,
                    bottom: widget.isRootTab ? 20.0 : 100.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header Bar
                      _buildHeader(),
                      const SizedBox(height: 20),

                      // 2. HERO FEATURE (Highlighted #1): Screening Kesehatan Mental
                      _buildScreeningBanner(),
                      const SizedBox(height: 24),

                      // 3. WAKE-UP ALARM CARD
                      _buildWakeupAlarmCard(),
                      const SizedBox(height: 24),

                      // 4. CORE FEATURE (Highlighted #2): Jurnal Harian Kamu
                      _buildDailyJournalSection(),
                      const SizedBox(height: 24),

                      // 5. FEATURE: Tanya MindCare AI
                      _buildAiAssistantCard(),
                      const SizedBox(height: 24),

                      // 6. Rekomendasi Fitur (Game Relaksasi & Tips Pola Makan)
                      _buildRecommendationsSection(),
                    ],
                  ),
                ),

                // 6. Custom Floating Bottom Navigation Bar (if not embedded in Root Tab)
                if (!widget.isRootTab)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomNavBar(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiAssistantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.skyBlueAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Tanya MindCare AI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Gemini 1.5',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Sahabat virtual untuk curhat ringan & solusi nutrisi emosional.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiChatScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Tanya AI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  /// --------------------------------------------------------------------------
  /// 😄 HELPER KONVERSI EMOTICON MOOD (_getMoodEmoji)
  /// --------------------------------------------------------------------------
  /// Mengonversi teks kategori emosi pengguna ('Sangat Sedih', 'Sedih', 'Biasa Saja', 'Senang')
  /// menjadi simbol emoji visual yang merepresentasikan perasaan pengguna.
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Sangat Sedih':
        return '😭';
      case 'Sedih':
        return '🙁';
      case 'Biasa Saja':
        return '😐';
      case 'Senang':
        return '😊';
      default:
        return '😊';
    }
  }

  /// --------------------------------------------------------------------------
  /// 👤 HELPER FORMAT NAMA SALAM PENGGUNA (_formatGreetingName)
  /// --------------------------------------------------------------------------
  /// Memotong nama pengguna jika melebihi 16 karakter (menambahkan '...')
  /// agar tampilan header salam "Selamat Pagi/Siang/Malam" tetap rapi dan tidak meluap (overflow).
  String _formatGreetingName(String fullName) {
    final cleanName = fullName.trim();
    if (cleanName.isEmpty) return 'Pengguna';
    if (cleanName.length > 16) {
      return '${cleanName.substring(0, 16)}...';
    }
    return cleanName;
  }

  /// --------------------------------------------------------------------------
  /// 🏆 WIDGET HEADER DASHBOARD UTAMA (_buildHeader)
  /// --------------------------------------------------------------------------
  /// Menyusun baris bagian atas layar utama:
  /// 1. Foto Avatar Profil Pengguna (Mendukung memori bytes, file galeri, asset lokal, atau URL network).
  /// 2. Teks Ucapan Selamat Datang ("Halo, [Nama Pengguna] 👋").
  /// 3. Lencana Peran ("Pasien" / "Teman MindCare" / "Psikolog").
  Widget _buildHeader() {
    final profile = AppStateService.instance.userProfile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Profile Avatar (Non-tappable)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryFixed, width: 2.5),
                ),
                child: ClipOval(
                  child: profile.avatarBytes != null
                      ? Image.memory(profile.avatarBytes!, fit: BoxFit.cover)
                      : profile.avatarFile != null
                      ? Image.file(profile.avatarFile!, fit: BoxFit.cover)
                      : profile.avatarUrl.startsWith('assets/')
                      ? Image.asset(
                          profile.avatarUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppColors.primaryFixed,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                        )
                      : Image.network(
                          profile.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppColors.primaryFixed,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting & Name (Max 16 Chars)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatGreetingName(profile.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Personal Profile Icon Button
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // --- Screening Banner Widget ---
  Widget _buildScreeningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4E9), Color(0xE0F7FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kenali Kondisi Mentalmu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yuk, cek tingkat stres & energi emosionalmu hari ini!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.onSelectTab != null) {
                widget.onSelectTab!(1);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreeningScreen(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
            label: Text(
              'Mulai Skrining',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Setel Alarm Bangun Pagi Widget ---
  Widget _buildWakeupAlarmCard() {
    final formattedTime =
        '${_alarmTime.hour.toString().padLeft(2, '0')}.${_alarmTime.minute.toString().padLeft(2, '0')} WIB';

    final Gradient? cardGradient = _isAlarmEnabled
        ? const LinearGradient(
            colors: [
              Color(0xFFBCE3F5), // Soft vibrant pastel blue (left)
              Color(0xFFE8D5F5), // Soft pastel lavender (center)
              Color(0xFFF9C8D9), // Soft vibrant pastel pink (right)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : null;

    final Color? cardBgColor =
        _isAlarmEnabled ? null : AppColors.surfaceCard;
    final Color cardBorderColor = _isAlarmEnabled
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.softPink.withValues(alpha: 0.5);
    final Color iconBgColor = _isAlarmEnabled
        ? Colors.white
        : AppColors.softPink.withValues(alpha: 0.4);
    final Color accentColor = _isAlarmEnabled
        ? const Color(0xFF8B3A4A) // Deep wine burgundy matching screenshot
        : AppColors.outline;
    final Color timeBoxBgColor = _isAlarmEnabled
        ? Colors.white.withValues(alpha: 0.95)
        : AppColors.softPink.withValues(alpha: 0.15);
    final Color timeBoxBorderColor = _isAlarmEnabled
        ? Colors.white
        : AppColors.softPink.withValues(alpha: 0.4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isAlarmEnabled
                ? const Color.fromRGBO(180, 150, 170, 0.22)
                : const Color.fromRGBO(45, 49, 66, 0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                        boxShadow: _isAlarmEnabled
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.alarm_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alarm Bangun Pagi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E2433),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAlarmEnabled
                                ? 'Aktif • Bangun segar setiap hari'
                                : 'Non-aktif',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: _isAlarmEnabled
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isAlarmEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF8B3A4A),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD0C2C8),
                onChanged: (val) {
                  setState(() {
                    _isAlarmEnabled = val;
                  });
                  _saveAlarmSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: timeBoxBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: timeBoxBorderColor,
              ),
              boxShadow: _isAlarmEnabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedTime,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _selectCustomAlarmTime,
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: Text(
                    'Ubah Jam',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Sound Selector Tile
          InkWell(
            onTap: _showAlarmSoundSelectorModal,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: timeBoxBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: timeBoxBorderColor,
                ),
                boxShadow: _isAlarmEnabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getSoundInfo(_selectedAlarmSound)['icon']
                              as IconData,
                          size: 18,
                          color: accentColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nada Alarm',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B5A63),
                                ),
                              ),
                              Text(
                                _getSoundInfo(_selectedAlarmSound)['title']
                                    as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E2433),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Ubah Nada',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: _isAlarmEnabled
                ? Colors.white.withValues(alpha: 0.8)
                : AppColors.surfaceVariant.withValues(alpha: 0.6),
            height: 1,
          ),
          const SizedBox(height: 14),

          // Tombol Memanjang Meditasi Tidur (Warna Biru Tua Midnight Navy)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MeditasiTidurScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1B4B),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF1E1B4B).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nights_stay_rounded,
                    color: AppColors.softSunshine,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Meditasi Tidur',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // --- Daily Recommendations Section ---
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Rekomendasi Hari Ini',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // 2 Column Grid
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Game Relaksasi
              Expanded(
                child: _buildRecommendationCard(
                  emoji: '🎮',
                  title: 'Game Relaksasi',
                  subtitle: 'Mini Game Pereda Stres',
                  buttonLabel: 'Mainkan Game',
                  iconData: Icons.sports_esports_rounded,
                  isPrimaryButton: false,
                  buttonBgColor: AppColors.softMint.withValues(alpha: 0.35),
                  buttonTextColor: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameRelaksasiScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Card 2: Tips Pola Makan
              Expanded(
                child: _buildRecommendationCard(
                  emoji: '🥗',
                  title: 'Tips Pola Makan',
                  subtitle: 'Nutrisi Usus & Otak',
                  buttonLabel: 'Baca Tips',
                  iconData: Icons.restaurant_rounded,
                  isPrimaryButton: true,
                  buttonBgColor: Colors.transparent,
                  buttonTextColor: AppColors.primary,
                  borderColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TipsPolaMakanScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required IconData iconData,
    required bool isPrimaryButton,
    required Color buttonBgColor,
    required Color buttonTextColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: buttonBgColor,
                side: borderColor != null
                    ? BorderSide(color: borderColor, width: 1.5)
                    : BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 6.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, size: 16, color: buttonTextColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      buttonLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Daily Journal Section ---
  Widget _buildDailyJournalSection() {
    final journals = AppStateService.instance.journals;
    final latest = journals.isNotEmpty ? journals.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Jurnal Harian Kamu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Replaced 'Tulis' with 'Lihat Penulisan Lainnya'
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaftarJurnalScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Penulisan Lainnya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Journal Card (with Tulis action inside)
        if (latest != null)
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(45, 49, 66, 0.05),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Mood Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              latest.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: latest.moodBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getMoodEmoji(latest.mood)} ${latest.mood}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: latest.moodColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quote Text
                Text(
                  '"${latest.preview}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                const Divider(color: AppColors.surfaceVariant, height: 1),
                const SizedBox(height: 12),

                // Bottom Row: Tags & Actions (Tulis Baru + Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hashtag Chips
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: latest.tags
                            .take(2)
                            .map((t) => _buildTag(t))
                            .toList(),
                      ),
                    ),

                    // Actions: Tulis Baru & Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TulisJurnalScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 16),
                          label: Text(
                            'Tulis Baru',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            AppStateService.instance.deleteJournal(latest.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jurnal berhasil dihapus'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.outline,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Empty State Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  size: 36,
                  color: AppColors.outlineVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum Ada Catatan Jurnal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ekspresikan perasaanmu hari ini untuk menjaga kesehatan mental.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TulisJurnalScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'Mulai Tulis Jurnal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  // --- Bottom Navigation Bar Widget ---
  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.fact_check_outlined, 'Skrining'),
          _buildNavItem(2, Icons.history_rounded, 'History'),
          _buildNavItem(3, Icons.forum_outlined, 'Komunitas'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedNavIndex == index;

    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScreeningScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityScreen()),
          );
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
