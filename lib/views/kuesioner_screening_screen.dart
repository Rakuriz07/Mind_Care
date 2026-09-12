import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/controllers/screening_controller.dart';
import 'package:mindcare/views/hasil_skrining_screen.dart';

class KuesionerScreeningScreen extends StatefulWidget {
  const KuesionerScreeningScreen({super.key});

  @override
  State<KuesionerScreeningScreen> createState() =>
      _KuesionerScreeningScreenState();
}

class _KuesionerScreeningScreenState extends State<KuesionerScreeningScreen> {
  final ScreeningController _controller = ScreeningController.instance;

  @override
  void initState() {
    super.initState();
    _controller.resetScreening();
  }

  void _onNextPressed() async {
    if (!_controller.isCurrentQuestionAnswered) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final mediaQuery = MediaQuery.of(context);
      final topPadding = mediaQuery.padding.top;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Silakan pilih salah satu jawaban terlebih dahulu.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.up,
          margin: EdgeInsets.only(
            bottom: mediaQuery.size.height - topPadding - 110,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    if (_controller.isLastQuestion) {
      final record = await _controller.completeScreening();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HasilSkriningScreen(
            score: record.score,
            totalQuestions: _controller.totalQuestions,
            answeredCount: _controller.answeredCount,
          ),
        ),
      );
    } else {
      _controller.nextQuestion();
    }
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Batalkan Skrining?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Progres pengisian kuesioner Anda saat ini tidak akan tersimpan jika Anda keluar.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Lanjutkan',
                style: GoogleFonts.plusJakartaSans(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.resetScreening();
                Navigator.pop(context);
                Navigator.maybePop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final progress = _controller.progress;
        final selectedOption = _controller.currentSelectedOptionIndex;
        final questionText = _controller.currentQuestion;
        final options = _controller.options;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Title
                        Text(
                          questionText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Options List
                        ...List.generate(options.length, (index) {
                          final option = options[index];
                          final bool isSelected = selectedOption == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: GestureDetector(
                              onTap: () => _controller.selectOption(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
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
                                          ? AppColors.primaryContainer
                                                .withValues(alpha: 0.2)
                                          : const Color(
                                              0xFF2D3142,
                                            ).withValues(alpha: 0.03),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      option.text,
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

                // 3. Bottom Footer Navigation
                _buildFooter(),
              ],
            ),
          ),
        );
      },
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
                        color: const Color(0xFF2D3142).withValues(alpha: 0.04),
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
                'Pertanyaan ${_controller.currentQuestionIndex + 1} dari ${_controller.totalQuestions}',
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Footer Controls ---
  Widget _buildFooter() {
    final bool hasPrev = _controller.hasPreviousQuestion;
    final bool isLast = _controller.isLastQuestion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          OutlinedButton(
            onPressed: hasPrev ? _controller.previousQuestion : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              disabledForegroundColor: AppColors.outlineVariant,
              side: BorderSide(
                color: hasPrev
                    ? AppColors.outline
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
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
            onPressed: _onNextPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              elevation: 2,
              shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
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
