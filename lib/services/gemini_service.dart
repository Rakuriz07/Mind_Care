import 'package:dio/dio.dart';

/// ============================================================================
/// GEMINI SERVICE (Layanan AI Assistant MindCare & Smart Fallback Engine)
/// ----------------------------------------------------------------------------
/// KEGUNAAN & FUNGSI:
/// Layanan ini mengintegrasikan kecerdasan buatan Google Gemini (gemini-1.5-flash)
/// untuk menjawab pertanyaan kesehatan mental, kecemasan, gizi emosional (Gut-Brain Axis),
/// serta menyediakan 15+ kategori Smart Fallback Engine yang tetap bekerja tanpa internet/API key.
///
/// FITUR UTAMA:
/// 1. HTTP Client Dio dengan timeout responsif (`Dio`).
/// 2. System Prompt khusus dengan batasan klinis & pertolongan krisis (`mentalHealthSystemPrompt`).
/// 3. Integrasi REST API Google Gemini (`generateNutritionAdvice`).
/// 4. Engine Respon Kontekstual Pintar Lapis 15+ Topik (`_generateFallbackAdvice`).
/// ============================================================================
class GeminiService {
  // Singleton Pattern: Memastikan hanya ada 1 instance layanan AI yang dipakai di seluruh app.
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  // Dio HTTP Client untuk melakukan panggilan HTTP REST API ke server Google Gemini
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // API Key Resmi Google Gemini AI untuk MindCare (dapat diisi via environment atau setApiKey)
  String _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Memperbarui API Key Gemini jika pengguna memasukkan custom key sendiri
  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  bool get hasCustomKey => _apiKey.isNotEmpty;

  /// ==========================================================================
  /// SYSTEM PROMPT KHUSUS KESEHATAN MENTAL & NUTRISI EMOSIONAL
  /// --------------------------------------------------------------------------
  /// Kegunaan: Memberikan instruksi peran (role-play), nada emosional empati,
  /// instruksi batas panjang kalimat (3-5 kalimat), serta instruksi krisis darurat.
  /// ==========================================================================
  static const String mentalHealthSystemPrompt = '''
Kamu adalah "MindCare AI Mental Health & Wellness Companion", sahabat virtual kesehatan mental dan gizi emosional yang hangat, penuh empati, ramah, dan bebas dari penilaian (non-judgmental).

Aturan Utama Tanggapan:
1. NADA BICARA & EMPATI: Selalu menyapa dengan ramah ("Sahabat MindCare" atau panggilan hangat), validasi emosi pengguna dengan lembut, dan berikan jawaban yang relevan serta mendukung secara presisi sesuai dengan pertanyaan yang diajukan.
2. PANJANG JAWABAN: Berikan jawaban yang padat, jelas, menenangkan, dan praktis (maksimal 3-5 kalimat).
3. PROTOKOL KONTROL KRISIS: Jika pengguna mengekspresikan stres sangat berat, keputusasaan, kecemasan akut, atau ide menyakiti diri, Anda WAJIB memberikan kalimat penguatan dan otomatis menyertakan informasi kontak darurat resmi:
   "Jika kamu membutuhkan teman bicara profesional saat ini, silakan hubungi Layanan Sehat Jiwa Kemenkes RI di Call Center 119 (ext 8)."
4. BAHASA: Gunakan Bahasa Indonesia yang santun, hangat, dan alami.
''';

