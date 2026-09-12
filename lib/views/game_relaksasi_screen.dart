import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/widgets/game/affirmation_card_widget.dart';
import 'package:mindcare/widgets/game/bubble_calm_widget.dart';
import 'package:mindcare/widgets/game/ripples_of_peace_widget.dart';

class GameRelaksasiScreen extends StatefulWidget {
  const GameRelaksasiScreen({super.key});

  @override
  State<GameRelaksasiScreen> createState() => _GameRelaksasiScreenState();
}

class _GameRelaksasiScreenState extends State<GameRelaksasiScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  // Selected Game Tab: 0 = Bubble Calm, 1 = Ripples Water, 2 = Kartu Afirmasi
  int _selectedTab = 0;

  // --- GAME 1: BUBBLE CALM STATE ---
  int _peaceScore = 0;
  int _poppedCount = 0;
  String _currentAffirmation =
      'Sentuh gelembung cemas di bawah untuk meletuskannya & melepaskan beban! ';

  final List<Map<String, String>> _wordPairs = const [
    {'word': 'Khawatir', 'affirm': 'Saya aman dan hidup di saat ini '},
    {'word': 'Beban', 'affirm': 'Saya melepaskan apa yang tidak bisa saya kontrol '},
    {'word': 'Stres', 'affirm': 'Setiap napas membawa kedamaian ke jiwa saya '},
    {'word': 'Overthinking', 'affirm': 'Pikiran saya tenang dan jernih seperti air danau '},
    {'word': 'Lelah', 'affirm': 'Saya mengizinkan tubuh dan pikiran saya beristirahat '},
    {'word': 'Cemas', 'affirm': 'Saya lebih kuat dari rasa cemas yang saya rasakan '},
    {'word': 'Ragu', 'affirm': 'Saya percaya pada potensi dan perjalanan hidup saya '},
    {'word': 'Takut', 'affirm': 'Keberanian tumbuh di dalam hati saya setiap hari '},
  ];

  late List<BubbleData> _bubbles;

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

  // --- GAME 3: KARTU AFIRMASI STATE ---
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
    {
      'title': 'Apresiasi Diri',
      'quote': 'Tubuh dan pikiran Anda telah berjuang keras. Berikan istirahat dan kasih sayang yang hangat.',
      'icon': '💖',
      'category': 'Self-Care',
    },
    {
      'title': 'Langkah Keberanian',
      'quote': 'Setiap kemajuan kecil yang Anda buat adalah apresiasi berharga untuk kesehatan mental Anda.',
      'icon': '🌱',
      'category': 'Growth',
    },
    {
      'title': 'Kebijaksanaan Diri',
      'quote': 'Biarkan pikiran negatif lewat seperti awan di langit. Anda adalah langitnya, bukan awannya.',
      'icon': '☁️',
      'category': 'Inner Peace',
    },
    {
      'title': 'Harapan Baru',
      'quote': 'Setiap matahari terbit membawa kesempatan baru untuk memulai kembali dengan hati yang lapang.',
      'icon': '🌅',
      'category': 'Hope',
    },
    {
      'title': 'Menghadapi Cemas',
      'quote': 'Rasa cemas adalah sinyal sementara, bukan takdir Anda. Anda jauh lebih kuat daripada ketakutan Anda.',
      'icon': '🛡️',
      'category': 'Courage',
    },
    {
      'title': 'Nilai Diri Sejati',
      'quote': 'Anda berharga bukan karena apa yang Anda capai, melainkan karena kebaikan di dalam diri Anda.',
      'icon': '💎',
      'category': 'Self-Worth',
    },
    {
      'title': 'Kedamaian Pikiran',
      'quote': 'Lepaskan apa yang tidak bisa Anda kendalikan. Salurkan energi untuk hal-hal baik di depan Anda.',
      'icon': '🕊️',
      'category': 'Clarity',
    },
    {
      'title': 'Keheningan Jiwa',
      'quote': 'Rasakan setiap hembusan napas. Keheningan adalah tempat terbaik untuk memulihkan energi.',
      'icon': '🧘',
      'category': 'Mindfulness',
    },
    {
      'title': 'Rasa Syukur',
      'quote': 'Selalu ada hal sederhana yang patut disyukuri hari ini, sekecil apapun itu.',
      'icon': '🌻',
      'category': 'Gratitude',
    },
    {
      'title': 'Keseimbangan Emosi',
      'quote': 'Semua perasaan Anda valid. Dengarkan dan peluk emosi Anda tanpa mengadili diri sendiri.',
      'icon': '⚖️',
      'category': 'Balance',
    },
    {
      'title': 'Proses Pemulihan',
      'quote': 'Percayalah pada proses pemulihan diri Anda. Setiap hari membawa kesembuhan yang baru.',
      'icon': '🪴',
      'category': 'Healing',
    },
    {
      'title': 'Keteguhan Jiwa',
      'quote': 'Ingatlah bahwa Anda telah berhasil melewati 100% hari-hari tersulit dalam hidup Anda hingga hari ini.',
      'icon': '⛰️',
      'category': 'Strength',
    },
    {
      'title': 'Istirahat Nyenyak',
      'quote': 'Malam adalah saatnya mengistirahatkan pikiran. Biarkan semua kekhawatiran tertidur lelap.',
      'icon': '🌙',
      'category': 'Rest',
    },
    {
      'title': 'Kebahagiaan Sederhana',
      'quote': 'Temukan kedamaian dalam hal-hal sederhana: udara segar, senyuman hangat, atau keheningan pagi.',
      'icon': '☕',
      'category': 'Joy',
    },
    {
      'title': 'Kelembutan Hati',
      'quote': 'Bicaralah pada diri sendiri dengan lembut, sebagaimana Anda berbicara pada sahabat tercinta.',
      'icon': '💌',
      'category': 'Kindness',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initBubbles();
    _initAudio();
  }

  void _initBubbles() {
    _bubbles = List.generate(6, (index) {
      final pair = _wordPairs[index % _wordPairs.length];
      return BubbleData(
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
        _bubbles[index] = BubbleData(
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
                      color: AppColors.softSkyBlue,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.iceBlueContainer),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded,
                            color: AppColors.skyBlueAccent, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pilih permainan relaksasi interaktif di bawah untuk meredakan stres & ketegangan Anda.',
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

                  // Tab Buttons (Bubble Calm, Ripples Water, Kartu Afirmasi)
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
                          label: 'Ripples Water',
                          icon: Icons.water_drop_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton(
                          index: 2,
                          label: 'Afirmasi',
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
        backgroundColor: isSelected ? AppColors.skyBlueAccent : AppColors.surfaceCard,
        foregroundColor: isSelected ? Colors.white : AppColors.onSurfaceVariant,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.skyBlueAccent : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGameView() {
    switch (_selectedTab) {
      case 0:
        return BubbleCalmWidget(
          peaceScore: _peaceScore,
          poppedCount: _poppedCount,
          currentAffirmation: _currentAffirmation,
          bubbles: _bubbles,
          onPopBubble: _popBubble,
          onReset: _resetBubbleGame,
        );
      case 1:
        return const RipplesOfPeaceWidget();
      case 2:
        return AffirmationCardWidget(
          cards: _affirmationCards,
        );
      default:
        return BubbleCalmWidget(
          peaceScore: _peaceScore,
          poppedCount: _poppedCount,
          currentAffirmation: _currentAffirmation,
          bubbles: _bubbles,
          onPopBubble: _popBubble,
          onReset: _resetBubbleGame,
        );
    }
  }
}
