import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/constants/screening_data.dart';
import 'package:mindcare/database/db_helper.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';

class ScreeningController extends ChangeNotifier {
  static final ScreeningController _instance = ScreeningController._internal();
  static ScreeningController get instance => _instance;

  ScreeningController._internal();

  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {};

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

  // --- [READ] Membaca riwayat skrining user ---
  List<ScreeningRecord> get screeningHistory =>
      AppStateService.instance.screeningHistory;

  // --- [READ] Membaca skor skrining terbaru ---
  int get latestScore => AppStateService.instance.latestScreeningScore;

  /// Select an option for current question
  void selectOption(int optionIndex) {
    _answers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }

  /// Move to next question if current is answered
  bool nextQuestion() {
    if (!isCurrentQuestionAnswered) {
      return false;
    }
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      return true;
    }
    return true;
  }

  /// Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Reset current screening questionnaire state
  void resetScreening() {
    _currentQuestionIndex = 0;
    _answers.clear();
    notifyListeners();
  }

  /// Calculate total score normalized to wellness scale (25 - 95)
  int calculateScore() {
    if (_answers.isEmpty) return 85;
    final totalRawPoints = _answers.entries.fold(0, (sum, entry) {
      final optionIdx = entry.value;
      final scoreVal = optionIdx >= 0 && optionIdx < options.length
          ? options[optionIdx].score
          : 0;
      return sum + scoreVal;
    });

    final maxPossible = totalQuestions * 3; // Scale 0-3 per question
    final wellnessScore = (100 - ((totalRawPoints / maxPossible) * 75))
        .round()
        .clamp(25, 95);
    return wellnessScore;
  }

  // --- [CREATE] Menyelesaikan skrining dan menyimpan hasilnya ---
  Future<ScreeningRecord> completeScreening() async {
    final finalScore = calculateScore();
    final now = DateTime.now();
    final dateStr =
        'Hari ini, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    String title;
    Color color;
    Color bg;
    String imageUrl;

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
    );

    AppStateService.instance.addScreeningRecord(record);

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
