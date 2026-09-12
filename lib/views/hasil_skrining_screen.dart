import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/daftar_jurnal_screen.dart';
import 'package:mindcare/views/game_relaksasi_screen.dart';
import 'package:mindcare/views/history_screen.dart';
import 'package:mindcare/views/meditasi_tidur_screen.dart';
import 'package:mindcare/views/tips_pola_makan_screen.dart';

class HasilSkriningScreen extends StatelessWidget {
  final int score; // 0 - 100 scale (or converted from raw points)
  final int totalQuestions;
  final int answeredCount;

  const HasilSkriningScreen({
    super.key,
    this.score = 85,
    this.totalQuestions = 10,
    this.answeredCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic mood data mapping based on score
    final String headline;
    final String description;
    final String moodImageUrl;
    final Color scoreColor;
    final Color pulseGlowColor;
    final List<Map<String, dynamic>> recommendations;

    if (score >= 75) {
      // Condition: Healthy / Senang
      headline = 'Hasil Skrining Kamu: Sangat Baik';
      description =
          'Berdasarkan jawabanmu, kondisi mentalmu saat ini berada dalam rentang yang sehat. Kamu merasa tenang dan mampu mengelola stres dengan baik.';
      moodImageUrl = 'assets/images/senang.png';
      scoreColor = AppColors.secondary;
      pulseGlowColor = AppColors.softSunshine;
      recommendations = [
        {
          'icon': Icons.edit_note_rounded,
          'title': 'Lanjutkan Jurnal Pagi',
          'desc': 'Tuangkan pikiranmu untuk jaga fokus.',
          'bg': AppColors.primaryFixed,
          'iconColor': AppColors.primary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DaftarJurnalScreen()),
          ),
        },
        {
          'icon': Icons.sports_esports_rounded,
          'title': 'Game Relaksasi',
          'desc': 'Mainkan mini game pereda cemas & stres.',
          'bg': AppColors.secondaryContainer,
          'iconColor': AppColors.secondary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameRelaksasiScreen(),
            ),
          ),
        },
      ];
    } else if (score >= 55) {
      // Condition: Mild Stress / Cemas
      headline = 'Hasil Skrining Kamu: Perlu Relaksasi';
      description =
          'Kamu mungkin sedang mengalami sedikit beban pikiran atau kecemasan akhir-akhir ini. Luangkan waktu untuk mengatur pernapasan dan istirahat.';
      moodImageUrl = 'assets/images/cemas.png';
      scoreColor = AppColors.tertiary;
      pulseGlowColor = AppColors.softMint;
      recommendations = [
        {
          'icon': Icons.air_rounded,
          'title': 'Pernapasan Rileks 4-7-8',
          'desc': 'Turunkan denyut jantung dan rasa cemas.',
          'bg': AppColors.softMint,
          'iconColor': AppColors.secondary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MeditasiTidurScreen(),
            ),
          ),
        },
        {
          'icon': Icons.restaurant_rounded,
          'title': 'Tips Pola Makan',
          'desc': 'Jaga nutrisi usus & kesehatan otak.',
          'bg': AppColors.softSkyBlue,
          'iconColor': AppColors.skyBlueAccent,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TipsPolaMakanScreen(),
            ),
          ),
        },
      ];
    } else if (score >= 35) {
      // Condition: Sadness / Sedih
      headline = 'Hasil Skrining Kamu: Sedang Lelah';
      description =
          'Kamu sedang berada di fase di mana suasana hati merasa sedih dan emosi cukup lelah. Jangan ragu beristirahat dan cerita ke teman terdekat.';
      moodImageUrl = 'assets/images/sedih.png';
      scoreColor = AppColors.primary;
      pulseGlowColor = AppColors.softPink;
      recommendations = [
        {
          'icon': Icons.edit_note_rounded,
          'title': 'Tuliskan Perasaan',
          'desc': 'Luapkan emosi dan pikiran ke jurnal harian.',
          'bg': AppColors.softPink,
          'iconColor': AppColors.primary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DaftarJurnalScreen()),
          ),
        },
        {
          'icon': Icons.sports_esports_rounded,
          'title': 'Game Relaksasi',
          'desc': 'Meletuskan cemas & menyelaraskan napas.',
          'bg': AppColors.softMint,
          'iconColor': AppColors.secondary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameRelaksasiScreen(),
            ),
          ),
        },
      ];
    } else {
      // Condition: Severe Stress / STRESS
      headline = 'Hasil Skrining Kamu: Perlu Perhatian Khusus';
      description =
          'Kondisi mentalmu menunjukkan tingkat stres yang cukup tinggi. Disarankan untuk beristirahat dan melatih relaksasi pernapasan.';
      moodImageUrl = 'assets/images/STRESS.png';
      scoreColor = AppColors.error;
      pulseGlowColor = AppColors.softPink;
      recommendations = [
        {
          'icon': Icons.sports_esports_rounded,
          'title': 'Game Relaksasi Stres',
          'desc': 'Meletuskan cemas & menyelaraskan napas.',
          'bg': AppColors.softPink,
          'iconColor': AppColors.primary,
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameRelaksasiScreen(),
            ),
          ),
        },
      ];
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top AppBar
            _buildAppBar(context),

            // 2. Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    // Result Hero (Emoticon + Headline + Description)
                    _buildResultHero(
                      moodImageUrl,
                      headline,
                      description,
                      pulseGlowColor,
                    ),
                    const SizedBox(height: 24),

                    // Glass Score Gauge Card
                    _buildScoreCard(score, scoreColor),
                    const SizedBox(height: 24),

                    // Bento Recommendations
                    _buildRecommendationsSection(recommendations),
                    const SizedBox(height: 28),

                    // Action Buttons
                    _buildActionButtons(context),
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
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
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
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
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
                const SnackBar(
                  content: Text(
                    'Hasil skrining telah tersimpan ke riwayat profil Anda.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.sentiment_satisfied_alt_rounded,
          size: 80,
          color: AppColors.primary,
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.sentiment_satisfied_alt_rounded,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }

  // --- Result Hero Section ---
  Widget _buildResultHero(
    String imageUrl,
    String headline,
    String description,
    Color glowColor,
  ) {
    return Column(
      children: [
        // Mascot / Mood Emoticon with Glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withValues(alpha: 0.4),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              height: 140,
              child: _buildResultImage(imageUrl),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Headline
        Text(
          headline,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),

        // Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // --- Score Card ---
  Widget _buildScoreCard(int score, Color scoreColor) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.softMint.withValues(alpha: 0.2),
            AppColors.softPink.withValues(alpha: 0.2),
          ],
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
      child: Row(
        children: [
          // Circular Progress Indicator / Score Gauge
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // Score Summary Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor Kesejahteraan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tingkat ketahanan mental dan emosional kamu terukur dari hasil analisis kuesioner terstandar.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Bento Recommendations Section ---
  Widget _buildRecommendationsSection(
    List<Map<String, dynamic>> recommendations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Rekomendasi Hari Ini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: rec['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(45, 49, 66, 0.04),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: rec['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        rec['icon'] as IconData,
                        color: rec['iconColor'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rec['desc'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.outlineVariant,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- Action Buttons ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Lihat Detail di History
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
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
            child: Text(
              'Lihat Detail di History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Kembali ke Beranda
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Kembali ke Beranda',
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
