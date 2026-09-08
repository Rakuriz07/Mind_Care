import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mindcare/firebase_options.dart';
import 'package:mindcare/services/preference_handler.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/database/app_database.dart';
import 'package:mindcare/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi lokalisasi tanggal untuk format Indonesia (id_ID) agar DateFormat dapat menggunakan format lokal
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi SharedPreferences (Day 17) agar siap digunakan di seluruh aplikasi.
  await PreferenceHandler.init();

  // Inisialisasi Database Aplikasi (SQLite)
  await AppDatabase.instance.init();

  runApp(const MindCareApp());
}

// Alias agar mendukung rujukan MyApp maupun MindCareApp
typedef MyApp = MindCareApp;

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surfaceCanvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceCanvas,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
