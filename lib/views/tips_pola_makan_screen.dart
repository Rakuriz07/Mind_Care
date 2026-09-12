import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindcare/constants/app_colors.dart';

class TipsPolaMakanScreen extends StatefulWidget {
  const TipsPolaMakanScreen({super.key});

  @override
  State<TipsPolaMakanScreen> createState() => _TipsPolaMakanScreenState();
}

class _TipsPolaMakanScreenState extends State<TipsPolaMakanScreen> {
  // Tracker Hidrasi State
  int _waterGlasses = 0;
  final int _targetGlasses = 8;

  // Filter Kategori
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Tracker Air',
    'Pereda Stres',
    'Menu Harian',
    'Pantangan',
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyWaterIntake();
  }

  /// Memuat data hidrasi hari ini. Jika tanggal berganti, otomatis reset ke 0.
  Future<void> _loadDailyWaterIntake() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final lastSavedDate = prefs.getString('last_water_date');

      if (lastSavedDate != todayStr) {
        // Hari baru! Reset tracker ke 0
        await prefs.setString('last_water_date', todayStr);
        await prefs.setInt('water_glasses_count', 0);
        if (mounted) {
          setState(() {
            _waterGlasses = 0;
          });
        }
      } else {
        // Hari yang sama, ambil data tersimpan
        final savedCount = prefs.getInt('water_glasses_count') ?? 0;
        if (mounted) {
          setState(() {
            _waterGlasses = savedCount;
          });
        }
      }
    } catch (_) {
      // Fallback jika terjadi kendala akses penyimpanan
    }
  }

  /// Menyimpan progress gelas air ke penyimpanan lokal
  Future<void> _saveWaterIntake(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_water_date', todayStr);
      await prefs.setInt('water_glasses_count', count);
    } catch (_) {}
  }

  void _toggleWaterGlass(int index) {
    int newCount = 0;
    // Jika menekan gelas aktif paling akhir, batalkan 1 gelas (koreksi jika salah pencet)
    if (index + 1 == _waterGlasses) {
      newCount = index;
    } else if (index < _waterGlasses) {
      newCount = index;
    } else {
      newCount = index + 1;
    }
    setState(() {
      _waterGlasses = newCount;
    });
    _saveWaterIntake(newCount);

    if (_waterGlasses == _targetGlasses) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selamat! Target hidrasi 8 gelas air (2.000 ml) hari ini telah tercapai!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            _buildHeader(context),

            // 2. Body Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Banner
                    _buildHeroSection(),
                    const SizedBox(height: 20),

                    // Filter Kategori Horizontal Chips
                    _buildCategoryFilterChips(),
                    const SizedBox(height: 20),

                    // Condition Content based on Filter
                    if (_selectedCategoryIndex == 0 ||
                        _selectedCategoryIndex == 1) ...[
                      _buildInteractiveWaterTracker(),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedCategoryIndex == 0 ||
                        _selectedCategoryIndex == 2) ...[
                      _buildGutBrainSection(),
                      const SizedBox(height: 24),
                      _buildStressReliefFoodsSection(),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedCategoryIndex == 0 ||
                        _selectedCategoryIndex == 3) ...[
                      _buildMealPlanSection(),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedCategoryIndex == 0 ||
                        _selectedCategoryIndex == 4) ...[
                      _buildFoodsToLimitSection(),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedCategoryIndex == 0) ...[
                      _buildMindfulEatingSection(),
                      const SizedBox(height: 32),
                    ],
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
        color: AppColors.surfaceCanvas,
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
            'Tips Pola Makan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Banner ---
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.4),
            AppColors.softMint.withValues(alpha: 0.35),
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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Opacity(
                opacity: 0.2,
                child: Image.network(
                  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nutrisi & Kesehatan Mental',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Makanan adalah Obat Bagi Pikiran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ketahui apa yang perlu dikonsumsi dan dibatasi untuk menjaga hormon stres tetap stabil sepanjang hari.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
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

  // --- Filter Category Chips ---
  Widget _buildCategoryFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceCard,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                width: 1,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }

  // --- 1. Interactive Water Intake Tracker ---
  Widget _buildInteractiveWaterTracker() {
    final double progress = (_waterGlasses / _targetGlasses).clamp(0.0, 1.0);
    final int totalMl = _waterGlasses * 250;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.softMint.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracker Hidrasi Harian',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Cukupi air agar pikiran tetap fokus',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Counter Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_waterGlasses ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        TextSpan(
                          text: '/ $_targetGlasses Gelas ($totalMl / 2.000 ml)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceCard,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),

          // Interactive 8 Glass Buttons (Simetris Grid 4x2)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _targetGlasses,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final isFilled = index < _waterGlasses;
              return InkWell(
                onTap: () => _toggleWaterGlass(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.secondary
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFilled
                          ? AppColors.secondary
                          : AppColors.surfaceVariant,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFilled
                            ? Icons.local_drink_rounded
                            : Icons.local_drink_outlined,
                        size: 16,
                        color: isFilled
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFilled
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 2. Gut-Brain Axis Section ---
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.softMint, width: 2.5),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=300&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.softMint.withValues(alpha: 0.4),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hubungan Usus & Otak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sekitar 90% hormon serotonin (hormon penentu rasa bahagia) diproduksi di pencernaan. Makanan sehat menjaga saluran cerna tetap rileks.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Sumber: Harvard Health & PubMed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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
        Text(
          'Makanan Pereda Stres & Cemas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
          children: [
            _buildBentoCard(
              icon: Icons.cookie_outlined,
              iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              iconColor: AppColors.primary,
              title: 'Dark Chocolate',
              description: 'Magnesium tinggi bantu redakan ketegangan otot.',
              badge: 'Magnesium',
            ),
            _buildBentoCard(
              icon: Icons.local_cafe,
              iconBgColor: AppColors.softMint.withValues(alpha: 0.5),
              iconColor: AppColors.secondary,
              title: 'Green Tea / Matcha',
              description: 'L-theanine tingkatkan gelombang alfa ketenangan.',
              badge: 'L-Theanine',
            ),
            _buildBentoCard(
              icon: Icons.set_meal,
              iconBgColor: AppColors.softSunshine.withValues(alpha: 0.5),
              iconColor: AppColors.tertiary,
              title: 'Ikan Salmon / Tuna',
              description: 'Asam lemak Omega-3 bantu kurangi inflamasi otak.',
              badge: 'Omega-3',
            ),
            _buildBentoCard(
              icon: Icons.blender,
              iconBgColor: AppColors.surfaceContainerHigh,
              iconColor: AppColors.onSurface,
              title: 'Yogurt / Kimchi',
              description: 'Probiotik aktif dukung produksi serotonin usus.',
              badge: 'Probiotik',
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
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.3,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Mood-Boosting Meal Plan Section ---
  Widget _buildMealPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi Menu Harian Penstabil Mood',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          timeLabel: 'Sarapan (07.00 - 09.00)',
          timeColor: AppColors.softSunshine,
          title: 'Oatmeal Pisang & Kacang Almond',
          benefit:
              'Karbohidrat kompleks pisang + triptofan meningkatkan energi tanpa kecemasan.',
          icon: Icons.wb_sunny_rounded,
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          timeLabel: 'Makan Siang (12.00 - 13.30)',
          timeColor: AppColors.softMint,
          title: 'Nasi Merah + Tumis Sayur & Tahu/Salmon',
          benefit:
              'Serat tinggi menjaga gula darah stabil & cegah penurunan mood di sore hari (brain fog).',
          icon: Icons.wb_twilight_rounded,
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          timeLabel: 'Makan Malam (18.30 - 20.00)',
          timeColor: AppColors.primaryContainer,
          title: 'Sup Sayur Warm + Teh Chamomile',
          benefit:
              'Makanan hangat yang mudah dicerna menyiapkan tubuh untuk tidur nyenyak.',
          icon: Icons.bedtime_rounded,
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String timeLabel,
    required Color timeColor,
    required String title,
    required String benefit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: timeColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: AppColors.onSurface),
                    const SizedBox(width: 6),
                    Text(
                      timeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            benefit,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Foods to Limit when Stressed ---
  Widget _buildFoodsToLimitSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCDCD),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Makanan yang Perlu Dibatasi saat Stres',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildLimitItem(
            title: 'Kafein Berlebihan (>2 Cangkir)',
            desc:
                'Kafein tinggi memicu hormon kortisol (stres) dan jantung berdebar-debar.',
            substitute: 'Ganti dengan Teh Chamomile atau Air Infused Lemon',
          ),
          const SizedBox(height: 12),
          _buildLimitItem(
            title: 'Gula Olahan & Makanan Manis',
            desc:
                'Menyebabkan lonjakan gula darah mendadak diikuti kemerosotan energi (mood swing).',
            substitute: 'Ganti dengan buah pisang segar atau Dark Chocolate',
          ),
          const SizedBox(height: 12),
          _buildLimitItem(
            title: 'Makanan Sangat Asin & Fast Food',
            desc:
                'Tinggi sodium meningkatkan tekanan darah dan mengganggu hidrasi tubuh.',
            substitute: 'Ganti dengan makanan buatan rumah berbumbu alami',
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem({
    required String title,
    required String desc,
    required String substitute,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $title',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '💡 $substitute',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 6. Pola Makan Mindful Section ---
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
                Icons.self_improvement_rounded,
                color: AppColors.tertiary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pola Makan Mindful (Penuh Kesadaran)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMindfulListItem(
            icon: Icons.restaurant_rounded,
            text:
                'Makanlah secara perlahan dan nikmati aroma serta tekstur setiap suapan.',
          ),
          const SizedBox(height: 12),
          _buildMindfulListItem(
            icon: Icons.phone_disabled_rounded,
            text:
                'Matikan TV dan jauhkan HP saat makan untuk menghargai momen bersantap.',
          ),
          const SizedBox(height: 12),
          _buildMindfulListItem(
            icon: Icons.psychology_rounded,
            text:
                'Dengarkan isyarat rasa lapar & kenyang alami dari tubuh dengan penuh kasih.',
          ),
        ],
      ),
    );
  }

  Widget _buildMindfulListItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
