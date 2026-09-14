import 'package:flutter/material.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

/// ============================================================================
/// 📜 CONTROLLER JURNAL HARIAN (JOURNAL CONTROLLER)
/// ============================================================================
/// Class ini bertanggung jawab mengelola logika bisnis pencatatan jurnal emosi pengguna,
/// meliputi pencarian jurnal (search), penyaringan suasana hati (filter mood),
/// penambahan catatan jurnal baru (Create), serta penghapusan catatan (Delete).
///
/// Class ini mewarisi [ChangeNotifier] agar tampilan UI Flutter otomatis diperbarui
/// ketika data jurnal berubah atau difilter.
class JournalController extends ChangeNotifier {
  // Pattern Singleton: Menjamin hanya ada 1 instance JournalController di seluruh aplikasi
  static final JournalController _instance = JournalController._internal();
  static JournalController get instance => _instance;

  JournalController._internal();

  /// Kata kunci pencarian judul atau isi jurnal yang sedang diketik pengguna
  String _searchQuery = '';

  /// Filter mood emosi yang sedang dipilih ('Semua', 'Senang', 'Cemas', 'Sedih', dll.)
  String _selectedMoodFilter = 'Semua';

  /// Getter untuk membaca kata kunci pencarian saat ini
  String get searchQuery => _searchQuery;

  /// Getter untuk membaca filter mood emosi saat ini
  String get selectedMoodFilter => _selectedMoodFilter;

  /// --------------------------------------------------------------------------
  /// 🔍 1. MEMBACA LIST JURNAL YANG DIFILTER ([READ])
  /// --------------------------------------------------------------------------
  /// Mengambil seluruh data jurnal dari [AppStateService] lalu menyaringnya
  /// berdasarkan kata kunci pencarian dan filter mood yang sedang aktif.
  List<JournalEntry> get journals {
    final allJournals = AppStateService.instance.journals;
    return allJournals.where((j) {
      // 1. Cek apakah judul atau pratinjau jurnal cocok dengan kata kunci pencarian
      final matchesSearch =
          _searchQuery.isEmpty ||
          j.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.preview.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Cek apakah kategori mood emosi cocok dengan filter yang dipilih
      final matchesMood =
          _selectedMoodFilter == 'Semua' ||
          j.mood.toLowerCase() == _selectedMoodFilter.toLowerCase();

      return matchesSearch && matchesMood;
    }).toList();
  }

  /// --------------------------------------------------------------------------
  /// ➕ 2. MENAMBAHKAN JURNAL EMOSI BARU ([CREATE])
  /// --------------------------------------------------------------------------
  /// Fungsi ini digunakan saat pengguna menekan tombol "Simpan Jurnal":
  /// 1. Format tanggal otomatis dalam Bahasa Indonesia.
  /// 2. Membuat objek [JournalEntry] baru dengan ID berbasis timestamp.
  /// 3. Memasukkan jurnal ke [AppStateService] (otomatis tersinkronisasi ke Firebase Cloud).
  /// 4. Menyimpan catatan ke database lokal SQLite via [DbHelper].
  /// 5. Memanggil [notifyListeners] untuk me-refresh layar UI.
  Future<void> addJournal({
    required String title,
    required String content,
    required String mood,
    required Color moodColor,
    required Color moodBg,
    required List<String> tags,
  }) async {
    final now = DateTime.now();
    final dateStr = _formatJournalDate(now);

    // Menyusun objek JournalEntry
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

    // Simpan ke state global (sync ke cloud)
    AppStateService.instance.addJournal(entry);

    // Simpan ke database lokal SQLite HP
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

    // Mengabarkan UI agar memperbarui daftar jurnal
    notifyListeners();
  }

  /// --------------------------------------------------------------------------
  /// 🗑️ 3. MENGHAPUS JURNAL BERDASARKAN ID ([DELETE])
  /// --------------------------------------------------------------------------
  /// Menghapus catatan jurnal tertentu dari State Management dan database SQLite.
  Future<void> deleteJournal(String id) async {
    AppStateService.instance.deleteJournal(id);
    await DbHelper.instance.deleteJournal(id);
    notifyListeners();
  }

  /// --------------------------------------------------------------------------
  /// ⚙️ 4. SETTER & KONTROL FILTER (SEARCH & MOOD FILTER)
  /// --------------------------------------------------------------------------
  /// Mengatur kata kunci pencarian baru dan memberi tahu UI
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Mengatur filter kategori mood baru dan memberi tahu UI
  void setMoodFilter(String mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  /// Mengosongkan seluruh filter pencarian dan mereset ke kondisi 'Semua'
  void clearFilters() {
    _searchQuery = '';
    _selectedMoodFilter = 'Semua';
    notifyListeners();
  }

  /// Helper internal untuk memformat objek DateTime menjadi string bahasa Indonesia
  /// Contoh output: "Senin, 13 September 2026 • 22:00 WIB"
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
}

