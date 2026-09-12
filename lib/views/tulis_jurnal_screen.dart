import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

class TulisJurnalScreen extends StatefulWidget {
  const TulisJurnalScreen({super.key});

  @override
  State<TulisJurnalScreen> createState() => _TulisJurnalScreenState();
}

class _TulisJurnalScreenState extends State<TulisJurnalScreen> {
  final TextEditingController _contentController = TextEditingController();

  // Mood selection state (Default: 'Biasa Saja')
  int _selectedMoodIndex = 2;

  final List<Map<String, dynamic>> _moodList = [
    {
      'label': 'Sangat Sedih',
      'emoji': '😭',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAfFD9ERBTIdUjDu_q1Cinb0_WOLDXlfaWtrWQYyHfspvGqtae6U7jNgxuU5P4zsZ5ucSAZ1VAXv9KhPMbLIgQ7VHxE7EWhKedml3M0ApujamNTi8U1r6HsyIM1qwHAdfiDGVN5kopwSGZfuSpg_6Wg_VR2mSj-1JB4Ls3qa5fIh1d2fh16Y3umk5KhNR7jX1btbxjZmCf73lroTK-LGtb7d1gi4CwYhrZdkAC5xl1gdsPmkJVRLk1N6w',
      'color': AppColors.softPink,
      'textColor': AppColors.primary,
    },
    {
      'label': 'Sedih',
      'emoji': '🙁',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDIBMRJhqp0kT55TqTs8eDFzjppqqzw8Ht9OIJT2xb5utTZ0PhvSuhTOS-QWoocs5FT2mC1hLeU0S1aB2XA4W-KLYWxiRx-DyVlC-duBiA5jbox1viGcJqMxlUvHa03yqurXkTeY8yYYvogeKADds784yJPUGi9YD_M0VA5xNQy_x7DAkH7HVbH5nl0Yuh4gMIIm2MIaGWMvDRpv08BxRITOnx9M0m_qeJ7oD7jGKJsbb7ERFA6nqDC2w',
      'color': AppColors.softPink,
      'textColor': AppColors.primary,
    },
    {
      'label': 'Biasa Saja',
      'emoji': '😐',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuACi00D13_ZiPyyS58UuaeeYiZrp873t9NT8eyTKOFlw1XlcrWfFqpV3ZLwmO_xfGNl59Ap4KfR5LJhq1PJkvu6j0m100lpYoU1SAIKNXw4OgKlcwyTAYIgtNuZ1cx479S123z2lI-_lG3IOw0uCzWpy8_mTjBql4fmOsIJA_jXKQpaKcOs4WyiQLrhB2ycKAJ6FSM7IU5RIR43pjtHLtzh2yFqYo4S09_DjFALF687uXedmjTKnbf-2g',
      'color': AppColors.softSunshine,
      'textColor': AppColors.tertiary,
    },
    {
      'label': 'Senang',
      'emoji': '😊',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBGZcq6ZZVn9iQ2r6YPR_PKwRYrBt4zSnY9FbB_h4-1_KJWfJH9GolHN4m-vEtHdgQ8cdcchg-23m1DqqtchLmtgdGOKsTFa22GxFnfvzV8kPLTI0pPl-JOwORE7j53ozt55EsR5w53mYZ7KRwgi14ZMolUQym75iyEn9CuyU0mbn2nqJgHI8zlUd4sj_8imFSOh9Boa37ejMW7rZJ12YnI_YH25542MNrEOzSgw-wnklCBddTw7O-auQ',
      'color': AppColors.softMint,
      'textColor': AppColors.secondary,
    },
  ];

  // Tags selection state
  final List<String> _availableTags = [
    '#Bersyukur',
    '#Kerja',
    '#Keluarga',
    '#Cemas',
    '#SelfCare',
    '#Mindfulness',
  ];
  final Set<String> _selectedTags = {'#Keluarga'};

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _addNewTag() {
    final tagInputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Tambah Tag Baru',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: tagInputController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Contoh: Relaksasi, Liburan...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.outline,
              ),
              filled: true,
              fillColor: AppColors.surfaceCanvas,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final tag = tagInputController.text.trim();
                if (tag.isNotEmpty) {
                  final formattedTag = tag.startsWith('#') ? tag : '#$tag';
                  setState(() {
                    if (!_availableTags.contains(formattedTag)) {
                      _availableTags.add(formattedTag);
                    }
                    _selectedTags.add(formattedTag);
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _saveJournal() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan tuliskan cerita atau perasaan Anda terlebih dahulu.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final moodItem = _moodList[_selectedMoodIndex];
    final selectedMood = moodItem['label'];
    final currentUser = AppStateService.instance.userProfile;
    final now = DateTime.now();
    final newEntry = JournalEntry(
      id: now.millisecondsSinceEpoch.toString(),
      userEmail: currentUser.email,
      title: text.length > 30 ? '${text.substring(0, 30)}...' : text,
      date: _formatJournalDate(now),
      preview: text,
      mood: selectedMood,
      moodColor: moodItem['textColor'] as Color,
      moodBg: moodItem['color'] as Color,
      tags: _selectedTags.toList(),
    );

    AppStateService.instance.addJournal(newEntry);

    Navigator.pop(context, {
      'content': text,
      'mood': selectedMood,
      'tags': _selectedTags.toList(),
      'date': newEntry.date,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Jurnal dengan suasana "$selectedMood" berhasil disimpan ✨',
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top AppBar
            _buildAppBar(),

            // 2. Main Scrollable Canvas
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date / Time Display
                    _buildDateTimeBadge(),
                    const SizedBox(height: 20),

                    // Mood Selector Section
                    _buildMoodSelectorSection(),
                    const SizedBox(height: 24),

                    // Text Area Section
                    _buildTextAreaSection(),
                    const SizedBox(height: 24),

                    // Tags Section
                    _buildTagsSection(),
                    const SizedBox(height: 32),

                    // Main Action Button
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- AppBar ---
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            'Tulis Jurnal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          TextButton(
            onPressed: _saveJournal,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  String _formatJournalDate(DateTime now) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final dayName = days[now.weekday - 1];
    final day = now.day;
    final monthName = months[now.month - 1];
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$dayName, $day $monthName $year • $hour:$minute WIB';
  }

  // --- Date Time Badge ---
  Widget _buildDateTimeBadge() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          _formatJournalDate(DateTime.now()),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Mood Selector Section ---
  Widget _buildMoodSelectorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bagaimana perasaanmu?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_moodList.length, (index) {
              final mood = _moodList[index];
              final bool isSelected = _selectedMoodIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMoodIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? mood['color']
                              : AppColors.surfaceCard,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? (mood['color'] as Color).withValues(
                                      alpha: 0.4,
                                    )
                                  : const Color(
                                      0xFF2D3142,
                                    ).withValues(alpha: 0.04),
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            mood['imageUrl'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Text(
                                    mood['emoji'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 72,
                        child: Text(
                          mood['label'],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- Text Area Section ---
  Widget _buildTextAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ceritakan harimu...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D3142).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 7,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan apa yang ada di pikiranmu saat ini...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Tags Section ---
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tambah Tag',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D3142).withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),

            // Add new tag button
            GestureDetector(
              onTap: _addNewTag,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.outline,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Main Save Button ---
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveJournal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Simpan Jurnal',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
