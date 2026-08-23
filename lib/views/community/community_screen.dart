import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Semua',
    '#CurhatKecemasan',
    '#SelfCare',
    '#PejuangSkripsi',
    '#BurnoutKerja',
    '#MotivasiPagi',
  ];

  final List<Map<String, String>> _pseudonyms = [
    {
      'name': 'PejuangTenang',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'SahabatJiwa',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'BintangMalam',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'LenteraHati',
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'MentariPagi',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callEmergencyHotline() async {
    final Uri uri = Uri.parse('tel:119');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackbar('Call Center 119: Layanan kesehatan mental Kemenkes RI aktif 24/7.');
      }
    } catch (_) {
      _showSnackbar('Call Center 119: Layanan kesehatan mental Kemenkes RI aktif 24/7.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAvatar({
    required String avatarUrl,
    required String email,
    double radius = 18,
  }) {
    final currentUser = AppStateService.instance.userProfile;
    if (email.isNotEmpty && email == currentUser.email && currentUser.avatarBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(currentUser.avatarBytes!),
      );
    }
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: avatarUrl.isEmpty
            ? Icon(Icons.person_rounded, size: radius, color: AppColors.primary)
            : null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryContainer,
      child: Icon(Icons.person_rounded, size: radius, color: AppColors.primary),
    );
  }

  void _showCreatePostSheet() {
    final currentUser = AppStateService.instance.userProfile;
    bool useRealIdentity = false;
    Map<String, String> selectedPseudonym = _pseudonyms.first;
    String selectedTag = '#CurhatKecemasan';
    final TextEditingController contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeAuthorName =
                useRealIdentity ? currentUser.name : selectedPseudonym['name']!;
            final activeAvatarUrl =
                useRealIdentity ? currentUser.avatarUrl : selectedPseudonym['avatar']!;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
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
                            color: AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tulis Cerita Baru ✨',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              useRealIdentity ? 'Identitas Asli' : '100% Anonim',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Identity Selection Segment
                      Text(
                        'Pilih Mode Identitas Pengirim:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              selected: !useRealIdentity,
                              label: Center(
                                child: Text('🎭 Nama Samaran (Anonim)'),
                              ),
                              selectedColor: AppColors.primaryContainer,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: !useRealIdentity ? FontWeight.bold : FontWeight.w500,
                                color: !useRealIdentity
                                    ? AppColors.onPrimaryContainer
                                    : AppColors.onSurfaceVariant,
                              ),
                              onSelected: (val) {
                                if (val) setSheetState(() => useRealIdentity = false);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              selected: useRealIdentity,
                              label: Center(
                                child: Text('👤 ${currentUser.name}'),
                              ),
                              selectedColor: AppColors.secondaryContainer,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: useRealIdentity ? FontWeight.bold : FontWeight.w500,
                                color: useRealIdentity ? AppColors.secondary : AppColors.onSurfaceVariant,
                              ),
                              onSelected: (val) {
                                if (val) setSheetState(() => useRealIdentity = true);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Pseudonym Selector (Only if Anonim)
                      if (!useRealIdentity) ...[
                        Text(
                          'Pilih Nama Samaran:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _pseudonyms.map((p) {
                              final isSelected = selectedPseudonym['name'] == p['name'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  avatar: CircleAvatar(
                                    backgroundImage: NetworkImage(p['avatar']!),
                                  ),
                                  label: Text(p['name']!),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryContainer,
                                  labelStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.onPrimaryContainer
                                        : AppColors.onSurface,
                                  ),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => selectedPseudonym = p);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Category Selector
                      Text(
                        'Pilih Topik Diskusi:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _categories.where((c) => c != 'Semua').map((tag) {
                          final isSelected = selectedTag == tag;
                          return ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: AppColors.secondaryContainer,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                            ),
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedTag = tag);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Post Input Text
                      TextField(
                        controller: contentController,
                        maxLines: 4,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              'Tuliskan perasaan, beban pikiran, atau kata penyemangat yang ingin Anda bagikan...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
                          filled: true,
                          fillColor: AppColors.surfaceCanvas,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final content = contentController.text.trim();
                            if (content.isEmpty) {
                              _showSnackbar('Silakan tulis cerita Anda sebelum mengirim.');
                              return;
                            }

                            final newPost = CommunityPost(
                              id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                              authorEmail: currentUser.email,
                              authorPseudonym: activeAuthorName,
                              authorAvatar: activeAvatarUrl,
                              content: content,
                              categoryTag: selectedTag,
                              likesCount: 0,
                              commentsCount: 0,
                              date: 'Baru saja',
                              isLiked: false,
                            );

                            AppStateService.instance.addCommunityPost(newPost);
                            Navigator.pop(context);
                            _showSnackbar('Cerita Anda berhasil dibagikan ke komunitas ✨');
                          },
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            'Kirim ke Komunitas',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeletePost(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Cerita Ini?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Cerita Anda akan dihapus secara permanen dari komunitas.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              AppStateService.instance.deleteCommunityPost(post.id);
              Navigator.pop(context);
              _showSnackbar('Cerita Anda berhasil dihapus 🗑️');
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePost(CommunityPost post) {
    Clipboard.setData(
      ClipboardData(text: '${post.authorPseudonym} di MindCare Komunitas:\n"${post.content}"'),
    );
    _showSnackbar('Pesan cerita berhasil disalin ke clipboard 📋');
  }

  void _showCommentSheet(CommunityPost post) {
    final currentUser = AppStateService.instance.userProfile;
    final TextEditingController commentController = TextEditingController();
    bool useRealIdentity = false;
    Map<String, String> selectedPseudonym = _pseudonyms[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeAuthorName =
                useRealIdentity ? currentUser.name : selectedPseudonym['name']!;
            final activeAvatarUrl =
                useRealIdentity ? currentUser.avatarUrl : selectedPseudonym['avatar']!;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
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
                            color: AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Original Post Snippet
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(
                              avatarUrl: post.authorAvatar,
                              email: post.authorEmail,
                              radius: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorPseudonym,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    post.content,
                                    maxLines: 2,
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
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Komentar Dukungan (${post.comments.length}):',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Real-Time 💬',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Comments List
                      if (post.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              'Belum ada komentar. Berikan kata-kata penyemangat pertama! 💙',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.outline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: post.comments.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final c = post.comments[index];
                              final isMyComment =
                                  c.authorEmail.isNotEmpty && c.authorEmail == currentUser.email;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMyComment
                                      ? AppColors.primaryContainer.withValues(alpha: 0.3)
                                      : AppColors.surfaceCanvas,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isMyComment
                                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                                      : null,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAvatar(
                                      avatarUrl: c.authorAvatar,
                                      email: c.authorEmail,
                                      radius: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    c.authorPseudonym,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  if (isMyComment) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        'Anda',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    c.date,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      color: AppColors.outline,
                                                    ),
                                                  ),
                                                  if (isMyComment ||
                                                      post.authorEmail == currentUser.email) ...[
                                                    const SizedBox(width: 4),
                                                    InkWell(
                                                      onTap: () {
                                                        AppStateService.instance
                                                            .deleteCommunityComment(post.id, c.id);
                                                        setSheetState(() {});
                                                        _showSnackbar('Komentar berhasil dihapus 🗑️');
                                                      },
                                                      child: const Icon(
                                                        Icons.delete_outline_rounded,
                                                        size: 14,
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            c.content,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 14),

                      // Comment Identity Option bar
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setSheetState(() => useRealIdentity = !useRealIdentity);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: useRealIdentity
                                    ? AppColors.secondaryContainer
                                    : AppColors.surfaceCanvas,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                useRealIdentity ? 'Kirim sbg ${currentUser.name}' : 'Kirim sbg Anonim',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: useRealIdentity
                                      ? AppColors.secondary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Add Comment Input Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Beri kata penyemangat...',
                                hintStyle:
                                    GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
                                filled: true,
                                fillColor: AppColors.surfaceCanvas,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              final text = commentController.text.trim();
                              if (text.isEmpty) return;

                              final newComment = CommunityComment(
                                id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
                                authorEmail: currentUser.email,
                                authorPseudonym: activeAuthorName,
                                authorAvatar: activeAvatarUrl,
                                content: text,
                                date: 'Baru saja',
                              );

                              AppStateService.instance.addCommentToPost(post.id, newComment);
                              commentController.clear();
                              setSheetState(() {});
                              _showSnackbar('Komentar dukungan Anda berhasil dikirim! ❤️');
                            },
                            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityPost>>(
      stream: AppStateService.instance.realTimeCommunityStream,
      builder: (context, snapshot) {
        final allPosts = snapshot.data ?? AppStateService.instance.realTimeCommunityPosts;
        final query = _searchController.text.toLowerCase().trim();

        final filteredPosts = allPosts.where((post) {
          final matchesCategory =
              _selectedCategory == 'Semua' || post.categoryTag == _selectedCategory;
          final matchesQuery = query.isEmpty ||
              post.content.toLowerCase().contains(query) ||
              post.authorPseudonym.toLowerCase().contains(query) ||
              post.categoryTag.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // Top Community Header
                _buildHeader(),

                // Scrollable Feed & Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crisis Hotline Banner
                        _buildCrisisBanner(),
                        const SizedBox(height: 16),

                        // Support Groups Bento Carousel
                        _buildSupportGroupsBento(),
                        const SizedBox(height: 18),

                        // Search & Topic Filter Chips
                        _buildSearchAndFilters(),
                        const SizedBox(height: 18),

                        // Feed Header Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Diskusi Sebaya (${filteredPosts.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Real-Time',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Posts List or Empty State
                        if (filteredPosts.isEmpty)
                          _buildEmptyState()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredPosts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _buildPostCard(filteredPosts[index]);
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showCreatePostSheet,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.edit_note_rounded, size: 22),
            label: Text(
              'Tulis Cerita',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCanvas,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Komunitas MindCare',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Ruang Aman Dukungan Sebaya',
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
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _callEmergencyHotline,
            tooltip: 'Call Center 119',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softPink.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruang Bersama 100% Bebas Penghakiman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Saling mendengarkan & memberikan pelukan emosional hangat. Butuh bantuan krisis segera?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _callEmergencyHotline,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              'Call 119 📞',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroupsBento() {
    final groups = [
      {
        'title': 'Ruang Ketenangan',
        'subtitle': 'Bebas Overthinking & Cemas',
        'tag': '#CurhatKecemasan',
        'color': AppColors.secondary,
        'bgColor': AppColors.secondaryContainer.withValues(alpha: 0.4),
      },
      {
        'title': 'Pejuang Skripsi',
        'subtitle': 'Stres Akademik & Mandiri',
        'tag': '#PejuangSkripsi',
        'color': AppColors.primary,
        'bgColor': AppColors.primaryContainer.withValues(alpha: 0.4),
      },
      {
        'title': 'Manajemen Burnout',
        'subtitle': 'Keseimbangan Kerjaan',
        'tag': '#BurnoutKerja',
        'color': AppColors.tertiary,
        'bgColor': AppColors.softSunshine.withValues(alpha: 0.5),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: groups.map((g) {
          final tag = g['tag'] as String;
          final isSelected = _selectedCategory == tag;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = isSelected ? 'Semua' : tag;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 180,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? (g['bgColor'] as Color) : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? (g['color'] as Color) : (g['color'] as Color).withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: g['bgColor'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.groups_rounded, color: g['color'] as Color, size: 18),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: g['color'] as Color, size: 16),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    g['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    g['subtitle'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Cari kata kunci cerita, topik, atau nama samaran...',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceCard,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final currentUser = AppStateService.instance.userProfile;
    final isMyPost = post.authorEmail.isNotEmpty && post.authorEmail == currentUser.email;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMyPost
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
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
          // Author Header & Options Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(
                avatarUrl: post.authorAvatar,
                email: post.authorEmail,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorPseudonym,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (isMyPost)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cerita Anda ✨',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          post.date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.outline,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            post.categoryTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isMyPost)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.outline),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (val) {
                    if (val == 'delete') _confirmDeletePost(post);
                    if (val == 'share') _sharePost(post);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, size: 16, color: AppColors.onSurface),
                          const SizedBox(width: 8),
                          Text('Salin Teks', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Hapus Cerita', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.outline),
                  onPressed: () => _sharePost(post),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Post Text Content
          Text(
            post.content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: 10),

          // Action Buttons: Likes & Comments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                    AppStateService.instance.toggleLikePost(post.id);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: post.isLiked ? AppColors.error : AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Pelukan & Dukungan (${post.likesCount})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: post.isLiked ? FontWeight.bold : FontWeight.w500,
                              color: post.isLiked ? AppColors.error : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: InkWell(
                  onTap: () => _showCommentSheet(post),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mode_comment_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Komentar (${post.comments.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Cerita Komunitas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Seluruh data komunitas telah dibersihkan. Jadilah orang pertama yang membagikan pesan dukungan atau cerita hangatmu secara anonim maupun langsung!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCreatePostSheet,
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: Text(
              'Tulis Cerita Pertama ✨',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
