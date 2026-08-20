import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class GameRelaksasiScreen extends StatefulWidget {
  const GameRelaksasiScreen({super.key});

  @override
  State<GameRelaksasiScreen> createState() => _GameRelaksasiScreenState();
}

class _GameRelaksasiScreenState extends State<GameRelaksasiScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  // Selected Game Tab: 0 = Bubble Calm, 1 = Lotus Breathing, 2 = Kartu Afirmasi
  int _selectedTab = 0;

  // --- GAME 1: BUBBLE CALM STATE ---
  int _peaceScore = 0;
  int _poppedCount = 0;
  String _currentAffirmation =
      'Sentuh gelembung cemas di bawah untuk meletuskannya & melepaskan beban! ✨';

  final List<Map<String, String>> _wordPairs = const [
    {'word': 'Khawatir', 'affirm': 'Saya aman dan hidup di saat ini 🌿'},
    {'word': 'Beban', 'affirm': 'Saya melepaskan apa yang tidak bisa saya kontrol 🌊'},
    {'word': 'Stres', 'affirm': 'Setiap napas membawa kedamaian ke jiwa saya 🕊️'},
    {'word': 'Overthinking', 'affirm': 'Pikiran saya tenang dan jernih seperti air danau 💎'},
    {'word': 'Lelah', 'affirm': 'Saya mengizinkan tubuh dan pikiran saya beristirahat 🛌'},
    {'word': 'Cemas', 'affirm': 'Saya lebih kuat dari rasa cemas yang saya rasakan 💪'},
    {'word': 'Ragu', 'affirm': 'Saya percaya pada potensi dan perjalanan hidup saya 🌟'},
    {'word': 'Takut', 'affirm': 'Keberanian tumbuh di dalam hati saya setiap hari 🦁'},
  ];

  late List<_BubbleData> _bubbles;

  final List<Color> _bubbleColors = const [
    Color(0xFFFFB7B2),
    Color(0xFFFFDAC1),
    Color(0xFFE2F0CB),
    Color(0xFFB5EAD7),
    Color(0xFFC7CEEA),
    Color(0xFFF6EACB),
  ];

  final List<Alignment> _alignments = const [
    Alignment(-0.75, -0.65),
    Alignment(0.70, -0.70),
    Alignment(-0.10, -0.30),
    Alignment(-0.70, 0.20),
    Alignment(0.65, 0.15),
    Alignment(0.0, 0.65),
  ];

  // --- GAME 2: LOTUS BREATHING STATE ---
  bool _isBreathingActive = false;
  int _breathingStep = 0; // 0 = Tarik Napas (4s), 1 = Tahan (7s), 2 = Hembuskan (8s)
  int _breathSecond = 0;
  int _completedCycles = 0;
  Timer? _breathingTimer;
  late AnimationController _lotusAnimController;

  // --- GAME 3: KARTU AFIRMASI STATE ---
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;

  final List<Map<String, String>> _affirmationCards = const [
    {
      'title': 'Ketenangan Hati',
      'quote': 'Kedamaian tidak datang dari ketiadaan masalah, melainkan dari ketenangan di dalam diri Anda.',
      'icon': '✨',
      'category': 'Self-Compassion',
    },
    {
      'title': 'Pelepasan Beban',
      'quote': 'Anda tidak harus membawa seluruh beban hari besok pada hari ini. Melangkahlah satu per satu.',
      'icon': '🍃',
      'category': 'Mindfulness',
    },
    {
      'title': 'Penerimaan Diri',
      'quote': 'Tidak apa-apa untuk merasa tidak sempurna. Anda sudah berusaha sebaik mungkin hari ini.',
      'icon': '🌸',
      'category': 'Self-Love',
    },
    {
      'title': 'Kekuatan Batin',
      'quote': 'Badai pasti berlalu. Di balik awan gelap, langit biru selalu setia menunggu Anda.',
      'icon': '🌈',
      'category': 'Resilience',
    },
    {
      'title': 'Fokus Saat Ini',
      'quote': 'Tarik napas dalam-dalam. Nikmati momen ini karena di sinilah kehidupan sesungguhnya berada.',
      'icon': '☀️',
      'category': 'Presence',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initBubbles();
    _initAudio();

    _lotusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _initBubbles() {
    _bubbles = List.generate(6, (index) {
      final pair = _wordPairs[index % _wordPairs.length];
      return _BubbleData(
        word: pair['word']!,
        affirmation: pair['affirm']!,
        color: _bubbleColors[index % _bubbleColors.length],
        alignment: _alignments[index % _alignments.length],
      );
    });
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.5);
    } catch (_) {}
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _lotusAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });

    if (_isAudioPlaying) {
      try {
        await _audioPlayer.play(AssetSource('audio/segar.mp3'));
      } catch (_) {
        try {
          await _audioPlayer.play(AssetSource('audio/senang.mp3'));
        } catch (_) {}
      }
    } else {
      await _audioPlayer.pause();
    }
  }

  // --- BUBBLE GAME LOGIC ---
  void _popBubble(int index) {
    if (_bubbles[index].isPopped) return;

    setState(() {
      _bubbles[index].isPopped = true;
      _peaceScore += 10;
      _poppedCount++;
      _currentAffirmation = _bubbles[index].affirmation;
    });

    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        final newPair = _wordPairs[math.Random().nextInt(_wordPairs.length)];
        _bubbles[index] = _BubbleData(
          word: newPair['word']!,
          affirmation: newPair['affirm']!,
          color: _bubbleColors[(_poppedCount + index) % _bubbleColors.length],
          alignment: _alignments[index % _alignments.length],
        );
      });
    });
  }

  void _resetBubbleGame() {
    setState(() {
      _peaceScore = 0;
      _poppedCount = 0;
      _currentAffirmation =
          'Game di-reset! Sentuh gelembung cemas di bawah untuk mulai meletuskan ✨';
      _initBubbles();
    });
  }

  // --- LOTUS BREATHING LOGIC ---
  void _toggleLotusBreathing() {
    setState(() {
      _isBreathingActive = !_isBreathingActive;
    });

    if (_isBreathingActive) {
      _startBreathingLoop();
    } else {
      _breathingTimer?.cancel();
      _lotusAnimController.stop();
    }
  }

  void _startBreathingLoop() {
    _breathingTimer?.cancel();
    _breathingStep = 0;
    _breathSecond = 0;
    _lotusAnimController.forward(from: 0.0);

    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isBreathingActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _breathSecond++;
        if (_breathingStep == 0 && _breathSecond >= 4) {
          // Move to Hold (7s)
          _breathingStep = 1;
          _breathSecond = 0;
          _lotusAnimController.stop();
        } else if (_breathingStep == 1 && _breathSecond >= 7) {
          // Move to Exhale (8s)
          _breathingStep = 2;
          _breathSecond = 0;
          _lotusAnimController.reverse(from: 1.0);
        } else if (_breathingStep == 2 && _breathSecond >= 8) {
          // Completed 1 cycle!
          _breathingStep = 0;
          _breathSecond = 0;
          _completedCycles++;
          _lotusAnimController.forward(from: 0.0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Game Relaksasi MindCare 🎮',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isAudioPlaying ? 'Matikan Musik Ambient' : 'Putar Musik Ambient',
            icon: Icon(
              _isAudioPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isAudioPlaying ? AppColors.primary : AppColors.outline,
            ),
            onPressed: _toggleAudio,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner & Game Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  // Subtitle Callout
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pilih permainan relaksasi di bawah untuk meredakan ketegangan mental Anda.',
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
                  const SizedBox(height: 14),

                  // Tab Buttons (Bubble Calm, Lotus Breathing, Kartu Afirmasi)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          index: 0,
                          label: 'Bubble Calm',
                          icon: Icons.bubble_chart_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton(
                          index: 1,
                          label: 'Irama Napas',
                          icon: Icons.self_improvement_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton(
                          index: 2,
                          label: 'Kartu Afirmasi',
                          icon: Icons.style_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Active Game Content View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSelectedGameView(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedTab == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceCard,
        foregroundColor: isSelected ? Colors.white : AppColors.onSurfaceVariant,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGameView() {
    switch (_selectedTab) {
      case 0:
        return _buildBubbleGame();
      case 1:
        return _buildLotusBreathingGame();
      case 2:
        return _buildAffirmationCardGame();
      default:
        return _buildBubbleGame();
    }
  }

  // ==========================================
  // GAME 1: BUBBLE CALM
  // ==========================================
  Widget _buildBubbleGame() {
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
                        'Skor Kedamaian: $_peaceScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_poppedCount meletus',
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
                  _currentAffirmation,
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
              children: _bubbles.asMap().entries.map((entry) {
                final index = entry.key;
                final bubble = entry.value;

                return Align(
                  alignment: bubble.alignment,
                  child: GestureDetector(
                    onTap: () => _popBubble(index),
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
          onPressed: _resetBubbleGame,
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

  // ==========================================
  // GAME 2: LOTUS BREATHING
  // ==========================================
  Widget _buildLotusBreathingGame() {
    String stepTitle = 'Siap Dimulai';
    String stepInstruction = 'Tekan Mulai untuk menyelaraskan napas 4-7-8';
    Color stepColor = AppColors.primary;

    if (_isBreathingActive) {
      if (_breathingStep == 0) {
        stepTitle = 'Tarik Napas... 🫁';
        stepInstruction = 'Hirup udara segar perlahan melalui hidung (${4 - _breathSecond} detik)';
        stepColor = AppColors.secondary;
      } else if (_breathingStep == 1) {
        stepTitle = 'Tahan Napas... ⏳';
        stepInstruction = 'Tahan napas Anda dengan tenang (${7 - _breathSecond} detik)';
        stepColor = AppColors.tertiary;
      } else if (_breathingStep == 2) {
        stepTitle = 'Hembuskan Napas... 🍃';
        stepInstruction = 'Lepaskan napas perlahan melalui mulut (${8 - _breathSecond} detik)';
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
                'Siklus Selesai: $_completedCycles kali',
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
          animation: _lotusAnimController,
          builder: (context, child) {
            final scale = 1.0 + (_lotusAnimController.value * 0.45);
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
            onPressed: _toggleLotusBreathing,
            icon: Icon(_isBreathingActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_isBreathingActive ? 'Hentikan Sesi Napas' : 'Mulai Sesi Napas Relaksasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBreathingActive ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // GAME 3: KARTU AFIRMASI
  // ==========================================
  Widget _buildAffirmationCardGame() {
    final card = _affirmationCards[_currentCardIndex];

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
          onTap: () {
            setState(() {
              _isCardFlipped = !_isCardFlipped;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: double.infinity,
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isCardFlipped
                    ? [AppColors.softSunshine, AppColors.softMint]
                    : [AppColors.surfaceCard, AppColors.surfaceCanvas],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isCardFlipped ? AppColors.primary : AppColors.outlineVariant,
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
                  _isCardFlipped ? card['quote']! : 'Tap untuk Membuka "${card['title']!}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _isCardFlipped ? 15 : 16,
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
              onPressed: () {
                setState(() {
                  _isCardFlipped = false;
                  _currentCardIndex =
                      (_currentCardIndex - 1 + _affirmationCards.length) %
                          _affirmationCards.length;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Sebelumnya'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Text(
              '${_currentCardIndex + 1} / ${_affirmationCards.length}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isCardFlipped = false;
                  _currentCardIndex =
                      (_currentCardIndex + 1) % _affirmationCards.length;
                });
              },
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

class _BubbleData {
  final String word;
  final String affirmation;
  final Color color;
  final Alignment alignment;
  bool isPopped;

  _BubbleData({
    required this.word,
    required this.affirmation,
    required this.color,
    required this.alignment,
    this.isPopped = false,
  });
}
