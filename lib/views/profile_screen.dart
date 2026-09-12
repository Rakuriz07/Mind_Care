import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/services/biometric_service.dart';
import 'package:mindcare/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final String _userTag = '✨';

  // Notification Preferences State
  bool _morningReminder = true;
  bool _nightReminder = true;
  bool _weeklyReport = false;

  @override
  void initState() {
    super.initState();
    AppStateService.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppStateService.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  final List<Map<String, String>> _availableAvatars = [
    {'title': 'Karakter Senang ✨', 'url': 'assets/images/senang.png'},
    {'title': 'Karakter Cemas 😟', 'url': 'assets/images/cemas.png'},
    {'title': 'Karakter Sedih 😢', 'url': 'assets/images/sedih.png'},
  ];

  Future<bool> _pickImage(ImageSource source) async {
    try {
      XFile? pickedFile;
      try {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
      } catch (err) {
        if (source == ImageSource.camera) {
          pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );
        } else {
          rethrow;
        }
      }

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return false;
        AppStateService.instance.updateAvatarBytes(
          bytes,
          File(pickedFile.path),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diganti dari perangkat! ✨'),
            backgroundColor: AppColors.secondary,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  void _showChangeAvatarModal() {
    String tempSelected = AppStateService.instance.userProfile.avatarUrl;
    final customUrlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ubah Foto Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ambil foto langsung, pilih dari galeri, atau gunakan avatar karakter.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 1. Camera & Gallery Options Row
                    Row(
                      children: [
                        // Camera Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final nav = Navigator.of(context);
                              final success = await _pickImage(
                                ImageSource.camera,
                              );
                              if (success && mounted) {
                                nav.pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kamera',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Gallery Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final nav = Navigator.of(context);
                              final success = await _pickImage(
                                ImageSource.gallery,
                              );
                              if (success && mounted) {
                                nav.pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.photo_library_rounded,
                                    color: AppColors.secondary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Galeri Foto',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Pilihan Karakter Avatar:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Avatar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: _availableAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _availableAvatars[index];
                        final bool isSelected =
                            AppStateService.instance.userProfile.avatarBytes ==
                                null &&
                            AppStateService.instance.userProfile.avatarFile ==
                                null &&
                            tempSelected == avatar['url'];

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempSelected = avatar['url']!;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipOval(
                                  child: avatar['url']!.startsWith('assets/')
                                      ? Image.asset(
                                          avatar['url']!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    color:
                                                        AppColors.primaryFixed,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                        )
                                      : Image.network(
                                          avatar['url']!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    color:
                                                        AppColors.primaryFixed,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                avatar['title']!,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Custom URL Option
                    TextField(
                      controller: customUrlController,
                      decoration: InputDecoration(
                        hintText: 'Atau tempel URL gambar custom...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceCanvas,
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Avatar Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final customUrl = customUrlController.text.trim();
                          final finalUrl = customUrl.isNotEmpty
                              ? customUrl
                              : tempSelected;
                          AppStateService.instance.updateAvatarUrl(finalUrl);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Foto profil berhasil diterapkan! ✨',
                              ),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Simpan Foto Profil',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preferensi Notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Pengingat Game Relaksasi (07:00 WIB)'),
                    value: _morningReminder,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() => _morningReminder = val);
                      setState(() => _morningReminder = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Pengingat Jurnal Malam (21:00 WIB)'),
                    value: _nightReminder,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() => _nightReminder = val);
                      setState(() => _nightReminder = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Rangkuman Mingguan Evaluasi Mood'),
                    value: _weeklyReport,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() => _weeklyReport = val);
                      setState(() => _weeklyReport = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBiometricModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool isEnabled = AppStateService.instance.isBiometricEnabled;

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Keamanan & Biometrik 🛡️',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? AppColors.secondaryContainer.withValues(
                                  alpha: 0.5,
                                )
                              : AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isEnabled
                                ? AppColors.secondary
                                : AppColors.outline,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isEnabled ? 'Aktif 🔒' : 'Nonaktif',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isEnabled
                                ? AppColors.secondary
                                : AppColors.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SwitchListTile(
                    title: Text(
                      'Kunci Aplikasi (Sidik Jari / Face ID)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Amankan catatan jurnal, riwayat skrining, dan percakapan konsultasi Anda dengan sensor biometrik native.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    value: isEnabled,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (val) {
                        // Request Biometric Scan to enable
                        final authRes = await BiometricService.instance
                            .authenticate(
                              localizedReason:
                                  'Verifikasi sidik jari atau Face ID untuk mengaktifkan kunci keamanan MindCare',
                            );

                        if (authRes['success'] == true) {
                          await AppStateService.instance.setBiometricEnabled(
                            true,
                          );
                          setModalState(() {});
                          setState(() {});
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Proteksi biometrik (Sidik Jari / Face ID) berhasil diaktifkan! 🔒✨',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                authRes['message'] as String? ??
                                    'Verifikasi dibatalkan.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else {
                        // Disable biometric protection
                        await AppStateService.instance.setBiometricEnabled(
                          false,
                        );
                        setModalState(() {});
                        setState(() {});
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Proteksi biometrik telah dinonaktifkan.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: AppColors.outline,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Button to test biometric scan directly
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final authRes = await BiometricService.instance
                            .authenticate(
                              localizedReason:
                                  'Uji coba pemindaian sidik jari / Face ID pada perangkat Anda',
                            );

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              authRes['message'] as String? ??
                                  'Hasil pemindaian biometrik',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: authRes['success'] == true
                                ? AppColors.secondary
                                : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.fingerprint_rounded, size: 20),
                      label: Text(
                        'Uji Pindai Sidik Jari / Face ID 👆',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    );
  }

  void _showLanguageInfoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bahasa Aplikasi 🌐',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'MindCare saat ini mengoptimalkan Bahasa Indonesia untuk memberikan pengalaman dan dukungan emosional yang ramah.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Option 1: Bahasa Indonesia (Active)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇩', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bahasa Indonesia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Bahasa Utama (Aktif)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Option 2: English (Coming Soon)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'English (US)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            'Segera Hadir di Versi 2.0',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Soon',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bantuan & Dukungan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildHelpTile(
                Icons.headset_mic_rounded,
                'Layanan Darurat Konseling 24 Jam',
                'Hubungi Hotline Nasional 119 ext 8',
              ),
              const SizedBox(height: 10),
              _buildHelpTile(
                Icons.help_center_rounded,
                'Pusat Bantuan & FAQ',
                'Pelajari cara kerja aplikasi dan panduan medis',
              ),
              const SizedBox(height: 10),
              _buildHelpTile(
                Icons.mail_outline_rounded,
                'Hubungi Tim Pengembang',
                'support@mindcare.id',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutMindCareModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // App Logo / Icon Container
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.spa_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'MindCare',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Versi 2.4.0 • Ruang Aman Kesehatan Mental',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'MindCare adalah aplikasi pendamping kesehatan mental yang dirancang untuk membantu Anda memantau suasana hati, menulis jurnal harian, serta berbagi cerita dalam komunitas anonim yang aman dan hangat.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAboutFeatureItem(Icons.verified_user_rounded, '100% Privasi'),
                        _buildAboutFeatureItem(Icons.favorite_rounded, 'Dukungan Sebaya'),
                        _buildAboutFeatureItem(Icons.fingerprint_rounded, 'Kunci Biometrik'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun MindCare Anda?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await AppStateService.instance.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAccountCenterModal() {
    final user = AppStateService.instance.userProfile;
    final nameController = TextEditingController(text: user.name);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isOldPassVisible = false;
    bool isNewPassVisible = false;
    bool isConfirmPassVisible = false;
    bool isLoadingPass = false;
    int selectedTab = 0; // 0 = Ganti Nama, 1 = Ganti Password

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.manage_accounts_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pusat Akun & Keamanan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Kelola nama profil & kata sandi akun Anda',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tab Selector: Ganti Nama vs Ganti Password
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCanvas,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => selectedTab = 0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedTab == 0
                                      ? AppColors.surfaceCard
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: selectedTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      size: 16,
                                      color: selectedTab == 0
                                          ? AppColors.primary
                                          : AppColors.outline,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ganti Nama',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: selectedTab == 0
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: selectedTab == 0
                                            ? AppColors.primary
                                            : AppColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => selectedTab = 1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedTab == 1
                                      ? AppColors.surfaceCard
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: selectedTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_reset_rounded,
                                      size: 16,
                                      color: selectedTab == 1
                                          ? AppColors.primary
                                          : AppColors.outline,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ganti Password',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: selectedTab == 1
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: selectedTab == 1
                                            ? AppColors.primary
                                            : AppColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TAB 0: GANTI NAMA
                    if (selectedTab == 0) ...[
                      Text(
                        'Nama Lengkap Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama lengkap Anda',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceCanvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              _showError('Silakan masukkan nama lengkap Anda.');
                              return;
                            }

                            AppStateService.instance.updateProfile(
                              name: newName,
                            );
                            Navigator.pop(modalContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Nama lengkap berhasil diubah menjadi "$newName"! ✨',
                                ),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Simpan Nama Baru',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ]
                    // TAB 1: GANTI PASSWORD
                    else ...[
                      Text(
                        'Kata Sandi Saat Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: oldPasswordController,
                        obscureText: !isOldPassVisible,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi lama',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isOldPassVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            onPressed: () => setModalState(
                              () => isOldPassVisible = !isOldPassVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceCanvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Kata Sandi Baru (Min. 6 Karakter)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: newPasswordController,
                        obscureText: !isNewPassVisible,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.key_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewPassVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            onPressed: () => setModalState(
                              () => isNewPassVisible = !isNewPassVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceCanvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Konfirmasi Kata Sandi Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPassVisible,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPassVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            onPressed: () => setModalState(
                              () =>
                                  isConfirmPassVisible = !isConfirmPassVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceCanvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoadingPass
                              ? null
                              : () async {
                                  final oldPass = oldPasswordController.text;
                                  final newPass = newPasswordController.text;
                                  final confirmPass =
                                      confirmPasswordController.text;

                                  if (oldPass.isEmpty) {
                                    _showError(
                                      'Silakan masukkan kata sandi lama Anda.',
                                    );
                                    return;
                                  }

                                  if (newPass.length < 6) {
                                    _showError(
                                      'Kata sandi baru minimal 6 karakter.',
                                    );
                                    return;
                                  }

                                  if (newPass != confirmPass) {
                                    _showError(
                                      'Konfirmasi kata sandi baru tidak cocok.',
                                    );
                                    return;
                                  }

                                  setModalState(() => isLoadingPass = true);
                                  final nav = Navigator.of(modalContext);
                                  final messenger = ScaffoldMessenger.of(context);

                                  final res = await AppStateService.instance
                                      .changePassword(
                                        oldPassword: oldPass,
                                        newPassword: newPass,
                                      );

                                  setModalState(() => isLoadingPass = false);

                                  if (res['success'] == true) {
                                    nav.pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['message'] ??
                                              'Kata sandi berhasil diganti! 🔐',
                                        ),
                                        backgroundColor: AppColors.secondary,
                                      ),
                                    );
                                  } else {
                                    _showError(
                                      res['message'] ??
                                          'Gagal mengganti kata sandi.',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoadingPass
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Perbarui Kata Sandi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top AppBar
                _buildAppBar(),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // Profile Header (Avatar, Name, Edit)
                        _buildProfileHeader(),
                        const SizedBox(height: 20),

                        // Stats Grid (3 Bento Cards)
                        _buildStatsGrid(),
                        const SizedBox(height: 20),

                        // Mental Health Weekly Progress Card
                        _buildProgressCard(),
                        const SizedBox(height: 20),

                        // Settings List Card
                        _buildSettingsList(),
                        const SizedBox(height: 24),

                        // Logout Button
                        _buildLogoutButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- AppBar ---
  Widget _buildAppBar() {
    final profile = AppStateService.instance.userProfile;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.onSurface,
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
              ClipOval(
                child: profile.avatarBytes != null
                    ? Image.memory(
                        profile.avatarBytes!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )
                    : profile.avatarUrl.startsWith('assets/')
                    ? Image.asset(
                        profile.avatarUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 36,
                          height: 36,
                          color: AppColors.primaryFixed,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      )
                    : Image.network(
                        profile.avatarUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 36,
                          height: 36,
                          color: AppColors.primaryFixed,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Text(
                'MindCare',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.')),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // --- Profile Header ---
  Widget _buildProfileHeader() {
    final profile = AppStateService.instance.userProfile;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _showChangeAvatarModal,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.softPink, AppColors.softMint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: profile.avatarBytes != null
                      ? Image.memory(
                          profile.avatarBytes!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                      : profile.avatarFile != null
                      ? Image.file(
                          profile.avatarFile!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                      : profile.avatarUrl.startsWith('assets/')
                      ? Image.asset(
                          profile.avatarUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 96,
                                height: 96,
                                color: AppColors.primaryFixed,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 48,
                                ),
                              ),
                        )
                      : Image.network(
                          profile.avatarUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 96,
                                height: 96,
                                color: AppColors.primaryFixed,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 48,
                                ),
                              ),
                        ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _showChangeAvatarModal,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${profile.name} $_userTag',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          profile.memberSince,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // --- Stats Grid (3 Bento Cards) ---
  Widget _buildStatsGrid() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Sesi Meditasi
          Expanded(
            child: _buildStatCard(
              count: '${AppStateService.instance.meditationCount}',
              label: 'Sesi Meditasi',
              icon: Icons.self_improvement_rounded,
              iconBg: AppColors.softPink.withValues(alpha: 0.35),
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // 2. Jurnal Ditulis
          Expanded(
            child: _buildStatCard(
              count: '${AppStateService.instance.journals.length}',
              label: 'Jurnal Ditulis',
              icon: Icons.menu_book_rounded,
              iconBg: AppColors.softMint.withValues(alpha: 0.4),
              iconColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 10),

          // 3. Skrining Dilakukan
          Expanded(
            child: _buildStatCard(
              count: '${AppStateService.instance.screeningHistory.length}',
              label: 'Skrining Dilakukan',
              icon: Icons.assignment_turned_in_rounded,
              iconBg: AppColors.softSunshine.withValues(alpha: 0.5),
              iconColor: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3142).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmotAssetForScore(int score, String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('cemas') || lowerTitle.contains('ansietas')) {
      return 'assets/images/cemas.png';
    }
    if (lowerTitle.contains('sedih') ||
        lowerTitle.contains('depresi') ||
        lowerTitle.contains('stres') ||
        lowerTitle.contains('berat')) {
      return 'assets/images/sedih.png';
    }
    if (lowerTitle.contains('senang') ||
        lowerTitle.contains('baik') ||
        lowerTitle.contains('stabil') ||
        lowerTitle.contains('sehat') ||
        lowerTitle.contains('normal')) {
      return 'assets/images/senang.png';
    }

    if (score >= 75) {
      return 'assets/images/senang.png';
    } else if (score >= 50) {
      return 'assets/images/cemas.png';
    } else {
      return 'assets/images/sedih.png';
    }
  }

  // --- Mental Health Weekly Progress Card (Dynamic from Screening Results) ---
  Widget _buildProgressCard() {
    final history = AppStateService.instance.screeningHistory;
    // Chronological order: oldest left, newest right
    final chronological = history.reversed.toList();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    String statusBadgeText = 'Belum Ada Skrining';
    if (chronological.isNotEmpty) {
      final latest = chronological.last;
      statusBadgeText = '${latest.title} (${latest.score})';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBCE3F5), // Soft vibrant pastel blue (left)
            Color(0xFFE8D5F5), // Soft pastel lavender (center)
            Color(0xFFF9C8D9), // Soft vibrant pastel pink (right)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3142).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                child: Text(
                  'Perkembangan Minggu Ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusBadgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayLabel = days[index];
              if (index < chronological.length) {
                final rec = chronological[index];
                final assetPath = _getEmotAssetForScore(rec.score, rec.title);
                return _buildDayMoodAsset(
                  dayLabel,
                  assetPath,
                  true,
                  rec.score,
                  rec.title,
                );
              } else {
                return _buildDayMoodAsset(dayLabel, null, false, 0, '');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMoodAsset(
    String day,
    String? assetPath,
    bool isCompleted,
    int score,
    String title,
  ) {
    return Column(
      children: [
        Tooltip(
          message: isCompleted ? '$title ($score/100)' : 'Belum ada skrining',
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.surfaceCard
                  : AppColors.surfaceCanvas,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? AppColors.primaryContainer
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: isCompleted && assetPath != null
                ? ClipOval(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.sentiment_satisfied_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.outlineVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isCompleted ? AppColors.onSurface : AppColors.outline,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // --- Settings List Card ---
  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3142).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.manage_accounts_rounded,
            iconColor: AppColors.primary,
            title: 'Pusat Akun',
            subtitle: 'Ganti nama, kata sandi, & data profil',
            onTap: _showAccountCenterModal,
          ),

          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            iconColor: AppColors.secondary,
            title: 'Preferensi Notifikasi',
            subtitle: 'Pengingat jurnal & meditasi harian',
            onTap: _showNotificationModal,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
          _buildSettingsTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.tertiary,
            title: 'Keamanan & Biometrik',
            subtitle: 'Kunci aplikasi dengan sidik jari',
            onTap: _showBiometricModal,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.secondary,
            title: 'Bahasa Aplikasi',
            subtitle: 'Bahasa Indonesia (Utama)',
            onTap: _showLanguageInfoModal,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.outline,
            title: 'Bantuan & Dukungan',
            subtitle: 'Pusat bantuan & layanan darurat',
            onTap: _showHelpModal,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primary,
            title: 'Tentang MindCare',
            subtitle: 'Versi aplikasi, visi & misi ruang aman',
            onTap: _showAboutMindCareModal,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.outline,
      ),
    );
  }

  // --- Logout Button ---
  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _showLogoutConfirmation,
      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
      label: Text(
        'Keluar dari Akun',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }
}
