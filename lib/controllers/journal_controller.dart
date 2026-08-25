import 'package:flutter/material.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

class JournalController extends ChangeNotifier {
  static final JournalController _instance = JournalController._internal();
  static JournalController get instance => _instance;

  JournalController._internal();

  String _searchQuery = '';
  String _selectedMoodFilter = 'Semua';

  String get searchQuery => _searchQuery;
  String get selectedMoodFilter => _selectedMoodFilter;

  // --- [READ] Membaca list jurnal yang difilter ---
  List<JournalEntry> get journals {
    final allJournals = AppStateService.instance.journals;
    return allJournals.where((j) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          j.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.preview.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMood =
          _selectedMoodFilter == 'Semua' ||
          j.mood.toLowerCase() == _selectedMoodFilter.toLowerCase();

      return matchesSearch && matchesMood;
    }).toList();
  }

  // --- [CREATE] Menambahkan jurnal baru ---
  Future<void> addJournal({
    required String title,
    required String content,
    required String mood,
    required Color moodColor,
    required Color moodBg,
    required List<String> tags,
  }) async {
    final now = DateTime.now();
    final dateStr =
        'Hari ini, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    final entry = JournalEntry(
      id: 'jrn_${now.millisecondsSinceEpoch}',
      userEmail: AppStateService.instance.userProfile.email,
      title: title,
      date: dateStr,
      preview: content,
      mood: mood,
      moodColor: moodColor,
      moodBg: moodBg,
      tags: tags,
    );

    AppStateService.instance.addJournal(entry);

    await DbHelper.instance.insertJournal({
      'id': entry.id,
      'user_email': entry.userEmail,
      'user_name': AppStateService.instance.userProfile.name,
      'title': entry.title,
      'date': entry.date,
      'preview': entry.preview,
      'mood': entry.mood,
      'mood_color': entry.moodColor.toARGB32(),
      'mood_bg': entry.moodBg.toARGB32(),
      'tags': entry.tags.join(','),
      'created_at': now.toIso8601String(),
    });

    notifyListeners();
  }

  // --- [DELETE] Menghapus jurnal berdasarkan ID ---
  Future<void> deleteJournal(String id) async {
    AppStateService.instance.deleteJournal(id);
    await DbHelper.instance.deleteJournal(id);
    notifyListeners();
  }

  /// Set search keyword for filtering journals
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter journals by mood type
  void setMoodFilter(String mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  /// Reset search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedMoodFilter = 'Semua';
    notifyListeners();
  }
}
