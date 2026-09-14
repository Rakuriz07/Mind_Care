import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mindcare/firebase_options.dart';
import 'package:mindcare/services/preference_handler.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/database/app_database.dart';
import 'package:mindcare/views/splash_screen.dart';

/// ============================================================================
/// 🚀 TITIK MASUK UTAMA APLIKASI MINDCARE (ENTRY POINT MAIN.DART)
/// ============================================================================
/// Fungsi [main] adalah titik awal eksekusi seluruh aplikasi Flutter.
/// Di sini dilakukan inisialisasi asinkronus seluruh layanan inti sebelum UI ditampilkan.
void main() async {
  // 1. Memastikan binding Flutter engine sudah siap sebelum memanggil async native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi format tanggal Bahasa Indonesia (id_ID) untuk DateFormat
  await initializeDateFormatting('id_ID', null);

  // 3. Inisialisasi Firebase Core SDK (Auth, Firestore, Messaging, Storage)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Inisialisasi SharedPreferences untuk penyimpanan setelan & preferensi pengguna
  await PreferenceHandler.init();

  // 5. Inisialisasi Database Lokal SQLite HP via AppDatabase
  await AppDatabase.instance.init();

  // 6. Jalankan Root Widget aplikasi
  runApp(const MindCareApp());
}

/// Alias agar mendukung rujukan `MyApp` maupun `MindCareApp`
typedef MyApp = MindCareApp;

/// ============================================================================
/// 🎨 WIDGET UTAMA APLIKASI (MINDCARE APP ROOT WIDGET)
/// ============================================================================
/// Menyusun MaterialApp, tema warna visual (Material 3), Google Fonts Plus Jakarta Sans,
/// serta rute awal aplikasi yang mengarah ke SplashScreen.
class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false, // Menghilangkan pita DEBUG di sudut kanan atas

      // Konfigurasi Tema Aplikasi (ThemeData Material 3)
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surfaceCanvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceCanvas,
        ),

        // Menggunakan Tipografi Google Fonts "Plus Jakarta Sans" untuk kesan modern & bersih
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      // Layar awal yang pertama kali dibuka saat aplikasi diluncurkan
      home: const SplashScreen(),
    );
  }
}

