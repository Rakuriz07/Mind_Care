import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mindcare/models/app_models.dart';

class PdfReportService {
  /// Generates a PDF byte array representing the user's mental health screening progress report.
  static Future<Uint8List> generateScreeningReport({
    required UserProfile user,
    required List<ScreeningRecord> records,
  }) async {
    final pdf = pw.Document();

    final nowStr = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now());

    final total = records.length;
    double avgScore = 0;
    if (total > 0) {
      avgScore = records.map((e) => e.score).reduce((a, b) => a + b) / total;
    }

    final latestRecord = records.isNotEmpty ? records.first : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Branding & Header Title
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1E3A8A'), // Deep Indigo/Navy Professional Header
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MINDCARE HEALTH REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Laporan Perkembangan & Tren Kesehatan Mental Pengguna',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber400,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'DOKUMEN RAHASIA',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // User Identity Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Nama Pengguna: ${user.name}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Email Terdaftar: ${user.email}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal Ekspor: $nowStr',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Total Skrining: $total Tes',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Statistics Widgets Row
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.teal50,
                      border: pw.Border.all(color: PdfColors.teal200),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Rata-Rata Skor', style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal900)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          avgScore.toStringAsFixed(1),
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue200),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Skor Skrining Terakhir', style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue900)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          latestRecord != null ? '${latestRecord.score} / 100' : '-',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber50,
                      border: pw.Border.all(color: PdfColors.amber200),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Status Terakhir', style: const pw.TextStyle(fontSize: 9, color: PdfColors.amber900)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          latestRecord != null ? latestRecord.title : '-',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Section Header
            pw.Text(
              'Riwayat Hasil Skrining Terperinci',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
            ),
            pw.SizedBox(height: 8),

            // History Records Table
            if (records.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 24),
                child: pw.Center(
                  child: pw.Text(
                    'Belum ada data riwayat skrining kesehatan mental tersimpan.',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                  ),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E3A8A')),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(28),
                  1: const pw.FlexColumnWidth(2.2),
                  2: const pw.FlexColumnWidth(1.2),
                  3: const pw.FlexColumnWidth(3),
                },
                headers: ['No', 'Tanggal Evaluasi', 'Skor', 'Status Emosional & Hasil Skrining'],
                data: List.generate(records.length, (index) {
                  final item = records[index];
                  return [
                    '${index + 1}',
                    item.date,
                    '${item.score} / 100',
                    item.title,
                  ];
                }),
              ),
            pw.SizedBox(height: 20),

            // Guidance & Consultation Note
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.blueGrey200),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Catatan Penting untuk Sesi Konsultasi Psikolog / Konselor:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blueGrey900),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Bullet(
                    text: 'Tunjukkan dokumen ini saat berkonsultasi dengan profesional kesehatan mental (Psikolog/Psikiater).',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Bullet(
                    text: 'Grafik tren dan riwayat skor membantu profesional memahami fluktuasi emosi harian dan mingguan Anda.',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Bullet(
                    text: 'Bila mengalami krisis atau kondisi darurat kesehatan jiwa, hubungi Hotline Kemenkes RI 119 ext 8 (Sehat Jiwa).',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Footer Disclaimer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MindCare App - Asisten Kesehatan Mental & Self-Care',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Laporan Resmi Pengguna',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
