import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/views/hasil_skrining_screen.dart';

class KuesionerScreeningScreen extends StatefulWidget {
  const KuesionerScreeningScreen({super.key});

  @override
  State<KuesionerScreeningScreen> createState() =>
      _KuesionerScreeningScreenState();
}

class _KuesionerScreeningScreenState extends State<KuesionerScreeningScreen> {
  int _currentIndex = 0;

  final List<String> _questions = [
    'Seberapa sering kamu merasa sulit untuk bersantai atau merasa tenang dalam seminggu terakhir?',
    'Seberapa sering kamu merasa cemas, gelisah, atau merasa ada hal buruk yang akan terjadi?',
    'Apakah kamu merasa kurang berenergi, mudah lelah, atau tidak bersemangat menjalani aktivitas harian?',
    'Seberapa sering kamu mengalami kesulitan tidur, sering terbangun di malam hari, atau tidur berlebihan?',
    'Apakah kamu merasa kesulitan untuk berkonsentrasi pada hal-hal seperti membaca, belajar, atau bekerja?',
    'Seberapa sering kamu merasa tertekan, murung, atau merasa putus asa tentang masa depan?',
    'Apakah kamu merasa kehilangan minat atau kesenangan dalam melakukan hal-hal yang biasanya kamu sukai?',
    'Seberapa sering kamu merasa mudah marah, tersinggung, atau tidak sabar menghadapi situasi kecil?',
    'Apakah kamu merasa ragu pada kemampuan dirimu sendiri atau merasa bersalah secara berlebihan?',
    'Seberapa sering kamu merasa kewalahan dengan beban pikiran dan tuntutan sehari-hari?',
    'Apakah kamu sering mengalami gejala fisik seperti jantung berdebar kencang, pusing, atau sesak napas saat tertekan?',
    'Seberapa sering kamu merasa kesepian atau merasa tidak ada orang yang memahami perasaanmu?',
    'Apakah kamu merasa sulit untuk memulai atau menyelesaikan tugas-tugas penting karena menunda-nunda?',
    'Seberapa sering kamu merasa takut atau panik tanpa alasan yang jelas?',
    'Apakah kamu merasa nafsu makanmu berubah drastis (makan jauh lebih sedikit atau jauh lebih banyak dari biasanya)?',
    'Seberapa sering kamu merasa pikiranmu terus berputar tanpa henti (overthinking) terutama di malam hari?',
    'Apakah kamu merasa tidak berdaya atau sulit mengendalikan hal-hal penting dalam hidupmu?',
    'Seberapa sering kamu merasa enggan untuk berinteraksi sosial atau menarik diri dari teman dan keluarga?',
    'Apakah kamu merasa suasana hatimu berubah-ubah dengan sangat cepat dan tidak terduga?',
    'Seberapa sering kamu merasa bangga, bersyukur, dan optimis terhadap dirimu sendiri akhir-akhir ini?',
  ];

  final List<Map<String, dynamic>> _options = [
    {'text': 'Tidak Pernah', 'score': 0},
    {'text': 'Kadang-kadang', 'score': 1},
    {'text': 'Sering', 'score': 2},
    {'text': 'Selalu', 'score': 3},
  ];

  // Store user answers: question index -> selected option index
  final Map<int, int> _answers = {};

