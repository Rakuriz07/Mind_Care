import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/views/login_screen.dart';

class PsychologistDashboardScreen extends StatefulWidget {
  const PsychologistDashboardScreen({super.key});

  @override
  State<PsychologistDashboardScreen> createState() => _PsychologistDashboardScreenState();
}

class _PsychologistDashboardScreenState extends State<PsychologistDashboardScreen> {
  int _currentTab = 0;

  void _showPatientDetailModal(PsychologistAppointment appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(appt.patientAvatar),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.patientName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '${appt.patientAge} • Pasien Konsultasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Skor: ${appt.screeningScore}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.surfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Keluhan Pasien & Hasil Skrining:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                appt.issueSummary,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${appt.date} • ${appt.time}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showPrescriptionDialog(appt);
                      },
                      icon: const Icon(Icons.note_alt_outlined, size: 16),
                      label: const Text('Catat Rekam Medis'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        AppStateService.instance.updateAppointmentStatus(appt.id, 'Completed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sesi dengan ${appt.patientName} berhasil diselesaikan!')),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Selesaikan Sesi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrescriptionDialog(PsychologistAppointment appt) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Catatan Medis & Rekomendasi Terapi',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pasien: ${appt.patientName} (${appt.screeningCategory})',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan diagnosis, anjuran CBT, atau rencana tindak lanjut...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceCanvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan rekam medis berhasil disimpan ke database! ✨'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan Rekam Medis'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final profile = AppStateService.instance.userProfile;
        final appointments = AppStateService.instance.appointments;

        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Doctor Top Header
                _buildDoctorHeader(profile),

                // 2. Main Content Views
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bento Statistics Overview
                        _buildDoctorStatsBento(appointments),
                        const SizedBox(height: 20),

                        // Section Tabs (Jadwal Konsultasi, Rekam Medis, Atur Praktik)
                        _buildSectionHeader(),
                        const SizedBox(height: 14),

                        // Appointments List Cards
                        if (_currentTab == 0)
                          _buildAppointmentsTab(appointments)
                        else if (_currentTab == 1)
                          _buildPatientDirectoryTab(appointments)
                        else
                          _buildPracticeSettingsTab(profile),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // --- Top Doctor Header ---
  Widget _buildDoctorHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(profile.avatarUrl),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: profile.isOnlineAccepting ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
                    ],
                  ),
                  Text(
                    '${profile.specialization} • ${profile.licenseNumber}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Online / Offline Toggle
          IconButton(
            onPressed: () {
              AppStateService.instance.toggleOnlineAccepting();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    profile.isOnlineAccepting ? 'Status praktik diubah ke Istirahat' : 'Status praktik diubah ke Online',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              profile.isOnlineAccepting ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              size: 36,
              color: profile.isOnlineAccepting ? AppColors.secondary : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  // --- Doctor Stats Bento ---
  Widget _buildDoctorStatsBento(List<PsychologistAppointment> appointments) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Jadwal Hari Ini',
            value: '${appointments.length} Sesi',
            icon: Icons.calendar_today_rounded,
            color: AppColors.primary,
            bgColor: AppColors.softPink.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Pasien Aktif',
            value: '142 Orang',
            icon: Icons.people_outline_rounded,
            color: AppColors.secondary,
            bgColor: AppColors.softMint.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Kepuasan',
            value: '⭐ 4.9',
            icon: Icons.star_rate_rounded,
            color: AppColors.tertiary,
            bgColor: AppColors.softSunshine.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // --- Section Tabs Header ---
  Widget _buildSectionHeader() {
    final tabs = ['Jadwal Konsultasi', 'Daftar Pasien', 'Pengaturan Praktik'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _currentTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tabs[index]),
              selected: isSelected,
              onSelected: (_) => setState(() => _currentTab = index),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceCard,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }),
      ),
    );
  }

  // --- Tab 0: Appointments Tab ---
  Widget _buildAppointmentsTab(List<PsychologistAppointment> appointments) {
    return Column(
      children: appointments.map((appt) {
        final isCompleted = appt.status == 'Completed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(appt.patientAvatar),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.patientName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            appt.consultationType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.surfaceVariant
                          : AppColors.softPink.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? 'Selesai' : appt.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.outline : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                appt.issueSummary,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showPatientDetailModal(appt),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Detail & Rekam Medis', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isCompleted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Membuka ruang konsultasi dengan ${appt.patientName}...'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.video_camera_front_rounded, size: 16),
                        label: const Text('Mulai Sesi', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Tab 1: Patient Directory Tab ---
  Widget _buildPatientDirectoryTab(List<PsychologistAppointment> appointments) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari riwayat nama pasien...',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...appointments.map((appt) {
          return ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: CircleAvatar(backgroundImage: NetworkImage(appt.patientAvatar)),
            title: Text(appt.patientName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Kategori: ${appt.screeningCategory} (Skor: ${appt.screeningScore})', style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.outline),
            onTap: () => _showPatientDetailModal(appt),
          );
        }),
      ],
    );
  }

  // --- Tab 2: Practice Settings Tab ---
  Widget _buildPracticeSettingsTab(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan Tarif & Lokasi Praktik', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildSettingRow('Tarif Konsultasi', profile.consultationFee, Icons.payments_outlined),
          const Divider(height: 20),
          _buildSettingRow('Pengalaman', profile.experienceYears, Icons.work_outline),
          const Divider(height: 20),
          _buildSettingRow('Nomor SIPP', profile.licenseNumber, Icons.verified_user_outlined),
          const Divider(height: 20),
          _buildSettingRow('Faskes Utama', 'RS Jiwa Menur & Klinik MindCare', Icons.local_hospital_outlined),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AppStateService.instance.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              label: const Text('Keluar dari Akun Psikolog', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Bottom Navigation ---
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (index) => setState(() => _currentTab = index),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.outline,
      backgroundColor: AppColors.surfaceCard,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal Sesi'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Daftar Pasien'),
        BottomNavigationBarItem(icon: Icon(Icons.medical_information_rounded), label: 'Klinik & Profil'),
      ],
    );
  }
}