  /// ==========================================================================
  /// MENGIRIM PERTANYAAN KE GEMINI API / FALLBACK ENGINE
  /// --------------------------------------------------------------------------
  /// Kegunaan: Mengirim prompt pertanyaan pengguna & mood emosional aktif ke API Gemini.
  /// Jika API key kosong atau sinyal internet terputus, otomatis mengalihkan ke Smart Engine.
  /// ==========================================================================
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
      } catch (_) {
        // Jika ada kendala jaringan atau batas kuota API, lanjut ke Smart Fallback Engine
      }
    }

    // Smart Fallback Engine berbasis 15+ analisis kata kunci & psikologi klinis
    return _generateFallbackAdvice(question, currentMood);
  }

  /// ==========================================================================
  /// SMART FALLBACK ENGINE (DETEKSI TOPIK & TANGGAPAN PRESISI)
  /// --------------------------------------------------------------------------
  /// Kegunaan: Menganalisis kata kunci dalam pertanyaan pengguna dan memberikan
  /// saran penyembuhan & nutrisi emosional secara instan tanpa membutuhkan koneksi internet.
  /// ==========================================================================
  String _generateFallbackAdvice(String question, String? mood) {
    final qLower = question.toLowerCase().trim();
    final moodLower = (mood ?? '').toLowerCase().trim();

    // Topik 1: Krisis & Stres Berat
    if (qLower.contains('bunuh diri') ||
        qLower.contains('menyerah') ||
        qLower.contains('tidak kuat') ||
        qLower.contains('hampa') ||
        qLower.contains('depresi berat') ||
        qLower.contains('putus asa') ||
        qLower.contains('menyakiti diri') ||
        moodLower.contains('stress berat') ||
        moodLower.contains('depresi')) {
      return 'Halo Sahabat, terima kasih sudah berani bercerita. Perasaanmu sangat valid dan kamu tidak sendirian menghadapi ini. Tolong luangkan waktu sejenak untuk bernapas perlahan. Jika beban ini terasa sangat berat, mohon hubungi layanan bantuan profesional Sehat Jiwa Kemenkes RI di Call Center 119 (ext 8) atau konselor terdekat. Kami sangat peduli padamu. ✨';
    }

    // Topik 2: Salam / Sapaan Awal
    if (qLower == 'halo' ||
        qLower == 'hai' ||
        qLower.startsWith('halo') ||
        qLower.startsWith('hai') ||
        qLower.contains('selamat pagi') ||
        qLower.contains('selamat siang') ||
        qLower.contains('selamat sore') ||
        qLower.contains('selamat malam') ||
        qLower.contains('siapa kamu') ||
        qLower.contains('apa kabar')) {
      return 'Halo Sahabat MindCare! 👋 Saya adalah asisten virtual kesehatan mental dan gizi emosional Anda. Saya siap mendengarkan cerita, memberikan tips meredakan cemas, hingga rekomendasi nutrisi sehat untuk emosi Anda. Ada yang bisa saya bantu hari ini? ✨';
    }

    // Topik 3: Ucapan Terima Kasih
    if (qLower.contains('terima kasih') ||
        qLower.contains('makasih') ||
        qLower.contains('thanks') ||
        qLower.contains('ok makasih')) {
      return 'Sama-sama Sahabat MindCare! 🌸 Selalu ingat untuk menjaga kesehatan fisik dan pikiranmu. Jika butuh teman cerita lagi, saya selalu ada di sini untuk mendengarkan.';
    }

    // Topik 4: Kecemasan, Panik & Overthinking
    if (qLower.contains('cemas') ||
        qLower.contains('panik') ||
        qLower.contains('gelisah') ||
        qLower.contains('overthinking') ||
        qLower.contains('takut') ||
        qLower.contains('was-was') ||
        qLower.contains('presentasi') ||
        qLower.contains('gugup')) {
      return 'Rasa cemas dan gugup sering kali dipicu oleh respons pikiran terhadap ketidakpastian. Cobalah tarik napas dalam-dalam selama 4 detik, tahan 4 detik, lalu hembuskan perlahan selama 6 detik. Ingatkan diri Anda bahwa Anda aman saat ini dan perasaan cemas ini akan segera berlalu.';
    }

    // Topik 5: Kesedihan, Kecewa & Menangis
    if (qLower.contains('sedih') ||
        qLower.contains('kecewa') ||
        qLower.contains('menangis') ||
        qLower.contains('patah hati') ||
        qLower.contains('dikhianati') ||
        qLower.contains('terluka')) {
      return 'Perasaan sedih dan kecewa adalah respons emosional yang sangat valid. Jangan menahannya—izinkan diri Anda merasakan emosi tersebut secara alami tanpa menyalahkan diri sendiri. Istirahatlah sejenak, minum air hangat, dan luapkan perasaan Anda di fitur Tulis Jurnal MindCare.';
    }

    // Topik 6: Stres Kerja, Kuliah & Penat / Lelah
    if (qLower.contains('stres') ||
        qLower.contains('stress') ||
        qLower.contains('kerja') ||
        qLower.contains('tugas') ||
        qLower.contains('kuliah') ||
        qLower.contains('lelah') ||
        qLower.contains('capek') ||
        qLower.contains('pusing') ||
        qLower.contains('penat')) {
      return 'Rasa lelah dan penat adalah sinyal bahwa pikiran Anda membutuhkan jeda sejenak (*break*). Cobalah beristirahat 5-10 menit jauh dari layar, lakukan peregangan otot ringan, atau coba Game Relaksasi di MindCare untuk menyegarkan kembali energi Anda.';
    }

    // Topik 7: Tidur, Insomnia & Begadang
    if (qLower.contains('tidur') ||
        qLower.contains('insomnia') ||
        qLower.contains('begadang') ||
        qLower.contains('susah tidur')) {
      return 'Kualitas tidur yang baik sangat penting untuk kestabilan emosi. Jauhkan gadget 30 menit sebelum tidur, redupkan lampu kamar, dan coba dengarkan alunan musik alam penyegar suasana di MindCare untuk membantu Anda tertidur lebih lelap.';
    }

    // Topik 8: Makanan Pedas & GERD / Maag (Gut-Brain Axis)
    if (qLower.contains('pedas') ||
        qLower.contains('sambal') ||
        qLower.contains('seblak') ||
        qLower.contains('maag') ||
        qLower.contains('gerd')) {
      return 'Makanan pedas atau asam dapat mengiritasi dinding lambung. Karena usus terhubung ke otak via Saraf Vagus (Gut-Brain Axis), rasa tidak nyaman di lambung memicu sinyal stres yang bisa menyebabkan cemas dan jantung berdebar. Kurangi pedas saat emosi sedang sensitif.';
    }

    // Topik 9: Kafein / Kopi
    if (qLower.contains('kopi') ||
        qLower.contains('kafein') ||
        qLower.contains('espresso')) {
      return 'Kafein merangsang kelenjar adrenal memproduksi hormon stres kortisol dan adrenalin. Jika Anda sedang cemas atau berdebar, kafein dapat memperparah rasa panik. Batasi maksimal 1 cangkir sebelum jam 12 siang atau ganti dengan Teh Chamomile.';
    }

    // Topik 10: Makanan Manis / Gula
    if (qLower.contains('manis') ||
        qLower.contains('gula') ||
        qLower.contains('boba') ||
        qLower.contains('es krim')) {
      return 'Gula merangsang dopamin sesaat, namun memicu lonjakan gula darah yang disusul penurunan drastis (*blood sugar crash*). Ini menyebabkan mood swing dan memperburuk cemas. Ganti dengan manis alami seperti pisang atau dark chocolate.';
    }

    // Topik 11: Topik Jurnal
    if (qLower.contains('jurnal') || qLower.contains('menulis')) {
      return 'Untuk menulis jurnal hari ini, Anda bisa memulainya dengan mencatat 3 hal kecil yang Anda syukuri hari ini, atau mendeskripsikan emosi terbesar yang Anda rasakan sejak pagi. Fitur Tulis Jurnal di MindCare siap membantu menyimpan catatan emosi Anda dengan aman.';
    }

    // Topik 12: Mood Khusus dari Parameter
    if (mood != null && mood.isNotEmpty) {
      return 'Halo Sahabat, mengenai "$question" dalam kondisi emosi "$mood": Pastikan mengonsumsi air putih yang cukup (2 Liter/hari), makanan segar tinggi serat prebiotik, serta luangkan waktu untuk meditasi atau relaksasi otot.';
    }

    // Topik 13: Respon Kontekstual Dinamis Umum
    return 'Mengenai "$question": Terima kasih telah berbagi dengan MindCare AI! Pertanyaan dan perasaan Anda sangat penting. Ketika menghadapi hal ini, luangkan waktu sejenak untuk bernapas tenang, penuhi hidrasi tubuh, serta manfaatkan fitur Skrining Kesehatan Mental & Jurnal di MindCare untuk memantau perkembangan emosional Anda secara berkala. ✨';
  }
}
