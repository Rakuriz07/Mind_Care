import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class AffirmationCardWidget extends StatelessWidget {
  final Map<String, String> card;
  final bool isCardFlipped;
  final int currentCardIndex;
  final int totalCards;
  final VoidCallback onFlipCard;
  final VoidCallback onPreviousCard;
  final VoidCallback onNextCard;

  const AffirmationCardWidget({
    super.key,
    required this.card,
    required this.isCardFlipped,
    required this.currentCardIndex,
    required this.totalCards,
    required this.onFlipCard,
    required this.onPreviousCard,
    required this.onNextCard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sentuh Kartu untuk Membuka Pesan Kedamaian 🌸',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),

        // Flip Card Widget
        GestureDetector(
          onTap: onFlipCard,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: double.infinity,
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCardFlipped
                    ? [AppColors.softSunshine, AppColors.softMint]
                    : [AppColors.surfaceCard, AppColors.surfaceCanvas],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCardFlipped ? AppColors.primary : AppColors.outlineVariant,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card['icon']!,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card['category']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isCardFlipped ? card['quote']! : 'Tap untuk Membuka "${card['title']!}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isCardFlipped ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Navigation Buttons for Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPreviousCard,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Sebelumnya'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Text(
              '${currentCardIndex + 1} / $totalCards',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onNextCard,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Selanjutnya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
