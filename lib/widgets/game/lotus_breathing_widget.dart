import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class LotusBreathingWidget extends StatelessWidget {
  final bool isBreathingActive;
  final int breathingStep;
  final int breathSecond;
  final int completedCycles;
  final AnimationController lotusAnimController;
  final VoidCallback onToggleBreathing;

  const LotusBreathingWidget({
    super.key,
    required this.isBreathingActive,
    required this.breathingStep,
    required this.breathSecond,
    required this.completedCycles,
    required this.lotusAnimController,
    required this.onToggleBreathing,
  });

  @override
  Widget build(BuildContext context) {
    String stepTitle = 'Siap Dimulai';
    String stepInstruction = 'Tekan Mulai untuk menyelaraskan napas 4-7-8';
    Color stepColor = AppColors.primary;

    if (isBreathingActive) {
      if (breathingStep == 0) {
        stepTitle = 'Tarik Napas... 🫁';
        stepInstruction = 'Hirup udara segar perlahan melalui hidung (${4 - breathSecond} detik)';
        stepColor = AppColors.secondary;
      } else if (breathingStep == 1) {
        stepTitle = 'Tahan Napas... ⏳';
        stepInstruction = 'Tahan napas Anda dengan tenang (${7 - breathSecond} detik)';
        stepColor = AppColors.tertiary;
      } else if (breathingStep == 2) {
        stepTitle = 'Hembuskan Napas... 🍃';
        stepInstruction = 'Lepaskan napas perlahan melalui mulut (${8 - breathSecond} detik)';
        stepColor = AppColors.primary;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Breathing Step Info Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            children: [
              Text(
                stepTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: stepColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepInstruction,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Siklus Selesai: $completedCycles kali',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Animated Lotus Circle
        AnimatedBuilder(
          animation: lotusAnimController,
          builder: (context, child) {
            final scale = 1.0 + (lotusAnimController.value * 0.45);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      stepColor.withValues(alpha: 0.35),
                      AppColors.softMint.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: stepColor.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      size: 56,
                      color: stepColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const Spacer(),

        // Control Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onToggleBreathing,
            icon: Icon(isBreathingActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(isBreathingActive ? 'Hentikan Sesi Napas' : 'Mulai Sesi Napas Relaksasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBreathingActive ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
