import 'package:flutter/material.dart';
import 'package:mindcare/constants/app_colors.dart';
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

  List<ScreeningRecord> get screeningHistory =>
      AppStateService.instance.screeningHistory;

  int get latestScore => AppStateService.instance.latestScreeningScore;

  /// Answer a question by index and point value
  void answerQuestion(int questionIndex, int scoreValue) {
    _answers[questionIndex] = scoreValue;
    notifyListeners();
  }

  /// Move to next question
  void nextQuestion() {
    _currentQuestionIndex++;
    notifyListeners();
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

  /// Calculate total score normalized to 0 - 100 scale
  int calculateScore(int totalQuestions) {
    if (_answers.isEmpty) return 85;
    final totalRawPoints = _answers.values.fold(0, (sum, val) => sum + val);
    final maxPossible = totalQuestions * 3; // Scale 0-3 per question
    final percentage = (totalRawPoints / maxPossible * 100).round();
    return percentage.clamp(0, 100);
  }

  /// Complete screening session and record result
  Future<ScreeningRecord> completeScreening({
    required int totalQuestions,
  }) async {
    final finalScore = calculateScore(totalQuestions);
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
    } else if (finalScore >= 50) {
      title = 'Stres Ringan';
      color = AppColors.tertiary;
      bg = AppColors.softSunshine;
      imageUrl = 'assets/images/cemas.png';
    } else {
      title = 'Tingkat Stres Tinggi';
      color = AppColors.primary;
      bg = AppColors.softPink;
      imageUrl = 'assets/images/sedih.png';
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

    resetScreening();
    return record;
  }
}
