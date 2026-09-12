import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/views/tulis_jurnal_screen.dart';

class DaftarJurnalScreen extends StatefulWidget {
  const DaftarJurnalScreen({super.key});

  @override
  State<DaftarJurnalScreen> createState() => _DaftarJurnalScreenState();
}

class _DaftarJurnalScreenState extends State<DaftarJurnalScreen> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteJournal(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Jurnal?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan jurnal ini?',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                AppStateService.instance.deleteJournal(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jurnal berhasil dihapus')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final journalEntries = AppStateService.instance.journals;
        final query = _searchController.text.toLowerCase().trim();
        final filteredList = journalEntries.where((journal) {
          final matchesFilter = _selectedFilter == 'Semua' || journal.mood == _selectedFilter;
          final matchesQuery = query.isEmpty ||
              journal.preview.toLowerCase().contains(query) ||
              journal.title.toLowerCase().contains(query) ||
              journal.tags.any((t) => t.toLowerCase().contains(query));
          return matchesFilter && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top AppBar
                _buildAppBar(),

                // 2. Search & Filter Bar
                _buildSearchAndFilters(),

                // 3. Journal List
                Expanded(
                  child: filteredList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildJournalCard(filteredList[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TulisJurnalScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'Tulis Jurnal',
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

  // --- Top AppBar ---
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 48),
          Text(
            'Daftar Jurnal Harian',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 48), // spacer
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Sangat Sedih':
        return '😭';
      case 'Sedih':
        return '🙁';
      case 'Biasa Saja':
        return '😐';
      case 'Senang':
        return '😊';
      default:
        return '😊';
    }
  }

  // --- Search & Filter Bar ---
  Widget _buildSearchAndFilters() {
    final filters = ['Semua', 'Sangat Sedih', 'Sedih', 'Biasa Saja', 'Senang'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D3142).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                icon: const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                hintText: 'Cari jurnal atau tag (#Bersyukur)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.outline),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mood Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Journal Card ---
  Widget _buildJournalCard(JournalEntry journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date & Mood Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        journal.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: journal.moodBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getMoodEmoji(journal.mood)} ${journal.mood}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: journal.moodColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Content
          Text(
            '"${journal.preview}"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          const Divider(color: AppColors.surfaceVariant, height: 1),
          const SizedBox(height: 10),

          // Tags & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tags
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: journal.tags.map<Widget>((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCanvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Delete button
              IconButton(
                onPressed: () => _deleteJournal(journal.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.outline),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_note_rounded, size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'Belum ada jurnal yang sesuai',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau filter suasana hati',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
