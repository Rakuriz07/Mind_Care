import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/meditasi_tidur_screen.dart';

class TipsTidurNyenyakScreen extends StatefulWidget {
  const TipsTidurNyenyakScreen({super.key});

  @override
  State<TipsTidurNyenyakScreen> createState() => _TipsTidurNyenyakScreenState();
}

class _TipsTidurNyenyakScreenState extends State<TipsTidurNyenyakScreen> {
  // Checklist states
  final List<Map<String, dynamic>> _checklistItems = [
    {
      'title': 'Matikan Gadget (30 mnt sebelum)',
      'icon': Icons.smartphone_rounded,
      'isChecked': false,
    },
    {
      'title': 'Redupkan Lampu Kamar',
      'icon': Icons.lightbulb_rounded,
      'isChecked': false,
    },
    {
      'title': 'Latihan Pernapasan Relaksasi',
      'icon': Icons.air_rounded,
      'isChecked': false,
    },
    {
      'title': 'Minum Air Hangat/Teh Herbal',
      'icon': Icons.local_cafe_rounded,
      'isChecked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Fixed Top Bar / Header
            _buildHeader(context),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    const SizedBox(height: 24),

                    // Interactive Checklist Section
                    _buildChecklistSection(),
                    const SizedBox(height: 24),

                    // Tips Tidur Berkualitas Section
                    _buildTipsSection(),
                    const SizedBox(height: 32),

                    // Footer CTA Section
                    _buildFooterCTA(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Bar ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 24,
            ),
            splashRadius: 24,
          ),
          Text(
            'Tips Tidur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Section ---
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.15),
            AppColors.softMint.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.03),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bedtime_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep Hygiene',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kebiasaan sederhana untuk tidur yang lebih lelap dan berkualitas.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Interactive Checklist Section ---
  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rutinitas Sebelum Tidur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(_checklistItems.length, (index) {
            final item = _checklistItems[index];
            final bool isChecked = item['isChecked'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _checklistItems[index]['isChecked'] = !isChecked;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.white,
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(45, 49, 66, 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1.5,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _checklistItems[index]['isChecked'] = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['title'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isChecked
                                ? AppColors.onSurface.withValues(alpha: 0.5)
                                : AppColors.onSurface,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      Icon(
                        item['icon'],
                        color: isChecked
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.outlineVariant,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Tips Tidur Berkualitas Section ---
  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips Tidur Berkualitas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            // Tip 1: Atur Suhu Ruangan
            _buildTipCard(
              title: 'Atur Suhu Ruangan',
              subtitle: '18-22°C ideal untuk tidur nyenyak.',
              icon: Icons.thermostat_rounded,
              iconBgColor: AppColors.softMint.withValues(alpha: 0.2),
              iconColor: AppColors.secondary,
            ),
            const SizedBox(height: 12),

            // Tip 2: Jadwal Konsisten
            _buildTipCard(
              title: 'Jadwal Konsisten',
              subtitle: 'Bangun dan tidur di jam yang sama.',
              icon: Icons.schedule_rounded,
              iconBgColor: AppColors.softSunshine.withValues(alpha: 0.3),
              iconColor: AppColors.tertiary,
            ),
            const SizedBox(height: 12),

            // Tip 3: Batasi Kafein
            _buildTipCard(
              title: 'Batasi Kafein',
              subtitle:
                  'Hindari kopi setelah jam 2 siang agar tidak mengganggu hormon kantuk.',
              icon: Icons.no_drinks_rounded,
              iconBgColor: AppColors.error.withValues(alpha: 0.1),
              iconColor: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Footer CTA Section ---
  Widget _buildFooterCTA() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MeditasiTidurScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.headphones_rounded, size: 18),
        label: Text(
          'Mulai Meditasi Tidur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