  void _selectOption(int optionIndex) {
    setState(() {
      _answers[_currentIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (!_answers.containsKey(_currentIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih salah satu jawaban terlebih dahulu.'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResultDialog();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Batalkan Skrining?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Progres pengisian kuesioner Anda saat ini tidak akan tersimpan jika Anda keluar.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Lanjutkan', style: GoogleFonts.plusJakartaSans(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.maybePop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog() {
    int totalScore = 0;
    _answers.forEach((key, value) {
      totalScore += (_options[value]['score'] as int);
    });

    // Convert raw score (0-30) to wellness scale (0-100)
    // Low stress (0 raw score) = 95 wellness; High stress (30 raw score) = 35 wellness
    final int maxRaw = _questions.length * 3;
    final int wellnessScore = (100 - ((totalScore / maxRaw) * 75)).round().clamp(25, 95);

    final String category = wellnessScore >= 75
        ? 'Sangat Baik'
        : wellnessScore >= 50
            ? 'Stres Ringan'
            : 'Butuh Perhatian';
    final Color scoreColor = wellnessScore >= 75
        ? AppColors.secondary
        : wellnessScore >= 50
            ? AppColors.tertiary
            : AppColors.error;
    final Color bgColor = wellnessScore >= 75
        ? AppColors.secondaryContainer
        : wellnessScore >= 50
            ? AppColors.tertiaryContainer
            : AppColors.errorContainer;
    final String imageUrl = wellnessScore >= 75
        ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuAD0xZM5CV0Z_4RpRFRQoub2kd51IOVm_WsspJKkZoBRRYRhk8lmLLHhAaksl7E6BdIXPrQ6zGAopmCE71llnm1VD00FOn2HcuUV7GY2K5kdaYRIcMCkdErQWs1yEq9ULH6uE62Rdhf6LipJ-nYPHYE2QcCFR_jX-Z5B_ps_-SMN5BzABSKFp7bTdMT_haqSHxDG3l9u5jmw55ubypNln296gLmoDupZsJvMqSTlLFM9cytzOVz14JL7S56UW10tgRP-VY'
        : wellnessScore >= 50
            ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBUD8y86yr3Iby6BIRJpr3nuL0uriCU1ZZIUR_Pen-a4ZEozm8tDnQ-rmCtYUgd7F0fHncgT5tMFJp_CXHZCmBp4pzOz3J6ukWb5aefHP8s_wfDFzh3hCHcX1Pn8W1xCFHWEk1-g6Kondm2a-aWzWqdnqizrb0Cp9qjtgOUVXDBsOVDuOEAE4xnLTVeu1DobT9Lx7hP5oZQB0IWoEitqLmS_B7iQGutGnDMRNEBcBdjrTF4rgTfVOpnfdqyuX5o6YQz2PA'
            : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrKQ7cDsFv9FHsaCLI1xjQx7Odrg5JoRmBlXx-qBsXDVYVBLSlU7aIGpuhmCBvu-1jdCY-CI8fp3rR7UW5mZpEVrR1k864yBteVkLUZoKKMmTd4ziF-ukiXNQ3SYaop9nKs-4rw2tYcbrbeEgkIhKGb6UeCfEtFonw3gzEauZu8-x9Dzphy2fRHrjraI51CyYIDxAWIrP5FbrA7fcOdBKEHm-KncXXVSnGe99ttanBjah3Q1TJrmBDcowaIBW5Lv7dcKY';

    final currentUser = AppStateService.instance.userProfile;
    AppStateService.instance.addScreeningRecord(
      ScreeningRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userEmail: currentUser.email,
        userName: currentUser.name,
        title: category,
        date: 'Hari ini, ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} WIB',
        score: wellnessScore,
        color: scoreColor,
        bg: bgColor,
        image: imageUrl,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HasilSkriningScreen(
          score: wellnessScore,
          totalQuestions: _questions.length,
          answeredCount: _answers.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentIndex + 1) / _questions.length;
    final int? selectedOption = _answers[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header with Close & Progress
            _buildHeader(progress),

            // 2. Main Question & Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Title
                    Text(
                      _questions[_currentIndex],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Options List
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final bool isSelected = selectedOption == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: GestureDetector(
                          onTap: () => _selectOption(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceVariant,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.primaryContainer.withOpacity(0.2)
                                      : const Color(0xFF2D3142).withOpacity(0.03),
                                  blurRadius: isSelected ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  option['text'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.onPrimaryContainer
                                        : AppColors.onSurface,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primaryContainer,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 3. Bottom Footer Navigation (Sebelumnya & Selanjutnya)
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              GestureDetector(
                onTap: _confirmExit,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D3142).withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.onSurface,
                    size: 20,
                  ),
                ),
              ),

              // Progress Text
              Text(
                'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(width: 40), // Spacer for centering
            ],
          ),
          const SizedBox(height: 16),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  // --- Footer Controls ---
  Widget _buildFooter() {
    final bool hasPrev = _currentIndex > 0;
    final bool isLast = _currentIndex == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.6)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          OutlinedButton(
            onPressed: hasPrev ? _previousQuestion : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              disabledForegroundColor: AppColors.outlineVariant,
              side: BorderSide(
                color: hasPrev ? AppColors.outline : AppColors.outlineVariant.withOpacity(0.4),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Sebelumnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Next / Submit Button
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              elevation: 2,
              shadowColor: AppColors.primaryContainer.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              isLast ? 'Lihat Hasil' : 'Selanjutnya',
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
}
