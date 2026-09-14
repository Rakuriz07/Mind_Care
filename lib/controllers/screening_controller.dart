import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/constants/screening_data.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

/// ============================================================================
/// SCREENING CONTROLLER (Pengontrol Alur Kuesioner Skrining DASS-21)
/// ----------------------------------------------------------------------------
/// KEGUNAAN & FUNGSI:
/// Controller ini mengelola State & Logika Kuesioner Skrining Kesehatan Mental:
/// 1. Mengacak / Menyajikan 21 Pertanyaan Emas DASS-21 secara bertahap.
/// 2. Mengingat Jawaban yang dipilih pengguna untuk tiap pertanyaan (`_answers`).
/// 3. Menghitung Skor Kebugaran Mental (Wellness Score) Skala 25 - 95.
/// 4. Mengelompokkan Kategori Klinis (Sangat Baik, Kecemasan Ringan, Sedang Lelah, Stres Tinggi).
/// 5. Menyimpan Hasil Lengkap (termasuk rincian pertanyaan & jawaban) ke SQLite & Cloud Firestore.
/// ============================================================================
class ScreeningController extends ChangeNotifier {
  // Singleton Pattern: Memastikan state pengisian kuesioner konsisten di seluruh aplikasi.
  static final ScreeningController _instance = ScreeningController._internal();
  static ScreeningController get instance => _instance;

  ScreeningController._internal();

  // Indeks pertanyaan yang sedang ditampilkan saat ini (dimulai dari 0)
  int _currentQuestionIndex = 0;
  
  // Map untuk menyimpan pasangan: (Indeks Pertanyaan -> Indeks Opsi Jawaban)
  final Map<int, int> _answers = {};

  // GETTER STATE KUESIONER
  int get currentQuestionIndex => _currentQuestionIndex;
  int get answeredCount => _answers.length;
  List<String> get questions => ScreeningData.questions;
  List<ScreeningOption> get options => ScreeningData.options;
  int get totalQuestions => questions.length;

  String get currentQuestion => questions[_currentQuestionIndex];
  double get progress => (_currentQuestionIndex + 1) / totalQuestions;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;
  bool get isCurrentQuestionAnswered =>
      _answers.containsKey(_currentQuestionIndex);
  int? get currentSelectedOptionIndex => _answers[_currentQuestionIndex];

  // --- [READ] Membaca riwayat skrining pengguna dari AppStateService ---
  List<ScreeningRecord> get screeningHistory =>
      AppStateService.instance.screeningHistory;

  // --- [READ] Membaca skor skrining paling baru ---
  int get latestScore => AppStateService.instance.latestScreeningScore;

  /// ==========================================================================
  /// 1. MEMILIH OPSI JAWABAN (SELECT OPTION)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menyimpan jawaban pilihan pengguna pada pertanyaan aktif saat ini.
  /// ==========================================================================
  void selectOption(int optionIndex) {
    _answers[_currentQuestionIndex] = optionIndex;
    notifyListeners(); // Memperbarui tampilan UI kuesioner secara langsung
  }

