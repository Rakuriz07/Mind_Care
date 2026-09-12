import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/community/community_screen.dart';
import 'package:mindcare/views/history_screen.dart';
import 'package:mindcare/views/home_screen.dart';
import 'package:mindcare/views/screening_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  late int _selectedIndex;
  bool _isTapNavigating = false;

  final List<String> _labels = const ['Beranda', 'Skrining', 'Riwayat', 'Komunitas'];
  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.fact_check_rounded,
    Icons.history_rounded,
    Icons.forum_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabItemSelected(int index) {
    if (_selectedIndex == index) return;

    final int distance = (_selectedIndex - index).abs();


    setState(() {
      _selectedIndex = index;
      _isTapNavigating = true;
    });

    if (distance > 1) {
      _pageController.jumpToPage(index);
      _isTapNavigating = false;
    } else {
      _pageController
          .animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      )
          .then((_) {
        if (mounted) {
          setState(() {
            _isTapNavigating = false;
          });
        }
      });
    }
  }

  void _onPageChanged(int index) {
    if (_isTapNavigating) return;
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeScreen(
            isRootTab: true,
            onSelectTab: _onTabItemSelected,
          ),
          const ScreeningScreen(),
          const HistoryScreen(),
          const CommunityScreen(),
        ],
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: List.generate(
          _icons.length,
          (index) => Icon(
            _icons[index],
            color: Colors.white,
            size: 26,
          ),
        ),
        inactiveIcons: List.generate(
          _labels.length,
          (index) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icons[index],
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                _labels[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        color: AppColors.surfaceCard,
        circleColor: AppColors.primary,
        height: 62,
        circleWidth: 56,
        activeIndex: _selectedIndex,
        onTap: _onTabItemSelected,
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 8,
      ),
    );
  }
}
