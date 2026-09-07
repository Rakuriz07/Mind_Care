 class ScreeningOption {
  final String text;
  final int score;

  const ScreeningOption({
    required this.text,
    required this.score,
  });
}

class ScreeningData {
  /// Pertanyaan psikometrik terverifikasi klinis berstandar internasional:
  /// - PHQ-9 (Patient Health Questionnaire-9): Indikator Depresi & Mood (No. 1-9)
  /// - GAD-7 (Generalized Anxiety Disorder-7): Indikator Kecemasan (No. 10-16)
  /// - DASS-21 Stress Subscale: Indikator Stres & Beban Emosional (No. 17-20)
  static const List<String> questions = [
    // --- PHQ-9 (Depresi & Suasana Hati) ---
    'Kurang berminat atau tidak merasa senang saat melakukan aktivitas harian.',
    'Merasa murung, sedih, tertekan, atau putus asa.',
    'Sulit tidur, sering terbangun di malam hari, atau malah terlalu banyak tidur.',
    'Merasa lelah, lemas, atau kurang bertenaga sepanjang hari.',
    'Kurang nafsu makan atau justru makan secara berlebihan.',
    'Merasa buruk tentang diri sendiri, merasa gagal, atau mengecewakan diri dan keluarga.',
    'Sulit berkonsentrasi pada hal-hal seperti membaca, belajar, atau bekerja.',
    'Bergerak atau berbicara sangat lambat, atau sebaliknya — terlalu gelisah hingga tak bisa tenang.',
    'Merasa kewalahan hingga muncul pikiran bahwa Anda lebih baik tidak ada atau ingin menyakiti diri.',

    // --- GAD-7 (Kecemasan & Kegelisahan) ---
    'Merasa gugup, cemas, khawatir, atau sangat gelisah.',
    'Merasa tidak mampu menghentikan atau mengendalikan rasa khawatir.',
    'Merasa sangat khawatir tentang berbagai macam hal secara berlebihan.',
    'Merasa sulit untuk santai, rileks, atau menenangkan pikiran.',
    'Sangat gelisah hingga merasa sulit untuk duduk tenang.',
    'Merasa mudah jengkel, marah, atau tersinggung pada hal-hal kecil.',
    'Merasa takut seolah-olah sesuatu yang buruk atau berbahaya akan terjadi.',

    // --- DASS-21 (Tingkat Stres & Beban Emosional) ---
    'Merasa emosi mudah meledak atau menghabiskan banyak energi emosional saat tertekan.',
    'Merasa kewalahan menghadapi beban pikiran dan tuntutan aktivitas sehari-hari.',
    'Merasa sulit untuk tenang kembali setelah mengalami peristiwa yang menyebalkan.',
    'Merasa enggan untuk berinteraksi sosial atau menarik diri dari lingkungan sekitar.',
  ];

  /// Opsi jawaban sesuai standar instrumen klinis PHQ-9 & GAD-7
  static const List<ScreeningOption> options = [
    ScreeningOption(text: 'Tidak pernah sama sekali', score: 0),
    ScreeningOption(text: 'Beberapa hari', score: 1),
    ScreeningOption(text: 'Lebih dari separuh hari', score: 2),
    ScreeningOption(text: 'Hampir setiap hari', score: 3),
  ];
}
