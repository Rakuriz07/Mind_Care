import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class MeditasiTidurScreen extends StatefulWidget {
  const MeditasiTidurScreen({super.key});

  @override
  State<MeditasiTidurScreen> createState() => _MeditasiTidurScreenState();
}

class _MeditasiTidurScreenState extends State<MeditasiTidurScreen>
    with TickerProviderStateMixin {
  // Audio Player Instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = true;
  double _playbackProgress = 0.0;
  int _currentSeconds = 0;
  int _totalSeconds = 600; // 10 minutes default
  double _volume = 0.8;
  bool _isMuted = false;
  bool _isNightDimmerActive = false;
  Timer? _playbackTimer;

  // Breathing 4-7-8 Phase State
  int _breathTimerSeconds = 0;
  String _breathPhase = 'Tarik Napas'; // 'Tarik Napas' (4s), 'Tahan' (7s), 'Hembuskan' (8s)
  int _breathCycleCount = 1;
  late AnimationController _breathAnimController;
  late Animation<double> _breathScaleAnimation;

  // Meditation Sessions List
  final List<Map<String, dynamic>> _sessionList = [
    {
      'title': 'Relaksasi Pernapasan 4-7-8',
      'subtitle': 'Panduan Ritme Pernapasan Pengantar Tidur',
      'technique': 'Teknik 4-7-8',
      'durationMinutes': 10,
    },
    {
      'title': 'Body Scan Tidur Pulas',
      'subtitle': 'Melepaskan Ketegangan Otot dari Kepala ke Kaki',
      'technique': 'Pelepasan Ketegangan',
      'durationMinutes': 15,
    },
    {
      'title': 'Visualisasi Hutan & Bintang',
      'subtitle': 'Imajinasi Tenang di Bawah Langit Malam',
      'technique': 'Guided Imagery',
      'durationMinutes': 20,
    },
    {
      'title': 'Mindfulness Pengantar Tidur',
      'subtitle': 'Menenangkan Pikiran yang Masih Sibuk',
      'technique': 'Mindful Awareness',
      'durationMinutes': 30,
    },
  ];
  late Map<String, dynamic> _selectedSession;

  // Sound definitions with offline assets & fallback preview URLs
  final List<Map<String, dynamic>> _soundList = [
    {
      'name': 'Hujan',
      'icon': Icons.water_drop_rounded,
      'asset': 'audio/hujan.mp3',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2515/2515-preview.mp3',
    },
    {
      'name': 'Hutan',
      'icon': Icons.forest_rounded,
      'asset': 'audio/hutan.mp3',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2437/2437-preview.mp3',
    },
    {
      'name': 'Ombak',
      'icon': Icons.water_rounded,
      'asset': 'audio/ombak.mp3',
      'url': 'https://assets.mixkit.co/active_storage/sfx/1198/1198-preview.mp3',
    },
    {
      'name': 'Api Unggun',
      'icon': Icons.local_fire_department_rounded,
      'asset': 'audio/api.mp3',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2473/2473-preview.mp3',
    },
    {
      'name': 'Malam',
      'icon': Icons.nights_stay_rounded,
      'asset': 'audio/malam.mp3',
      'url': 'https://assets.mixkit.co/active_storage/sfx/2528/2528-preview.mp3',
    },
    {
      'name': 'Piano Lembut',
      'icon': Icons.piano_rounded,
      'asset': 'audio/piano.mp3',
      'url': 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
    },
  ];

  late String _selectedSound;
  String _selectedTimer = '10m';

  @override
  void initState() {
    super.initState();
    _selectedSession = _sessionList[0];
    _selectedSound = _soundList[0]['name'];

    // Breathing Animation Controller Setup
    _breathAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathScaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _breathAnimController, curve: Curves.easeInOut),
    );

    _breathAnimController.forward();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      await _playSelectedSound();
    } catch (_) {}
    _startPlaybackTimer();
  }

  Future<void> _playSelectedSound() async {
    final sound = _soundList.firstWhere(
      (element) => element['name'] == _selectedSound,
      orElse: () => _soundList[0],
    );

    try {
      await _audioPlayer.stop();
      if (_isPlaying) {
        try {
          await _audioPlayer.play(AssetSource(sound['asset']));
        } catch (_) {
          await _audioPlayer.play(UrlSource(sound['url']));
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _breathAnimController.dispose();
    _playbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    if (!_isPlaying) return;

    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        // Update main session countdown
        if (_currentSeconds < _totalSeconds) {
          _currentSeconds++;
          _playbackProgress = _currentSeconds / _totalSeconds;
        } else {
          _isPlaying = false;
          _audioPlayer.pause();
          _breathAnimController.stop();
          timer.cancel();
          _showSessionCompletedDialog();
        }

        // Update 4-7-8 Breathing Cycle Logic
        _breathTimerSeconds++;
        if (_breathTimerSeconds <= 4) {
          _breathPhase = 'Tarik Napas (Hidung)';
          if (!_breathAnimController.isAnimating && _breathAnimController.status != AnimationStatus.forward) {
            _breathAnimController.duration = const Duration(seconds: 4);
            _breathAnimController.forward(from: 0.0);
          }
        } else if (_breathTimerSeconds <= 11) { // 4 + 7 = 11s
          _breathPhase = 'Tahan Napas';
          _breathAnimController.stop();
        } else if (_breathTimerSeconds <= 19) { // 11 + 8 = 19s
          _breathPhase = 'Hembuskan (Mulut)';
          if (!_breathAnimController.isAnimating && _breathAnimController.status != AnimationStatus.reverse) {
            _breathAnimController.duration = const Duration(seconds: 8);
            _breathAnimController.reverse(from: 1.0);
          }
        } else {
          _breathTimerSeconds = 0;
          _breathCycleCount++;
        }
      });
    });
  }

  Future<void> _togglePlayPause() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _breathAnimController.forward();
      _startPlaybackTimer();
      try {
        await _audioPlayer.resume();
      } catch (_) {
        _playSelectedSound();
      }
    } else {
      _breathAnimController.stop();
      _playbackTimer?.cancel();
      try {
        await _audioPlayer.pause();
      } catch (_) {}
    }
  }

  void _rewind10Seconds() {
    setState(() {
      _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
      _playbackProgress = _currentSeconds / _totalSeconds;
    });
  }

  void _forward10Seconds() {
    setState(() {
      _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
      _playbackProgress = _currentSeconds / _totalSeconds;
    });
  }

  void _selectSound(String soundName) {
    setState(() {
      _selectedSound = soundName;
    });
    _playSelectedSound();
  }

  void _selectTimer(String timerValue) {
    setState(() {
      _selectedTimer = timerValue;
      if (timerValue == '5m') {
        _totalSeconds = 300;
      } else if (timerValue == '10m') {
        _totalSeconds = 600;
      } else if (timerValue == '15m') {
        _totalSeconds = 900;
      } else if (timerValue == '30m') {
        _totalSeconds = 1800;
      } else if (timerValue == '60m') {
        _totalSeconds = 3600;
      }
      _currentSeconds = (_playbackProgress * _totalSeconds).toInt();
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _audioPlayer.setVolume(0.0);
      } else {
        _audioPlayer.setVolume(_volume);
      }
    });
  }

  void _showSessionSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Panduan Meditasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_sessionList.length, (index) {
                final session = _sessionList[index];
                final isSelected = _selectedSession['title'] == session['title'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.softMint.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.softMint : Colors.white12,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppColors.softMint : Colors.white10,
                      child: Icon(
                        Icons.self_improvement_rounded,
                        color: isSelected ? AppColors.onSecondaryContainer : Colors.white70,
                      ),
                    ),
                    title: Text(
                      session['title'],
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${session['technique']} • ${session['durationMinutes']} Menit',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.softMint)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSession = session;
                        _selectTimer('${session['durationMinutes']}m');
                        _currentSeconds = 0;
                        _playbackProgress = 0.0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSessionCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nights_stay_rounded,
                  color: AppColors.softSunshine,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sesi Selesai 🌙',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tubuh dan pikiran Anda kini lebih rileks. Semoga tidur Anda nyenyak dan berkualitas malam ini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentSeconds = 0;
                            _playbackProgress = 0.0;
                            _isPlaying = true;
                            _startPlaybackTimer();
                            _audioPlayer.resume();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ulangi Sesi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.maybePop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Tidur Sekarang'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isNightDimmerActive
                ? [
                    const Color(0xFF0D0B24),
                    const Color(0xFF141238),
                    const Color(0xFF0D0B24),
                  ]
                : [
                    const Color(0xFF1E1B4B),
                    const Color(0xFF312E81),
                    const Color(0xFF1E1B4B),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top AppBar
              _buildAppBar(context),

              // 2. Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hero Mascot Card with Tap to Change Session
                      _buildHeroIllustration(),
                      const SizedBox(height: 12),

                      // Audio & Breathing Player Card
                      _buildPlayerCard(),
                      const SizedBox(height: 20),

                      // Settings Section (Suara Latar, Timer, & Sleep Mode)
                      _buildSettingsSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- AppBar ---
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
            splashRadius: 24,
          ),
          Text(
            'Meditasi Tidur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Night Dimmer Quick Toggle Button
          IconButton(
            tooltip: 'Mode Redup Layar',
            onPressed: () {
              setState(() {
                _isNightDimmerActive = !_isNightDimmerActive;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF312E81),
                  content: Text(
                    _isNightDimmerActive ? 'Mode Redup Aktif 🌙' : 'Mode Standar 💡',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            icon: Icon(
              _isNightDimmerActive ? Icons.bedtime_rounded : Icons.bedtime_outlined,
              color: _isNightDimmerActive ? AppColors.softSunshine : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Illustration ---
  Widget _buildHeroIllustration() {
    return GestureDetector(
      onTap: _showSessionSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing Ambient Circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.softMint.withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softMint.withOpacity(0.2),
                          blurRadius: 36,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  // Illustration Image
                  ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuArqcQC5EHSvlcPSb5ba4yExhJkb9f1AL7ON29eTZg2Y2Qkxavaz-hm_T5hSvjyIK7IhSG18nw2LKxhfTHhIuwdiHqPG0BUOXeEws4tKoWNR7WSmgn4mI4uxX2Em6a7gfC4Px54wfXi1-UcivKkhGBqfLUY2vzHXNZIphCX1JFOymmlDAIHjpEyCD7qcCa72F6V_tBWmoV_aVbeM8jpUcN5Xi76uVEVsmbEL6mcxOVGU4yJA90nJZHjpg',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 140,
                        height: 140,
                        color: const Color(0xFF312E81),
                        child: const Icon(
                          Icons.nights_stay_rounded,
                          color: AppColors.softMint,
                          size: 54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ganti Tema Panduan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.softMint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.softMint),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Audio Player Card ---
  Widget _buildPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Session Title
          Text(
            _selectedSession['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_selectedSound • Siklus ke-$_breathCycleCount • $_selectedTimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Breathing Visualizer with Animated 4-7-8 Phase Display
          _buildBreathingVisualizer(),
          const SizedBox(height: 16),

          // Progress Bar / Slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: AppColors.softMint,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: _playbackProgress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    setState(() {
                      _playbackProgress = value;
                      _currentSeconds = (value * _totalSeconds).toInt();
                    });
                  },
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentSeconds),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    _formatDuration(_totalSeconds),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Controls Rows (Rewind, Play/Pause, Forward)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind Button
              IconButton(
                onPressed: _rewind10Seconds,
                icon: const Icon(Icons.replay_10_rounded),
                iconSize: 32,
                color: Colors.white70,
                hoverColor: Colors.white10,
              ),
              const SizedBox(width: 20),

              // Play / Pause Button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Forward Button
              IconButton(
                onPressed: _forward10Seconds,
                icon: const Icon(Icons.forward_10_rounded),
                iconSize: 32,
                color: Colors.white70,
                hoverColor: Colors.white10,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Volume & Mute Controls
          Row(
            children: [
              IconButton(
                onPressed: _toggleMute,
                icon: Icon(
                  _isMuted || _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    activeTrackColor: AppColors.softPink,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                  ),
                  child: Slider(
                    value: _isMuted ? 0.0 : _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setState(() {
                        _volume = val;
                        _isMuted = false;
                      });
                      _audioPlayer.setVolume(val);
                    },
                  ),
                ),
              ),
              Text(
                '${((_isMuted ? 0.0 : _volume) * 100).toInt()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Breathing Visualizer (Pulsing Animation + Real-time Phase) ---
  Widget _buildBreathingVisualizer() {
    return AnimatedBuilder(
      animation: _breathAnimController,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  Transform.scale(
                    scale: _breathScaleAnimation.value * 1.15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softMint.withOpacity(0.18),
                      ),
                    ),
                  ),
                  // Inner Expanding Ring
                  Transform.scale(
                    scale: _breathScaleAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softMint.withOpacity(0.35),
                      ),
                    ),
                  ),
                  // Center Core Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.air_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Breathing Instruction text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _breathPhase,
                key: ValueKey(_breathPhase),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softMint,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Settings Section (Suara Latar & Timer) ---
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Suara Latar Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suara Latar (Ambient)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Pilih Suara',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.softMint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_soundList.length, (index) {
              final sound = _soundList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: _buildSoundChip(sound['name'], sound['icon']),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // 2. Timer Selection
        Text(
          'Durasi Sleep Timer',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTimerChip('5m')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimerChip('10m')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimerChip('15m')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimerChip('30m')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimerChip('60m')),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundChip(String soundName, IconData icon) {
    final bool isSelected = _selectedSound == soundName;
    return GestureDetector(
      onTap: () => _selectSound(soundName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softMint : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.onSecondaryContainer : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              soundName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.onSecondaryContainer : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerChip(String timerValue) {
    final bool isSelected = _selectedTimer == timerValue;
    return GestureDetector(
      onTap: () => _selectTimer(timerValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPink : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          timerValue,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.onPrimaryContainer : Colors.white,
          ),
        ),
      ),
    );
  }
}
