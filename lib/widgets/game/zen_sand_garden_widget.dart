import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class ZenSandGardenWidget extends StatefulWidget {
  const ZenSandGardenWidget({super.key});

  @override
  State<ZenSandGardenWidget> createState() => _ZenSandGardenWidgetState();
}

class LinePath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  LinePath({
    required this.points,
    required this.color,
    this.strokeWidth = 14.0,
  });
}

class GardenElement {
  final String id;
  final String emoji;
  final String label;
  Offset position;
  final Color color;

  GardenElement({
    required this.id,
    required this.emoji,
    required this.label,
    required this.position,
    required this.color,
  });
}

class _ZenSandGardenWidgetState extends State<ZenSandGardenWidget> {
  final List<LinePath> _paths = [];
  LinePath? _currentPath;
  String _selectedRakeStyle = 'Garis Halus'; // 'Garis Halus', 'Gelombang', 'Sapu Lebar'

  final List<GardenElement> _placedElements = [];
  String _selectedEmoji = '🪨';

  final List<Map<String, String>> _availableDecorations = const [
    {'emoji': '🪨', 'name': 'Batu Zen'},
    {'emoji': '🪴', 'name': 'Bonsai'},
    {'emoji': '🌸', 'name': 'Sakura'},
    {'emoji': '🍃', 'name': 'Daun Bambu'},
    {'emoji': '🪷', 'name': 'Teratai'},
    {'emoji': '🕯️', 'name': 'Lilin Kedamaian'},
  ];

  @override
  void initState() {
    super.initState();
    // Default initial decorations in the sand garden
    _placedElements.addAll([
      GardenElement(
        id: '1',
        emoji: '🪨',
        label: 'Batu Utuh',
        position: const Offset(100, 120),
        color: Colors.blueGrey,
      ),
      GardenElement(
        id: '2',
        emoji: '🪴',
        label: 'Bonsai',
        position: const Offset(240, 220),
        color: Colors.green,
      ),
      GardenElement(
        id: '3',
        emoji: '🌸',
        label: 'Sakura',
        position: const Offset(120, 280),
        color: Colors.pink,
      ),
    ]);
  }

  void _clearSand() {
    setState(() {
      _paths.clear();
      _currentPath = null;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pasir taman telah diratakan kembali. Bebas berkreativitas! ✨',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  double _getStrokeWidth() {
    switch (_selectedRakeStyle) {
      case 'Sapu Lebar':
        return 22.0;
      case 'Gelombang':
        return 16.0;
      default:
        return 10.0;
    }
  }

  Color _getRakeColor() {
    switch (_selectedRakeStyle) {
      case 'Sapu Lebar':
        return const Color(0xFFD4C3A3);
      case 'Gelombang':
        return const Color(0xFFE2D6BE);
      default:
        return const Color(0xFFC7B299);
    }
  }

  void _addDecorationAt(Offset localPosition) {
    final name = _availableDecorations.firstWhere(
      (d) => d['emoji'] == _selectedEmoji,
      orElse: () => {'name': 'Dekorasi'},
    )['name']!;

    setState(() {
      _placedElements.add(
        GardenElement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          emoji: _selectedEmoji,
          label: name,
          position: localPosition,
          color: AppColors.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Toolbar: Rake Styles & Controls
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.brush_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'Taman Pasir Zen (ASMR)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _clearSand,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(
                      'Ratakan Pasir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Rake Style Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRakeChip('Garis Halus', Icons.drag_handle_rounded),
                    const SizedBox(width: 6),
                    _buildRakeChip('Gelombang', Icons.waves_rounded),
                    const SizedBox(width: 6),
                    _buildRakeChip('Sapu Lebar', Icons.line_weight_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Sand Canvas View
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2E7), // Warm Sand Color
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD8CBB5), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(60, 50, 30, 0.08),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sand Texture Background Pattern
                CustomPaint(
                  size: Size.infinite,
                  painter: SandGardenPainter(
                    paths: _paths,
                    currentPath: _currentPath,
                  ),
                ),

                // Gesture Detector for Drawing Sand Rake Lines
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentPath = LinePath(
                        points: [details.localPosition],
                        color: _getRakeColor(),
                        strokeWidth: _getStrokeWidth(),
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    if (_currentPath != null) {
                      setState(() {
                        _currentPath!.points.add(details.localPosition);
                      });
                    }
                  },
                  onPanEnd: (_) {
                    if (_currentPath != null) {
                      setState(() {
                        _paths.add(_currentPath!);
                        _currentPath = null;
                      });
                    }
                  },
                  onDoubleTapDown: (details) {
                    _addDecorationAt(details.localPosition);
                  },
                ),

                // Draggable Zen Ornaments
                ..._placedElements.map((elem) {
                  return Positioned(
                    left: elem.position.dx - 24,
                    top: elem.position.dy - 24,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          elem.position += details.delta;
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          _placedElements.removeWhere((e) => e.id == elem.id);
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          elem.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }),

                // Guidance Helper overlay
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '👉 Usap jari untuk menyapu pola pasir • Ketuk 2x untuk taruh hiasan • Tahan elemen untuk hapus',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Bottom Decoration Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(
                'Hiasan:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableDecorations.map((item) {
                      final isSelected = _selectedEmoji == item['emoji'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          avatar: Text(item['emoji']!, style: const TextStyle(fontSize: 14)),
                          label: Text(item['name']!),
                          selected: isSelected,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.onPrimaryContainer
                                : AppColors.onSurfaceVariant,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedEmoji = item['emoji']!);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRakeChip(String styleName, IconData icon) {
    final bool isSelected = _selectedRakeStyle == styleName;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : AppColors.secondary,
      ),
      label: Text(styleName),
      selected: isSelected,
      selectedColor: AppColors.secondary,
      backgroundColor: AppColors.surfaceCanvas,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedRakeStyle = styleName);
      },
    );
  }
}

class SandGardenPainter extends CustomPainter {
  final List<LinePath> paths;
  final LinePath? currentPath;

  SandGardenPainter({
    required this.paths,
    required this.currentPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Sand Texture Lines (Subtle background Zen pattern)
    final bgPaint = Paint()
      ..color = const Color(0xFFEADBCE).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.height; i += 24) {
      final path = Path();
      path.moveTo(0, i);
      for (double x = 0; x <= size.width; x += 40) {
        final yOffset = math.sin((x + i) * 0.02) * 3;
        path.lineTo(x, i + yOffset);
      }
      canvas.drawPath(path, bgPaint);
    }

    // 2. Render Raked Paths
    final allPaths = [...paths];
    if (currentPath != null) {
      allPaths.add(currentPath!);
    }

    for (var linePath in allPaths) {
      if (linePath.points.length < 2) continue;

      final paint = Paint()
        ..color = linePath.color
        ..strokeWidth = linePath.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(linePath.points.first.dx, linePath.points.first.dy);
      for (int i = 1; i < linePath.points.length; i++) {
        path.lineTo(linePath.points[i].dx, linePath.points[i].dy);
      }
      canvas.drawPath(path, paint);

      // Inner shadow line for depth in sand
      final shadowPaint = Paint()
        ..color = const Color(0xFFAC997F)
        ..strokeWidth = linePath.strokeWidth * 0.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SandGardenPainter oldDelegate) => true;
}
