import 'package:dio/dio.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // API Key Gemini (Opsional: Dapat diisi dengan API Key Gemini resmi)
  String _apiKey = '';

  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  bool get hasCustomKey => _apiKey.isNotEmpty;

  /// System Prompt khusus Asisten Kesehatan Mental & Nutrisi MindCare
  static const String mentalHealthSystemPrompt = '''
Kamu adalah "MindCare AI Mental Health & Wellness Companion", sahabat virtual kesehatan mental dan gizi emosional yang hangat, penuh empati, ramah, dan bebas dari penilaian (non-judgmental).

Aturan Utama Tanggapan:
1. NADA BICARA & EMPATI: Selalu menyapa dengan ramah ("Sahabat MindCare" atau panggilan hangat), validasi emosi pengguna dengan lembut, dan berikan jawaban yang mendukung tanpa kesan menggurui.
2. PANJANG JAWABAN: Berikan jawaban yang padat, jelas, menenangkan, dan praktis (maksimal 3-5 kalimat).
3. PROTOKOL KONTROL KRISIS: Jika pengguna mengekspresikan stres sangat berat, keputusasaan, kecemasan akut, atau ide menyakiti diri, Anda WAJIB memberikan kalimat penguatan dan otomatis menyertakan informasi kontak darurat resmi:
   "Jika kamu membutuhkan teman bicara profesional saat ini, silakan hubungi Layanan Sehat Jiwa Kemenkes RI di Call Center 119 (ext 8)."
4. BAHASA: Gunakan Bahasa Indonesia yang santun, hangat, dan alami.
''';

  /// Mengirim prompt ke Google Gemini API (gemini-1.5-flash)
  Future<String> generateNutritionAdvice({
    required String question,
    String? currentMood,
  }) async {
    final userPrompt = currentMood != null && currentMood.isNotEmpty
        ? 'Kondisi emosi saya saat ini: "$currentMood". Pertanyaan/Keluhan saya: "$question"'
        : 'Pertanyaan/Keluhan kesehatan mental & gizi saya: "$question"';

    if (_apiKey.isNotEmpty) {
      try {
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

        final response = await _dio.post(
          url,
          data: {
            "contents": [
              {
                "parts": [
                  {"text": "$mentalHealthSystemPrompt\n\n[PENGGUNA]: $userPrompt"}
                ]
              }
            ]
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final candidates = response.data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
        }
      } catch (e) {
        // Jika terjadi gangguan API / offline / rate limit, gunakan Smart Fallback Engine
      }
    }

    // Smart Fallback Engine berbasis deteksi krisis & edukasi gizi emosi
    return _generateFallbackAdvice(question, currentMood);
  }

  String _generateFallbackAdvice(String question, String? mood) {
    final qLower = question.toLowerCase();
    final moodLower = (mood ?? '').toLowerCase();

    // 1. Crisis & Extreme Emotional Distress Detection
    if (qLower.contains('bunuh diri') ||
        qLower.contains('menyerah') ||
        qLower.contains('tidak kuat') ||
        qLower.contains('hampa') ||
        qLower.contains('depresi berat') ||
        qLower.contains('putus asa') ||
        qLower.contains('menyakiti diri') ||
        moodLower.contains('stress berat') ||
        moodLower.contains('depresi')) {
      return 'Halo Sahabat, terima kasih sudah berani bercerita. Perasaanmu sangat valid dan kamu tidak sendirian menghadapi ini. Tolong luangkan waktu sejenak untuk bernapas perlahan. Jika beban ini terasa sangat berat, mohon hubungi layanan bantuan profesional Sehat Jiwa Kemenkes RI di Call Center 119 (ext 8) atau konselor terdekat. Kami peduli padamu.';
    }

    // 2. Makanan Pedas / Asam / Lambung / GERD
    if (qLower.contains('pedas') ||
        qLower.contains('cabai') ||
        qLower.contains('sambal') ||
        qLower.contains('seblak') ||
        qLower.contains('maag') ||
        qLower.contains('gerd')) {
      return 'Makanan pedas atau asam dapat mengiritasi dinding lambung. Karena usus terhubung ke otak melalui Saraf Vagus (Gut-Brain Axis), rasa tidak nyaman di lambung memicu sinyal stres yang bisa menyebabkan cemas dan jantung berdebar. Kurangi pedas saat emosi sedang sensitif.';
    }

    // 3. Kafein / Kopi
    if (qLower.contains('kopi') ||
        qLower.contains('kafein') ||
        qLower.contains('espresso')) {
      return 'Kafein merangsang kelenjar adrenal memproduksi hormon stres kortisol dan adrenalin. Jika Anda sedang cemas atau berdebar, kafein dapat memperparah rasa panik. Batasi maksimal 1 cangkir sebelum jam 12 siang atau ganti dengan Teh Chamomile.';
    }

    // 4. Makanan Manis / Gula
    if (qLower.contains('manis') ||
        qLower.contains('gula') ||
        qLower.contains('boba') ||
        qLower.contains('es krim')) {
      return 'Gula merangsang dopamin sesaat (sugar craving), namun memicu lonjakan gula darah yang disusul penurunan drastis (blood sugar crash). Ini menyebabkan perubahan mood mendadak dan memperburuk rasa cemas. Ganti dengan manis alami seperti pisang atau dark chocolate.';
    }

    // 5. Tidur / Insomnia
    if (qLower.contains('tidur') ||
        qLower.contains('insomnia') ||
        qLower.contains('begadang')) {
      return 'Makan makanan berat sebelum tidur membuat usus bekerja keras dan mengganggu fase tidur nyenyak (REM sleep). Pilih cemilan ringan tinggi triptofan seperti oatmeal hangat atau pisang 1 jam sebelum tidur untuk meningkatkan hormon tidur melatonin.';
    }

    // 6. Gorengan / Junk Food
    if (qLower.contains('gorengan') ||
        qLower.contains('mie') ||
        qLower.contains('fast food') ||
        qLower.contains('junk food')) {
      return 'Makanan tinggi lemak jenuh & garam memicu mikro-inflamasi sel saraf dan memperlambat aliran oksigen ke otak, menyebabkan "brain fog" (pikiran lemas/kabur). Imbangi dengan hidrasi air putih dan sayuran hijau.';
    }

    // 7. Sayur / Buah / Nutrisi Sehat
    if (qLower.contains('sayur') ||
        qLower.contains('buah') ||
        qLower.contains('alpukat') ||
        qLower.contains('pisang') ||
        qLower.contains('yogurt')) {
      return 'Buah dan sayuran segar kaya serat prebiotik, magnesium, dan asam folat. Serat ini menjadi makanan bagi bakteri baik usus yang memproduksi 90% hormon serotonin (hormon penentu kebahagiaan) di tubuh Anda.';
    }

    if (mood != null && mood.isNotEmpty) {
      return 'Halo Sahabat, untuk kondisi emosi "$mood", pastikan mengonsumsi makanan kaya probiotik, cairan air putih yang cukup (2 Liter/hari), serta makanan tinggi Omega-3 untuk menjaga keseimbangan serotonin di usus & meredakan stres.';
    }

    return 'Halo Sahabat MindCare! Mengenai "$question", nutrisi harian yang seimbang sangat memengaruhi kestabilan emosi. Usahakan mengonsumsi makanan segar bergizi tinggi, kurangi makanan olahan tinggi gula/garam, serta cukupi hidrasi air putih untuk mendukung produksi hormon bahagia di usus.';
  }
}
