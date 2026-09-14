import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/models/app_models.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/services/pdf_report_service.dart';
import 'package:mindcare/views/detail_hasil_screening_screen.dart';

/// ============================================================================
/// 📈 LAYAR RIWAYAT SKRINING & TREN KESEHATAN MENTAL ([HistoryScreen])
/// ============================================================================
/// Layar ini berfungsi sebagai pusat pemantauan perkembangan kesehatan emosional pengguna:
/// 1. Tampilan Grafik Tren Kesehatan Mental (`CustomPainter` dinamis berbasis waktu & skor).
/// 2. Analisis & Insight Perkembangan Emosional (Perbandingan skor tes pertama & terbaru).
/// 3. Daftar Riwayat Lengkap Evaluasi DASS-21 (Lihat Detail & Hapus Catatan).
/// 4. Ekspor Laporan Resmi Kesehatan Mental dalam Format Dokumen PDF (`PdfReportService`).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// Filter rentang waktu yang sedang dipilih ('Semua Riwayat', '30 Hari', '7 Hari', '3 Bulan')
  String _selectedFilter = 'Semua Riwayat';

  /// Status apakah dokumen laporan PDF sedang dalam proses pembuatan
  bool _isGeneratingPdf = false;

  /// --------------------------------------------------------------------------
  /// 📄 FUNGSI EKSPOR LAPORAN KESEHATAN MENTAL DOKUMEN PDF (_exportPdfReport)
  /// --------------------------------------------------------------------------
  /// Mengompilasi profil pengguna dan seluruh riwayat skrining DASS-21 dari database
  /// menjadi dokumen PDF resmi berstandar medis, lalu membuka cetak/preview bawaan HP.
  Future<void> _exportPdfReport() async {
    final user = AppStateService.instance.userProfile;
    final screeningHistory = AppStateService.instance.screeningHistory;

    // Validasi: Jika belum ada data skrining, tampilkan peringatan
    if (screeningHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada data riwayat skrining untuk dicetak. Lakukan skrining terlebih dahulu.',
          ),
          backgroundColor: AppColors.tertiary,
        ),
      );
      return;
    }

    setState(() => _isGeneratingPdf = true);

    try {
      // 1. Generate byte dokumen PDF via PdfReportService
      final pdfBytes = await PdfReportService.generateScreeningReport(
        user: user,
        records: screeningHistory,
      );

      // 2. Format nama file PDF yang rapi (mengabaikan karakter khusus)
      final cleanName = user.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final pdfName = 'MindCare_Laporan_${cleanName.isEmpty ? "User" : cleanName}.pdf';

      // 3. Buka dialog pratinjau cetak PDF bawaan perangkat (iOS / Android / Desktop)
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: pdfName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat dokumen PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  /// --------------------------------------------------------------------------
  /// 🗑️ DIALOG KONFIRMASI HAPUS RIWAYAT SKRINING (_deleteHistory)
  /// --------------------------------------------------------------------------
  /// Menampilkan modal dialog konfirmasi sebelum menghapus riwayat skrining dari SQLite & Firestore.
  /// Menutup dialog modal terlebih dahulu sebelum meng-update state agar navigasi UI tetap aman.
  void _deleteHistory(ScreeningRecord record) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Riwayat?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data riwayat skrining ini? Grafik tren akan disesuaikan secara otomatis.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Pop dialog konfirmasi terlebih dahulu agar tidak menepis route utama
                Navigator.pop(dialogContext);

                // 2. Hapus data dari state & database lokal/cloud
                await AppStateService.instance.deleteScreeningRecordById(
                  record.id,
                );

                // 3. Tampilkan pesan SnackBar pemberitahuan sukses
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Riwayat skrining dan grafik berhasil diperbarui.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  /// Helper internal untuk memotong format tanggal teks di bawah grafik agar tidak meluap
  String _formatShortDate(String rawDate) {
    if (rawDate.toLowerCase().contains('hari ini')) return 'Hari Ini';
    if (rawDate.toLowerCase().contains('kemarin')) return 'Kemarin';
    final parts = rawDate.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return rawDate;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final screeningHistory = AppStateService.instance.screeningHistory;
        final user = AppStateService.instance.userProfile;

        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Bar Header dengan Tombol Cetak PDF
                _buildAppBar(),

                // 2. Scrollable Body Tampilan Riwayat & Grafik
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Pengguna Aktif
                        _buildHeaderText(user),
                        const SizedBox(height: 16),

                        // Chip Filter Rentang Waktu
                        _buildFilterChips(),
                        const SizedBox(height: 20),

                        // Card Grafik Tren Kesehatan Mental (Render Dinamis Real-Time)
                        _buildProgressChartCard(screeningHistory),
                        const SizedBox(height: 24),

                        // Sub-judul Daftar Riwayat Terbaru
                        Text(
                          'Riwayat Terbaru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Daftar Kartu Riwayat Skrining (Tampil State Kosong / List)
                        if (screeningHistory.isEmpty)
                          _buildEmptyState(user)
                        else
                          ...List.generate(screeningHistory.length, (index) {
                            return _buildHistoryCard(
                              screeningHistory[index],
                              index,
                            );
                          }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Top AppBar ---
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Riwayat Skrining',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          // Tombol Cetak Dokumen Laporan PDF
          ElevatedButton.icon(
            onPressed: _isGeneratingPdf ? null : _exportPdfReport,
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
            label: Text(
              _isGeneratingPdf ? 'Memproses...' : 'Cetak PDF',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Text ---
  Widget _buildHeaderText(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perkembangan ${user.name}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // --- Filter Chips ---
  Widget _buildFilterChips() {
    final filters = ['Semua Riwayat', '30 Hari', '7 Hari', '3 Bulan'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D3142).withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  f,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// 📊 KARTU WIDGET GRAFIK TREN KESEHATAN MENTAL (_buildProgressChartCard)
  /// --------------------------------------------------------------------------
  /// Membungkus lukisan `CustomPainter` grafik kurva tren emosional pengguna:
  /// - Jika 0 data: Tampil pesan "Belum ada data grafik".
  /// - Jika 1 data: Tampil 1 titik koordinat hijau di grafik.
  /// - Jika >= 2 data: Tampil garis kurva tren melengkung halus (*smooth Bezier curve*).
  Widget _buildProgressChartCard(List<ScreeningRecord> rawRecords) {
    // Urutkan kronologis dari tes terlama (kiri) ke tes terbaru (kanan) untuk grafik timeline
    final chronological = rawRecords.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Kesehatan Mental',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${chronological.length} Tes Tersimpan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (chronological.isEmpty)
            Container(
              height: 140,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.show_chart_rounded,
                    size: 40,
                    color: AppColors.outlineVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada data grafik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Canvas Lukisan Grafik Tren Dinamis
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _DynamicMentalHealthTrendPainter(
                  records: chronological,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Baris Label Tanggal di Bawah Grafik
            Row(
              mainAxisAlignment: chronological.length == 1
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: chronological.map((rec) {
                final shortDate = _formatShortDate(rec.date);
                return Text(
                  shortDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Pesan Analisis & Insight Kestabilan Emosi Pengguna
          _buildInsightCallout(chronological),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// 💡 WIDGET PESAN ANALISIS & INSIGHT PERKEMBANGAN (_buildInsightCallout)
  /// --------------------------------------------------------------------------
  /// Menghitung selisih poin antara tes pertama dan tes terbaru untuk memberikan
  /// feedback psikologis (misal: "Tingkat kestabilan mentalmu meningkat +5 poin").
  Widget _buildInsightCallout(List<ScreeningRecord> chronological) {
    if (chronological.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lakukan skrining pertama untuk memantau grafik kestabilan kesehatan mental Anda.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (chronological.length == 1) {
      final first = chronological.first;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.stars_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Skor awal Anda adalah ${first.score}/100 (${first.title}). Lakukan tes berkala untuk melihat grafik tren perkembangan.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final int diff = chronological.last.score - chronological.first.score;
    final bool isImprovement = diff > 0;
    final bool isSame = diff == 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isImprovement
                ? Icons.trending_up_rounded
                : isSame
                ? Icons.trending_flat_rounded
                : Icons.trending_down_rounded,
            color: isImprovement
                ? AppColors.secondary
                : isSame
                ? AppColors.primary
                : AppColors.tertiary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: isImprovement
                        ? 'Tingkat kestabilan mentalmu meningkat '
                        : isSame
                        ? 'Kondisi kesehatan mentalmu terpantau '
                        : 'Skor kesehatan mentalmu mengalami perubahan ',
                  ),
                  TextSpan(
                    text: isImprovement
                        ? '+$diff poin'
                        : isSame
                        ? 'stabil (${chronological.last.score} poin)'
                        : '$diff poin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isImprovement
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: isImprovement
                        ? ' sejak tes pertama.'
                        : isSame
                        ? ' dalam evaluasi berkala.'
                        : '. Jaga istirahat dan luangkan waktu relaksasi.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveMoodAsset(String path, int score) {
    if (path.contains('assets/images/')) return path;
    if (score >= 75) return 'assets/images/senang.png';
    if (score >= 55) return 'assets/images/cemas.png';
    if (score >= 35) return 'assets/images/sedih.png';
    return 'assets/images/STRESS.png';
  }

  Widget _buildCardImage(String path, int score) {
    final assetPath = _resolveMoodAsset(path, score);
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.sentiment_satisfied_rounded,
        color: AppColors.primary,
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// 🎴 WIDGET KARTU ITEM RIWAYAT SKRINING (_buildHistoryCard)
  /// --------------------------------------------------------------------------
  /// Menampilkan judul diagnosis, skor, tanggal tes, serta tombol "Lihat Detail" & "Hapus".
  Widget _buildHistoryCard(ScreeningRecord item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.bg.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: _buildCardImage(item.image, item.score),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.score}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                  Text(
                    'Skor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Aksi: Lihat Detail Hasil & Tombol Hapus
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailHasilScreeningScreen(
                          score: item.score,
                          status: item.title,
                          date: item.date,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Lihat Detail Hasil',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteHistory(item),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.outline,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- State Kosong (Belum ada Riwayat) ---
  Widget _buildEmptyState(UserProfile user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada riwayat untuk ${user.name}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selesaikan kuesioner skrining pertama Anda untuk melihat perkembangan kesehatan mental di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 🎨 CUSTOM PAINTER GRAFIK KURVA TREN KESEHATAN MENTAL ([_DynamicMentalHealthTrendPainter])
/// ============================================================================
/// Menggambar grafik garis dinamis berbasis Canvas 2D Flutter:
/// 1. Garis Panduan Level Grid (Tinggi, Sedang, Rendah).
/// 2. Perhitungan Titik Koordinat Dinamis (Kiri: Tes Terlama -> Kanan: Tes Terbaru).
/// 3. Lukisan Kurva Melengkung Halus (*Cubic Bezier Curve*) & Warna Gradien Area di Bawah Garis.
/// 4. Lingkaran Titik Data Berwarna Sesuai Kategori Skor Emosional Pengguna.
class _DynamicMentalHealthTrendPainter extends CustomPainter {
  final List<ScreeningRecord> records;

  _DynamicMentalHealthTrendPainter({required this.records});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Gambar Garis Panduan Horizontal Grid (Grid Guidelines)
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.2), Offset(w, h * 0.2), gridPaint);
    canvas.drawLine(Offset(0, h * 0.55), Offset(w, h * 0.55), gridPaint);
    canvas.drawLine(Offset(0, h * 0.85), Offset(w, h * 0.85), gridPaint);

    if (records.isEmpty) return;

    // 2. Hitung Titik-Titik Koordinat (Points) dari Data Skor Skrining
    final List<Offset> points = [];
    for (int i = 0; i < records.length; i++) {
      final rec = records[i];
      // Jika 1 tes: letakkan di tengah canvas (w * 0.5). Jika >= 2 tes: bagi secara merata di lebar canvas (w)
      final double x = records.length == 1
          ? w * 0.5
          : (i / (records.length - 1)) * w;
      final double norm = (rec.score / 100.0).clamp(0.0, 1.0);
      final double y = (h * 0.85) - (norm * (h * 0.65));
      points.add(Offset(x, y));
    }

    // Jika HANYA 1 tes tersimpan: Gambar 1 titik lingkaran tunggal
    if (points.length == 1) {
      final pt = points.first;
      final pointPaint = Paint()..color = records.first.color;
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pt, 8, pointPaint);
      canvas.drawCircle(pt, 8, borderPaint);
      return;
    }

    // 3. Buat Garis Kurva Melengkung Halus (Smooth Cubic Bezier Curve)
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // 4. Gambar Warna Gradien Transparan di Bawah Garis Kurva
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.secondary.withValues(alpha: 0.25),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, fillPaint);

    // 5. Gambar Garis Kurva Utama (Stroke Line)
    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // 6. Gambar Lingkaran Titik Data (Data Point Dots)
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final rec = records[i];
      final pointPaint = Paint()..color = rec.color;
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pt, 6, pointPaint);
      canvas.drawCircle(pt, 6, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicMentalHealthTrendPainter oldDelegate) {
    return oldDelegate.records.length != records.length ||
        oldDelegate.records != records;
  }
}
