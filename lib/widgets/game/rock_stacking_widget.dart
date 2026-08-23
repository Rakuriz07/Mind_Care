import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class PebbleData {
  final String id;
  final String name;
  final double width;
  final double height;
  final Color colorStart;
  final Color colorEnd;
  final String texture;
  final double rotation;

  PebbleData({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.colorStart,
    required this.colorEnd,
    required this.texture,
    this.rotation = 0.0,
  });
}

class RockStackingWidget extends StatefulWidget {
  const RockStackingWidget({super.key});

  @override
  State<RockStackingWidget> createState() => _RockStackingWidgetState();
}

class _RockStackingWidgetState extends State<RockStackingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  int _stackedCount = 0;
  int _zenScore = 0;
  String _activeAffirmation = 'Ketuk "Tambah Batu" untuk mulai menyusun ketenangan Anda 🪨✨';

  final List<PebbleData> _availablePebbles = [
    PebbleData(
      id: 'p1',
      name: 'Batu Sungai Hitam',
      width: 170,
      height: 48,
      colorStart: const Color(0xFF374151),
      colorEnd: const Color(0xFF1F2937),
      texture: 'Batu Kali Halus',
      rotation: -0.02,
    ),
    PebbleData(
      id: 'p2',
      name: 'Batu Giok Hijau',
      width: 145,
      height: 44,
      colorStart: const Color(0xFF34D399),
      colorEnd: const Color(0xFF059669),
      texture: 'Giok Penenang',
      rotation: 0.03,
    ),
    PebbleData(
      id: 'p3',
      name: 'Batu Kuarza Emas',
      width: 125,
      height: 42,
      colorStart: const Color(0xFFFBBF24),
      colorEnd: const Color(0xFFD97706),
      texture: 'Kuarza Hangat',
      rotation: -0.01,
    ),
    PebbleData(
      id: 'p4',
      name: 'Batu Samudra Biru',
      width: 105,
      height: 38,
      colorStart: const Color(0xFF60A5FA),
      colorEnd: const Color(0xFF2563EB),
      texture: 'Kristal Samudra',
      rotation: 0.02,
    ),
    PebbleData(
      id: 'p5',
      name: 'Batu Mawar Merah Muda',
      width: 85,
      height: 35,
      colorStart: const Color(0xFFF472B6),
      colorEnd: const Color(0xFFDB2777),
      texture: 'Mawar Afeksi',
      rotation: -0.03,
    ),
    PebbleData(
      id: 'p6',
      name: 'Batu Zen Lavender',
      width: 68,
      height: 32,
      colorStart: const Color(0xFFA78BFA),
      colorEnd: const Color(0xFF7C3AED),
      texture: 'Zen Kedamaian',
      rotation: 0.01,
    ),
    PebbleData(
      id: 'p7',
      name: 'Batu Putih Murni',
      width: 52,
      height: 28,
      colorStart: const Color(0xFFF3F4F6),
      colorEnd: const Color(0xFFD1D5DB),
      texture: 'Keheningan Murni',
      rotation: 0.0,
    ),
  ];

  final List<PebbleData> _stackedPebbles = [];

  final List<String> _mindfulQuotes = const [
    'Setiap batu menemukan posisinya saat Anda tetap tenang dan bersabar 🌿',
    'Keseimbangan lahir dari kedamaian dan keheningan di dalam diri 🕊️',
    'Tidak ada yang terburu-buru. Melangkahlah satu demi satu 🌸',
    'Napas Anda adalah fondasi utama keseimbangan hidup ini 🫁✨',
    'Kecemasan perlahan memudar saat pikiran Anda menjadi fokus dan jernih 💎',
    'Anda telah berhasil membangun menara ketenangan yang indah hari ini 🏆✨',
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _addNextPebble() {
    if (_stackedPebbles.length >= _availablePebbles.length) {
      setState(() {
        _activeAffirmation =
            'Menara Batu Keseimbangan Sempurna! Anda mencapai keheningan maksimal ✨🧘‍♂️';
      });
      return;
    }

    final nextPebble = _availablePebbles[_stackedPebbles.length];
    setState(() {
      _stackedPebbles.add(nextPebble);
      _stackedCount = _stackedPebbles.length;
      _zenScore += 15;
      _activeAffirmation =
          _mindfulQuotes[(_stackedCount - 1) % _mindfulQuotes.length];
    });
  }

  void _resetStack() {
    setState(() {
      _stackedPebbles.clear();
      _stackedCount = 0;
      _zenScore = 0;
      _activeAffirmation =
          'Menara di-reset. Mari susun batu ketenangan Anda kembali dari awal ✨';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          width: 1,
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
          // Header Stats Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBadge(
                  icon: Icons.layers_rounded,
                  title: 'Tersusun',
                  value: '$_stackedCount / ${_availablePebbles.length}',
                  color: AppColors.primary,
                ),
                _buildStatBadge(
                  icon: Icons.spa_rounded,
                  title: 'Skor Zen',
                  value: '$_zenScore Poin',
                  color: AppColors.secondary,
                ),
                ElevatedButton.icon(
                  onPressed: _resetStack,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceCanvas,
                    foregroundColor: AppColors.onSurfaceVariant,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mindful Message Callout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.softMint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _activeAffirmation,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
            ),
          ),

          // Main Zen Stacking Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E293B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Water Ripple Background Animation
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Positioned(
                          bottom: 20,
                          child: Container(
                            width: 220 + (_rippleController.value * 40),
                            height: 24 + (_rippleController.value * 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(
                                  110 + (_rippleController.value * 20),
                                  12 + (_rippleController.value * 6),
                                ),
                              ),
                              border: Border.all(
                                color: AppColors.softMint.withValues(
                                  alpha: (1.0 - _rippleController.value) * 0.4,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Pedestal Base Wooden/Stone Platform
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 240,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF475569), Color(0xFF334155)],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'KEDAMAIAN ZEN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stack of Pebbles
                    Positioned(
                      bottom: 30,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_stackedPebbles.length, (index) {
                          final pebbleIndex = _stackedPebbles.length - 1 - index;
                          final pebble = _stackedPebbles[pebbleIndex];

                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutBack,
                            builder: (context, val, child) {
                              return Transform.scale(
                                scale: val,
                                child: Transform.rotate(
                                  angle: pebble.rotation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    width: pebble.width,
                                    height: pebble.height,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [pebble.colorStart, pebble.colorEnd],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(pebble.height / 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        pebble.texture,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),

                    // Empty State Prompt
                    if (_stackedPebbles.isEmpty)
                      Positioned(
                        top: 80,
                        child: Column(
                          children: [
                            Icon(
                              Icons.filter_hdr_rounded,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Susun batu untuk melepaskan beban pikiran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _stackedPebbles.length < _availablePebbles.length
                    ? _addNextPebble
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                label: Text(
                  _stackedPebbles.length < _availablePebbles.length
                      ? 'Tambah Batu Keseimbangan (+1)'
                      : 'Menara Batu Sempurna ✨',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
