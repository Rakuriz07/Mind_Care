class ProfanityFilter {
  // Daftar kata-kata kasar / kasar umum (Bahasa Indonesia & Inggris)
  static const List<String> _profaneWords = [
    'anjing',
    'anjir',
    'anjrit',
    'babi',
    'bangsat',
    'kontol',
    'kintol',
    'memek',
    'pepek',
    'pantek',
    'puki',
    'pukimak',
    'itil',
    'bajingan',
    'jancok',
    'jancuk',
    'goblok',
    'tolol',
    'bego',
    'lonte',
    'perek',
    'peler',
    'fuck',
    'bitch',
    'bastard',
    'shit',
    'asshole',
    'cunt',
    'slut',
    'dick',
    'pussy',
  ];

  /// Memeriksa apakah teks mengandung kata kasar
  static bool containsProfanity(String text) {
    if (text.trim().isEmpty) return false;

    // Normalisasi teks: huruf kecil dan ubah substitusi karakter umum (cth: @ -> a, 0 -> o, 1 -> i, $ -> s)
    final normalized = text
        .toLowerCase()
        .replaceAll('@', 'a')
        .replaceAll('\$', 's')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('!', 'i');

    for (final badWord in _profaneWords) {
      final cleanBad = badWord.toLowerCase().trim();
      if (cleanBad.isNotEmpty && normalized.contains(cleanBad)) {
        return true;
      }
    }
    return false;
  }

  /// Mengubah kata kasar dalam teks menjadi tanda bintang (***)
  static String censorText(String text) {
    if (text.trim().isEmpty) return text;

    String result = text;
    for (final word in _profaneWords) {
      final cleanWord = word.trim();
      if (cleanWord.isEmpty) continue;
      final pattern = RegExp(RegExp.escape(cleanWord), caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) {
        final matchedStr = match.group(0) ?? '';
        return '*' * matchedStr.length;
      });
    }

    return result;
  }
}
