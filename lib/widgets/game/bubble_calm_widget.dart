import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class BubbleData {
  final String word;
  final String affirmation;
  final Color color;
  final Alignment alignment;
  bool isPopped;

  BubbleData({
    required this.word,
    required this.affirmation,
    required this.color,
    required this.alignment,
    this.isPopped = false,
  });
}

class BubbleCalmWidget extends StatelessWidget {
  final int peaceScore;
  final int poppedCount;
  final String currentAffirmation;
  final List<BubbleData> bubbles;
  final Function(int) onPopBubble;
  final VoidCallback onReset;

  const BubbleCalmWidget({
    super.key,
    required this.peaceScore,
    required this.poppedCount,
    required this.currentAffirmation,
    required this.bubbles,
    required this.onPopBubble,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Score Header & Affirmation Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Skor Kedamaian: $peaceScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$poppedCount meletus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softSunshine.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentAffirmation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Floating Bubble Arena
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Stack(
              children: bubbles.asMap().entries.map((entry) {
                final index = entry.key;
                final bubble = entry.value;

                return Align(
                  alignment: bubble.alignment,
                  child: GestureDetector(
                    onTap: () => onPopBubble(index),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: bubble.isPopped ? 1.4 : 1.0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: bubble.isPopped ? 0.0 : 1.0,
                        child: Container(
                          width: 88,
                          height: 88,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bubble.color.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: bubble.color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.touch_app_rounded,
                                  size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(height: 2),
                              Text(
                                bubble.word,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Reset Button
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Reset Game Bubble'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            side: const BorderSide(color: AppColors.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
