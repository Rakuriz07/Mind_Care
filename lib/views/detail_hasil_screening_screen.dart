import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/game_relaksasi_screen.dart';
import 'package:mindcare/views/tips_pola_makan_screen.dart';
import 'package:mindcare/views/tulis_jurnal_screen.dart';

class DetailHasilScreeningScreen extends StatefulWidget {
  final int score;
  final String status;
  final String date;

  const DetailHasilScreeningScreen({
    super.key,
    this.score = 85,
    this.status = 'Sangat Baik',
    this.date = 'Hari ini, 08:45 WIB',
  });

  @override
  State<DetailHasilScreeningScreen> createState() =>
      _DetailHasilScreeningScreenState();
}

class _DetailHasilScreeningScreenState
    extends State<DetailHasilScreeningScreen> {
  bool _showAllAnswers = false;

  final List<Map<String, dynamic>> _answerBreakdowns = [
    {
      'question': 'Saya merasa bisa bersantai dan menikmati momen.',
      'answer': 'Sering',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': AppColors.secondary,
      'bg': AppColors.secondaryContainer,
    },
    {
      'question': 'Saya merasa tegang atau cemas tanpa alasan jelas.',
      'answer': 'Kadang-kadang',
      'icon': Icons.sentiment_neutral_rounded,
      'color': AppColors.tertiary,
      'bg': AppColors.softSunshine,
    },
    {
      'question': 'Kualitas tidur saya cukup baik dan menyegarkan.',
      'answer': 'Sering',
      'icon': Icons.bedtime_rounded,
      'color': AppColors.secondary,
      'bg': AppColors.secondaryContainer,
    },
    {
      'question': 'Saya memiliki energi dan motivasi untuk beraktivitas.',
      'answer': 'Selalu',
      'icon': Icons.bolt_rounded,
      'color': AppColors.primary,
      'bg': AppColors.softPink,
    },
    {
      'question': 'Saya merasa mampu mengatasi tekanan pekerjaan/tugas.',
      'answer': 'Sering',
      'icon': Icons.psychology_rounded,
      'color': AppColors.secondary,
      'bg': AppColors.softMint,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final displayedAnswers = _showAllAnswers
        ? _answerBreakdowns
        : _answerBreakdowns.take(3).toList();

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Gauge Card
                    _buildGaugeCard(),
                    const SizedBox(height: 24),

                    // Breakdown Section: Analisis Jawaban
                    _buildBreakdownSection(displayedAnswers),
                    const SizedBox(height: 24),

                    // Recommendations Section
                    _buildRecommendationsSection(),
                    const SizedBox(height: 28),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top AppBar ---
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          Text(
            'Detail Hasil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 48), // spacer
        ],
      ),
    );
  }

  // --- Progress Gauge Card ---
  Widget _buildGaugeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
        children: [
          // Circular Progress with Inner Mascot
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: widget.score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.softMint,
                    ),
                  ),
                ),
                ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAmSQpAfGVUEoJNd94pgCvaBac1N1obz7JL4blLGRJNPzHo671RDHnCktcc7f1zaCFMzzlGyVsQb4nLB6aTh1TEP8qmp6d07DKVZnNQLYWgYBF9ZISTqSfyZwa0GaGFYo0mG1EkLopUDgGwK4giSF0-R7BCC1cQaiVlblcB5KRmrBvd8pqkhrL8B-PQN1iV-0EUbLJcT339yAorZSFYFRzQhZkVnQgLPdeD_f2BS1HCTBx7eqvV4-BiM-lYHG-FKc4dIz8',
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score text
          RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
              children: [
                TextSpan(text: '${widget.score}'),
                TextSpan(
                  text: ' / 100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Narrative Explanation
          Text(
            'Kondisi mental kamu saat ini terlihat sangat positif. Pertahankan rutinitas baikmu dan jangan lupa untuk terus merawat diri.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- Breakdown Section: Analisis Jawaban ---
  Widget _buildBreakdownSection(List<Map<String, dynamic>> answers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisis Jawaban',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...answers.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceVariant.withValues(alpha: 0.8),
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
                    color: (item['bg'] as Color).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['question'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          item['answer'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _showAllAnswers = !_showAllAnswers;
              });
            },
            child: Text(
              _showAllAnswers ? 'Sembunyikan' : 'Lihat Semua Jawaban',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Recommendations Section ---
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi Untukmu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Recommendation 1: Game Relaksasi
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameRelaksasiScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.softPink.withValues(alpha: 0.25),
                        AppColors.softMint.withValues(alpha: 0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(45, 49, 66, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Game Relaksasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '5 Mnt Napas 4-7-8',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Recommendation 2: Tips Nutrisi
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TipsPolaMakanScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.softSunshine.withValues(alpha: 0.25),
                        AppColors.softMint.withValues(alpha: 0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(45, 49, 66, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tips Nutrisi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pemicu Serotonin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Action Buttons ---
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Tulis Refleksi di Jurnal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
              elevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: Text(
              'Tulis Refleksi di Jurnal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Unduh PDF Hasil
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Laporan hasil skrining berhasil diunduh dalam format PDF.',
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.download_rounded, size: 20),
            label: Text(
              'Unduh PDF Hasil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
