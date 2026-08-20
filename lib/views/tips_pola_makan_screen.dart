import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class TipsPolaMakanScreen extends StatelessWidget {
  const TipsPolaMakanScreen({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    const SizedBox(height: 24),

                    // Mascot & Gut-Brain Axis Section
                    _buildGutBrainSection(),
                    const SizedBox(height: 24),

                    // Makanan Pereda Stres (Bento Grid)
                    _buildStressReliefFoodsSection(),
                    const SizedBox(height: 24),

                    // Tips Hidrasi Section
                    _buildHydrationTipsSection(),
                    const SizedBox(height: 24),

                    // Pola Makan Mindful Section
                    _buildMindfulEatingSection(),
                    const SizedBox(height: 32),
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
        color: AppColors.surfaceCanvas.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceVariant.withOpacity(0.5),
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
            'Tips Pola Makan',
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

  // --- 1. Hero Section ---
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withOpacity(0.3),
            AppColors.softMint.withOpacity(0.3),
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
      child: Stack(
        children: [
          // Background Decorative Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Opacity(
                opacity: 0.25,
                child: Image.network(
                  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryContainer.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Content Layer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nutrisi untuk Pikiran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pola Makan & Kesehatan Mental',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jelajahi bagaimana makanan yang Anda konsumsi dapat menjadi pelukan hangat bagi pikiran Anda.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.4,
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

  // --- 2. Mascot & Gut-Brain Section ---
  Widget _buildGutBrainSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mascot Avatar Image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.softPink,
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.softPink.withOpacity(0.3),
                  child: const Icon(
                    Icons.face_retouching_natural,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hubungan Usus & Otak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tahukah Anda? Usus Anda memproduksi 90% serotonin (hormon bahagia). Makanan bergizi membantu menjaga keseimbangan ini, mengurangi stres dan kecemasan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.45,
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

  // --- 3. Makanan Pereda Stres (Bento Grid) ---
  Widget _buildStressReliefFoodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.softPink,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Makanan Pereda Stres',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2x2 Bento Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
          children: [
            _buildBentoCard(
              icon: Icons.cookie_outlined,
              iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.25),
              iconColor: AppColors.primary,
              title: 'Dark Chocolate',
              description: 'Kaya magnesium untuk relaksasi otot dan pikiran.',
            ),
            _buildBentoCard(
              icon: Icons.local_cafe,
              iconBgColor: AppColors.softMint.withValues(alpha: 0.4),
              iconColor: AppColors.secondary,
              title: 'Green Tea',
              description: 'L-theanine membantu meningkatkan fokus dan ketenangan.',
            ),
            _buildBentoCard(
              icon: Icons.set_meal,
              iconBgColor: AppColors.softSunshine.withValues(alpha: 0.4),
              iconColor: AppColors.tertiary,
              title: 'Ikan Berlemak',
              description: 'Omega-3 sangat penting untuk kesehatan otak jangka panjang.',
            ),
            _buildBentoCard(
              icon: Icons.blender,
              iconBgColor: AppColors.surfaceContainerHigh,
              iconColor: AppColors.onSurfaceVariant,
              title: 'Makanan Fermentasi',
              description: 'Probiotik untuk mendukung poros usus-otak yang sehat.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.35,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Tips Hidrasi Section ---
  Widget _buildHydrationTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.softMint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softMint.withOpacity(0.5),
          width: 1.5,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips Hidrasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Dehidrasi ringan dapat memengaruhi suasana hati dan konsentrasi. Usahakan minum air putih yang cukup sepanjang hari.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHydrationPill(
                iconColor: AppColors.secondary,
                label: 'Air Putih (8 Gelas)',
              ),
              _buildHydrationPill(
                iconColor: AppColors.primary,
                label: 'Teh Herbal (Chamomile)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationPill({
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: iconColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Pola Makan Mindful Section ---
  Widget _buildMindfulEatingSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.self_improvement,
                color: AppColors.tertiary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Pola Makan Mindful',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMindfulListItem(
            icon: Icons.restaurant,
            text: 'Makanlah dengan perlahan, nikmati setiap gigitan dan tekstur makanan.',
          ),
          const SizedBox(height: 14),
          _buildMindfulListItem(
            icon: Icons.phone_disabled,
            text: 'Hindari distraksi seperti ponsel atau TV saat sedang bersantap.',
          ),
          const SizedBox(height: 14),
          _buildMindfulListItem(
            icon: Icons.psychology,
            text: 'Dengarkan isyarat lapar dan kenyang dari tubuh Anda dengan penuh perhatian.',
          ),
        ],
      ),
    );
  }

  Widget _buildMindfulListItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