  /// ==========================================================================
  /// 2. PINDAH KE PERTANYAAN BENDA BERIKUTNYA (NEXT QUESTION)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Berpindah ke pertanyaan nomor berikutnya jika pertanyaan saat ini sudah dijawab.
  /// ==========================================================================
  bool nextQuestion() {
    if (!isCurrentQuestionAnswered) {
      return false; // Jangan izinkan lanjut jika belum dijawab
    }
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      return true;
    }
    return true;
  }

  /// ==========================================================================
  /// 3. KEMBALI KE PERTANYAAN SEBELUMNYA (PREVIOUS QUESTION)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Memungkinkan pengguna meninjau atau mengubah jawaban pertanyaan sebelumnya.
  /// ==========================================================================
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// ==========================================================================
  /// 4. RESET STATE SKRINING (RESET)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Membersihkan seluruh jawaban dan mengembalikan indeks ke awal saat memulai ulang.
  /// ==========================================================================
  void resetScreening() {
    _currentQuestionIndex = 0;
    _answers.clear();
    notifyListeners();
  }

  /// ==========================================================================
  /// 5. MENGHITUNG SKOR KELUARAN SKRINING (CALCULATE WELLNESS SCORE)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menghitung total bobot nilai DASS-21 dan mengkonversinya ke dalam
  /// skala persentase kebugaran mental (25 - 95).
  /// ==========================================================================
  int calculateScore() {
    if (_answers.isEmpty) return 85;
    final totalRawPoints = _answers.entries.fold(0, (sum, entry) {
      final optionIdx = entry.value;
      final scoreVal = optionIdx >= 0 && optionIdx < options.length
          ? options[optionIdx].score
          : 0;
      return sum + scoreVal;
    });

    final maxPossible = totalQuestions * 3; // Skala nilai 0-3 per soal DASS-21
    final wellnessScore = (100 - ((totalRawPoints / maxPossible) * 75))
        .round()
        .clamp(25, 95);
    return wellnessScore;
  }

  /// ==========================================================================
  /// 6. MENYELESAIKAN SKRINING & MENYIMPAN HASIL LENGKAP
  /// --------------------------------------------------------------------------
  /// Kegunaan: Mengelompokkan status tingkat kesehatan emosional, menyusun array jawaban,
  /// serta mengirimnya ke AppStateService (SQLite & Cloud Firestore).
  /// ==========================================================================
  Future<ScreeningRecord> completeScreening() async {
    final finalScore = calculateScore();
    final now = DateTime.now();
    final dateStr =
        'Hari ini, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    String title;
    Color color;
    Color bg;
    String imageUrl;

    // Klasifikasi Tingkat Kesehatan Mental berdasarkan Wellness Score
    if (finalScore >= 75) {
      title = 'Sangat Baik';
      color = AppColors.secondary;
      bg = AppColors.secondaryContainer;
      imageUrl = 'assets/images/senang.png';
    } else if (finalScore >= 55) {
      title = 'Kecemasan Ringan';
      color = AppColors.tertiary;
      bg = AppColors.softSunshine;
      imageUrl = 'assets/images/cemas.png';
    } else if (finalScore >= 35) {
      title = 'Sedang Lelah & Sedih';
      color = AppColors.primary;
      bg = AppColors.softPink;
      imageUrl = 'assets/images/sedih.png';
    } else {
      title = 'Tingkat Stres Tinggi';
      color = AppColors.error;
      bg = AppColors.errorContainer;
      imageUrl = 'assets/images/STRESS.png';
    }

    // Menyusun rincian pertanyaan & opsi jawaban yang dipilih pengguna
    final List<Map<String, dynamic>> answersList = [];
    for (int i = 0; i < questions.length; i++) {
      final selectedOptionIndex = _answers[i];
      if (selectedOptionIndex != null && selectedOptionIndex < options.length) {
        final option = options[selectedOptionIndex];
        answersList.add({
          'question_number': i + 1,
          'question_text': questions[i],
          'selected_option': option.text,
          'option_score': option.score,
        });
      }
    }

    // Membuat objek model ScreeningRecord baru
    final record = ScreeningRecord(
      id: 'scr_${now.millisecondsSinceEpoch}',
      userEmail: AppStateService.instance.userProfile.email,
      userName: AppStateService.instance.userProfile.name,
      title: title,
      date: dateStr,
      score: finalScore,
      color: color,
      bg: bg,
      image: imageUrl,
      answers: answersList,
    );

    // Simpan ke State Utama (otomatis sync ke SQLite & Firestore Cloud)
    AppStateService.instance.addScreeningRecord(record);

    // Simpan tambahan ke database lokal SQLite
    await DbHelper.instance.insertScreening({
      'id': record.id,
      'user_email': record.userEmail,
      'user_name': record.userName,
      'title': record.title,
      'date': record.date,
      'score': record.score,
      'color': record.color.toARGB32(),
      'bg': record.bg.toARGB32(),
      'image': record.image,
      'created_at': now.toIso8601String(),
    });

    return record;
  }
}
