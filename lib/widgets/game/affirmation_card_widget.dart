import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class AffirmationCardWidget extends StatefulWidget {
  final List<Map<String, String>> cards;

  const AffirmationCardWidget({
    super.key,
    required this.cards,
  });

  @override
  State<AffirmationCardWidget> createState() => _AffirmationCardWidgetState();
}

class _AffirmationCardWidgetState extends State<AffirmationCardWidget>
    with SingleTickerProviderStateMixin {
  int _topIndex = 0;
  final Set<int> _likedCardIndices = {};

  // Gesture Drag position
  Offset _dragOffset = Offset.zero;

  // Animation controller for ultra-smooth snap-back and fling-out
  late AnimationController _animController;
  late Animation<Offset> _offsetAnim;

  final List<List<Color>> _cardGradients = const [
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], // Soft Mint Green
    [Color(0xFFFFF8E1), Color(0xFFFFECB3)], // Soft Sunshine Warm Yellow
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Soft Peaceful Sky Blue
    [Color(0xFFF3E5F5), Color(0xFFE1E0F7)], // Soft Lavender Relax
    [Color(0xFFFBE9E7), Color(0xFFFFCCBC)], // Soft Peach Warmth
    [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], // Soft Ocean Breath
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)], // Soft Amber Glow
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnim = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_animController.isAnimating) return;
    _animController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_animController.isAnimating) return;

    final double swipeThreshold = 90.0;
    final double velocityX = details.velocity.pixelsPerSecond.dx;

    if (_dragOffset.dx.abs() > swipeThreshold || velocityX.abs() > 400) {
      // Fling card off-screen with smooth curve
      final double endX = _dragOffset.dx >= 0 ? 550.0 : -550.0;
      final double endY = _dragOffset.dy * 1.4;

      _offsetAnim = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(endX, endY),
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );

      _animController.forward(from: 0).then((_) {
        setState(() {
          _topIndex++;
          _dragOffset = Offset.zero;
        });
        _animController.reset();
      });
    } else {
      // Elastic spring snap-back to center
      _offsetAnim = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
      );

      _animController.forward(from: 0).then((_) {
        setState(() {
          _dragOffset = Offset.zero;
        });
        _animController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox();
    }

    final totalCards = widget.cards.length;
    final currentCardNum = (_topIndex % totalCards) + 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // Top Counter Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Kartu $currentCardNum dari $totalCards',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Stacked Cards Viewport
        SizedBox(
          height: 340,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 3rd Card in Stack (deepest)
              _buildStackedCard(
                stackPosition: 2,
                cardIndex: (_topIndex + 2) % totalCards,
              ),

              // 2nd Card in Stack (middle)
              _buildStackedCard(
                stackPosition: 1,
                cardIndex: (_topIndex + 1) % totalCards,
              ),

              // Top Card (Fully Interactive Drag & Tilt)
              _buildTopInteractiveCard(
                cardIndex: _topIndex % totalCards,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Animated Dots Indicator at Bottom (Dynamic Window for 20 Cards)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: () {
            const maxVisibleDots = 7;
            final activeIndex = _topIndex % totalCards;
            int start = (activeIndex - (maxVisibleDots ~/ 2)).clamp(
              0,
              (totalCards - maxVisibleDots).clamp(0, totalCards),
            );
            int end = (start + maxVisibleDots).clamp(0, totalCards);

            return List.generate(end - start, (i) {
              final index = start + i;
              final isSelected = activeIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            });
          }(),
        ),
      ],
    );
  }

  // Top Card with Smooth Drag & Tilt Physics
  Widget _buildTopInteractiveCard({required int cardIndex}) {
    final card = widget.cards[cardIndex];
    final gradient = _cardGradients[cardIndex % _cardGradients.length];

    final currentOffset = _animController.isAnimating
        ? _offsetAnim.value
        : _dragOffset;

    // Rotational tilt proportional to horizontal drag
    final double rotationAngle = (currentOffset.dx / 350) * 0.22;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: currentOffset,
        child: Transform.rotate(
          angle: rotationAngle,
          child: _buildCardContainer(
            card: card,
            gradient: gradient,
            cardIndex: cardIndex,
            isInteractive: true,
          ),
        ),
      ),
    );
  }

  // Cards in background with dynamic scaling synchronized with top drag
  Widget _buildStackedCard({
    required int stackPosition,
    required int cardIndex,
  }) {
    final card = widget.cards[cardIndex];
    final gradient = _cardGradients[cardIndex % _cardGradients.length];

    final double currentDx = _animController.isAnimating
        ? _offsetAnim.value.dx.abs()
        : _dragOffset.dx.abs();

    final double dragProgress = (currentDx / 200.0).clamp(0.0, 1.0);

    // Interpolate scale & translateY smoothly as top card is dragged
    final double baseScale = 1.0 - (stackPosition * 0.05);
    final double targetScale = 1.0 - ((stackPosition - 1) * 0.05);
    final double currentScale = baseScale + (targetScale - baseScale) * dragProgress;

    final double baseOffsetY = stackPosition * 14.0;
    final double targetOffsetY = (stackPosition - 1) * 14.0;
    final double currentOffsetY = baseOffsetY + (targetOffsetY - baseOffsetY) * dragProgress;

    final double baseOpacity = (1.0 - (stackPosition * 0.22)).clamp(0.0, 1.0);
    final double targetOpacity = (1.0 - ((stackPosition - 1) * 0.22)).clamp(0.0, 1.0);
    final double currentOpacity = baseOpacity + (targetOpacity - baseOpacity) * dragProgress;

    return Transform.translate(
      offset: Offset(0, currentOffsetY),
      child: Transform.scale(
        scale: currentScale,
        child: Opacity(
          opacity: currentOpacity,
          child: _buildCardContainer(
            card: card,
            gradient: gradient,
            cardIndex: cardIndex,
            isInteractive: false,
          ),
        ),
      ),
    );
  }

  // Base Card Content Layout
  Widget _buildCardContainer({
    required Map<String, String> card,
    required List<Color> gradient,
    required int cardIndex,
    required bool isInteractive,
  }) {
    final isLiked = _likedCardIndices.contains(cardIndex);

    return Container(
      width: double.infinity,
      height: 330,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3142).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Category Badge & Like Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      card['icon'] ?? '✨',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      card['category'] ?? 'Afirmasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInteractive)
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (isLiked) {
                        _likedCardIndices.remove(cardIndex);
                      } else {
                        _likedCardIndices.add(cardIndex);
                      }
                    });
                  },
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked ? Colors.redAccent : AppColors.primary,
                    size: 22,
                  ),
                  tooltip: 'Resapi & Simpan',
                )
              else
                const SizedBox(height: 40),
            ],
          ),

          // Center: Title & Full Quote Directly Readable
          Column(
            children: [
              Text(
                card['title'] ?? '',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${card['quote'] ?? ''}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          // Bottom Indicator inside Card
          Text(
            'Resapi & geser kartu ini 🌿',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
