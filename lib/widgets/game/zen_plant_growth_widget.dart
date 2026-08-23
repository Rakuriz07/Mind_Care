import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class ZenPlantGrowthWidget extends StatefulWidget {
  const ZenPlantGrowthWidget({super.key});

  @override
  State<ZenPlantGrowthWidget> createState() => _ZenPlantGrowthWidgetState();
}

class WaterDrop {
  final String id;
  Offset position;
  final double size;

  WaterDrop({
    required this.id,
    required this.position,
    this.size = 36.0,
  });
}

class _ZenPlantGrowthWidgetState extends State<ZenPlantGrowthWidget>
    with SingleTickerProviderStateMixin {
  double _growthProgress = 0.2; // 0.0 to 1.0
  int _waterCount = 2;
  int _totalBloomedTrees = 0;
  String _statusMessage = 'Ketuk tetesan air 💧 untuk menyiram benih ketenangan Anda!';

  late AnimationController _animController;
  Timer? _dropSpawnerTimer;
  final List<WaterDrop> _drops = [];

  final List<Map<String, dynamic>> _growthStages = const [
    {
      'minProgress': 0.0,
      'title': 'Benih Ditanam',
      'emoji': '🌱',
      'description': 'Benih ketenangan baru diairi di tanah yang subur.',
      'color': Color(0xFF81C784),
    },
    {
      'minProgress': 0.25,
      'title': 'Tunas Muda',
      'emoji': '🌿',
      'description': 'Tunas muda mulai bertumbuh menggapai cahaya hangat.',
      'color': Color(0xFF66BB6A),
    },
    {
      'minProgress': 0.50,
      'title': 'Tanaman Rindang',
      'emoji': '🪴',
      'description': 'Daun-daun semakin lebat dan memancarkan energi positif.',
      'color': Color(0xFF4CAF50),
    },
    {
      'minProgress': 0.75,
      'title': 'Pohon Kedamaian',
      'emoji': '🌳',
      'description': 'Pohon tumbuh kokoh dan siap memunculkan kelopak bunga.',
      'color': Color(0xFF388E3C),
    },
    {
      'minProgress': 1.0,
      'title': 'Mekar Sempurna',
      'emoji': '🌸',
      'description': 'Bunga ketenangan mekar indah! Jiwa Anda sejuk dan damai.',
      'color': Color(0xFFEC407A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _spawnWaterDrops();
    _dropSpawnerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _drops.length < 5) {
        _spawnSingleDrop();
      }
    });
  }

  void _spawnWaterDrops() {
    _drops.clear();
    for (int i = 0; i < 3; i++) {
      _spawnSingleDrop();
    }
  }

  void _spawnSingleDrop() {
    final randomX = 40.0 + math.Random().nextDouble() * 220.0;
    final randomY = 40.0 + math.Random().nextDouble() * 260.0;
    setState(() {
      _drops.add(
        WaterDrop(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          position: Offset(randomX, randomY),
        ),
      );
    });
  }

  void _waterPlant([WaterDrop? drop]) {
    if (_growthProgress >= 1.0) return;

    setState(() {
      if (drop != null) {
        _drops.removeWhere((d) => d.id == drop.id);
      }
      _waterCount++;
      _growthProgress = (_growthProgress + 0.15).clamp(0.0, 1.0);

      if (_growthProgress >= 1.0) {
        _totalBloomedTrees++;
        _statusMessage = 'Selamat! Pohon Ketenangan Anda mekar sempurna ✨🌸';
      } else {
        _statusMessage = 'Siraman air menyegarkan tanaman! Kemajuan: ${(_growthProgress * 100).toInt()}%';
      }
    });
  }

  void _resetPlant() {
    setState(() {
      _growthProgress = 0.1;
      _waterCount = 0;
      _statusMessage = 'Benih baru telah ditanam! Siram dengan tetesan air 💧';
      _spawnWaterDrops();
    });
  }

  Map<String, dynamic> _getCurrentStage() {
    for (int i = _growthStages.length - 1; i >= 0; i--) {
      if (_growthProgress >= _growthStages[i]['minProgress']) {
        return _growthStages[i];
      }
    }
    return _growthStages.first;
  }

  @override
  void dispose() {
    _dropSpawnerTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _getCurrentStage();
    final bool isFullyGrown = _growthProgress >= 1.0;

    return Column(
      children: [
        // Top Info & Progress Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pohon Kedamaian (Plant Growth)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Tahap: ${stage['title']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stage['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_florist_rounded, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalBloomedTrees Mekar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Growth Bar
              Row(
                children: [
                  const Icon(Icons.water_drop_rounded, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _growthProgress,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceCanvas,
                        valueColor: AlwaysStoppedAnimation<Color>(stage['color'] as Color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_growthProgress * 100).toInt()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Plant Garden Viewport
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFC8E6C9).withValues(alpha: 0.8),
                  const Color(0xFFA5D6A7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(76, 175, 80, 0.1),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground Soil Layer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 90,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF8D6E63),
                      borderRadius: BorderRadius.vertical(top: Radius.elliptical(200, 30)),
                    ),
                  ),
                ),

                // Floating Interactive Water Droplets 💧
                ..._drops.map((drop) {
                  return Positioned(
                    left: drop.position.dx,
                    top: drop.position.dy,
                    child: GestureDetector(
                      onTap: () => _waterPlant(drop),
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, math.sin(_animController.value * math.pi * 2) * 4),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withValues(alpha: 0.25),
                                border: Border.all(color: Colors.blueAccent, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(33, 150, 243, 0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: Colors.blueAccent,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),

                // Center Growing Plant Emoji & Animation
                Positioned(
                  bottom: 50,
                  child: GestureDetector(
                    onTap: () => _waterPlant(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: 0.8 + (_growthProgress * 0.8),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          child: Text(
                            stage['emoji'] as String,
                            style: TextStyle(
                              fontSize: isFullyGrown ? 90 : 70,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            stage['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: stage['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Helper Overlay Text
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Bottom Action Bar
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: isFullyGrown ? null : () => _waterPlant(),
                  icon: const Icon(Icons.water_drop_rounded, size: 18),
                  label: Text(
                    isFullyGrown ? 'Pohon Sudah Mekar 🌸' : 'Siram Tanaman 💧',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
            if (isFullyGrown) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _resetPlant,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: Text(
                    'Tanam Baru 🌱',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
