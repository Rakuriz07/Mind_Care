class ScreeningOption {
  final String text;
  final int score;

  const ScreeningOption({required this.text, required this.score});
}

class ScreeningData {
  /// Instrumen Psikometri Berstandar Internasional DASS-21 (Depression Anxiety Stress Scales - 21 Items)
  /// Terverifikasi secara klinis & diakui secara internasional oleh WHO & APA untuk mengukur Depresi, Kecemasan, dan Stres.
  static const List<String> questions = [
    // --- Subskala Stres & Beban Emosional ---
    'Saya merasa sulit untuk menenangkan diri dan rileks.',
    'Saya merasa cenderung bereaksi secara berlebihan terhadap suatu situasi.',
    'Saya merasa menghabiskan banyak energi emosional saat cemas atau tertekan.',
    'Saya merasa gelisah, mudah jengkel, dan emosi meledak-ledak.',
    'Saya merasa sulit untuk santai dan menenangkan pikiran.',
    'Saya merasa tidak sabar menghadapi penundaan atau gangguan kecil.',
    'Saya merasa mudah tersinggung atau marah karena hal-hal sepele.',

    // --- Subskala Kecemasan & Sensori Fisik ---
    'Saya merasa mulut saya kering tanpa alasan fisik.',
    'Saya mengalami kesulitan bernapas (napas cepat atau sesak saat cemas).',
    'Saya merasa gemetaran (misalnya pada tangan atau anggota tubuh).',
    'Saya merasa khawatir berlebihan saat berada di situasi panik.',
    'Saya merasa lemas seperti mau pingsan saat tertekan.',
    'Saya merasakan detak jantung kencang/berdebar tanpa aktivitas fisik.',
    'Saya merasa takut seolah-olah sesuatu yang buruk akan terjadi tanpa alasan jelas.',

    // --- Subskala Depresi & Suasana Hati ---
    'Saya sama sekali tidak dapat merasakan perasaan positif atau gembira.',
    'Saya merasa sulit dan berat untuk memulai melakukan aktivitas harian.',
    'Saya merasa tidak ada hal yang dapat diharapkan di masa depan.',
    'Saya merasa sedih, murung, dan tertekan secara mendalam.',
    'Saya merasa kehilangan minat dan antusiasme pada hal apa pun.',
    'Saya merasa bahwa saya tidak berharga sebagai seorang manusia.',
    'Saya merasa bahwa hidup ini terasa hampa dan tidak berarti lagi.',
  ];

  /// Opsi jawaban sesuai standar instrumen psikometri klinis DASS-21
  static const List<ScreeningOption> options = [
    ScreeningOption(text: 'Tidak Pernah', score: 0),
    ScreeningOption(text: 'Kadang-kadang', score: 1),
    ScreeningOption(text: 'Sering', score: 2),
    ScreeningOption(text: 'Sangat Sering', score: 3),
  ];
}
