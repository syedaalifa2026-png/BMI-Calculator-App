// lib/services/pdf_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record.dart';

class PdfService {
  static Future<void> generateBMIReport({
    required String userName,
    required int age,
    required String gender,
    required List<BmiRecord> history,
    required BmiRecord latestRecord,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#0D7377');
    final accentColor = PdfColor.fromHex('#FF6B6B');
    final goldColor = PdfColor.fromHex('#FFB300');
    // Light/white theme PDF
    const bgColor = PdfColors.white;
    final cardColor = PdfColor.fromHex('#F5F7FA');
    final textLight = PdfColor.fromHex('#1A1A2E');
    final textGrey = PdfColor.fromHex('#4A5568');

    String getCategoryColor(String cat) {
      switch (cat) {
        case 'Underweight': return '#5B8AF0';
        case 'Normal': return '#06D6A0';
        case 'Overweight': return '#FFD166';
        case 'Obese': return '#FF6B6B';
        default: return '#0D7377';
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          buildBackground: (context) => pw.Container(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
          ),
          margin: const pw.EdgeInsets.all(0),
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [primaryColor, PdfColor.fromHex('#14A085')],
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BMI HEALTH REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style: pw.TextStyle(color: PdfColor.fromHex('#B2EBF2'), fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white.shade(0.2),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      'Vixo',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.Container(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      color: cardColor,
                      borderRadius: pw.BorderRadius.circular(16),
                      border: pw.Border.all(color: primaryColor.shade(0.3), width: 1),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 70,
                          height: 70,
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 32,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              userName.isNotEmpty ? userName : 'User',
                              style: pw.TextStyle(
                                color: textLight,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '$gender · $age years · ${latestRecord.height.toStringAsFixed(0)} cm · ${latestRecord.weight.toStringAsFixed(1)} kg',
                              style: pw.TextStyle(color: textGrey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 24),

                  // Current BMI Card
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(24),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex(getCategoryColor(latestRecord.category)).shade(0.1),
                            borderRadius: pw.BorderRadius.circular(16),
                            border: pw.Border.all(
                              color: PdfColor.fromHex(getCategoryColor(latestRecord.category)),
                              width: 1,
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Current BMI', style: pw.TextStyle(color: textGrey, fontSize: 12)),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                latestRecord.bmi.toStringAsFixed(1),
                                style: pw.TextStyle(
                                  color: PdfColor.fromHex(getCategoryColor(latestRecord.category)),
                                  fontSize: 48,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex(getCategoryColor(latestRecord.category)),
                                  borderRadius: pw.BorderRadius.circular(20),
                                ),
                                child: pw.Text(
                                  latestRecord.category,
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildStatCard('Weight', '${latestRecord.weight.toStringAsFixed(1)} kg', primaryColor, cardColor, textLight, textGrey),
                            pw.SizedBox(height: 12),
                            _buildStatCard('Height', '${latestRecord.height.toStringAsFixed(0)} cm', goldColor, cardColor, textLight, textGrey),
                            pw.SizedBox(height: 12),
                            _buildStatCard('Sleep', '${latestRecord.sleepHours.toStringAsFixed(1)} hrs', accentColor, cardColor, textLight, textGrey),
                          ],
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 24),

                  // BMI Scale
                  pw.Text(
                    'BMI Classification Scale',
                    style: pw.TextStyle(color: textLight, fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      _buildScaleBox('< 18.5', 'Underweight', PdfColor.fromHex('#5B8AF0')),
                      pw.SizedBox(width: 8),
                      _buildScaleBox('18.5–24.9', 'Normal', PdfColor.fromHex('#06D6A0')),
                      pw.SizedBox(width: 8),
                      _buildScaleBox('25–29.9', 'Overweight', PdfColor.fromHex('#FFD166')),
                      pw.SizedBox(width: 8),
                      _buildScaleBox('≥ 30', 'Obese', PdfColor.fromHex('#FF6B6B')),
                    ],
                  ),

                  pw.SizedBox(height: 24),

                  // History Table
                  if (history.isNotEmpty) ...[
                    pw.Text(
                      'BMI History (Last ${history.length > 10 ? 10 : history.length} Records)',
                      style: pw.TextStyle(color: textLight, fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Table(
                      border: pw.TableBorder.all(color: primaryColor.shade(0.2), width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                        4: const pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: primaryColor),
                          children: ['Date', 'BMI', 'Weight', 'Height', 'Category']
                              .map((h) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(h,
                                        style: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10)),
                                  ))
                              .toList(),
                        ),
                        ...history.take(10).map((r) => pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: history.indexOf(r) % 2 == 0 ? cardColor : bgColor,
                              ),
                              children: [
                                DateFormat('MMM dd, yyyy').format(r.date),
                                r.bmi.toStringAsFixed(1),
                                '${r.weight.toStringAsFixed(1)} kg',
                                '${r.height.toStringAsFixed(0)} cm',
                                r.category,
                              ]
                                  .map((cell) => pw.Padding(
                                        padding: const pw.EdgeInsets.all(8),
                                        child: pw.Text(cell,
                                            style: pw.TextStyle(color: textGrey, fontSize: 9)),
                                      ))
                                  .toList(),
                            )),
                      ],
                    ),
                  ],

                  pw.SizedBox(height: 32),

                  // Health Tips
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E8F5F5'),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: primaryColor.shade(0.4)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Health Recommendations',
                            style: pw.TextStyle(
                                color: textLight, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 12),
                        ..._getHealthTips(latestRecord.category)
                            .map((tip) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 6),
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('• ',
                                          style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                                      pw.Expanded(
                                        child: pw.Text(tip,
                                            style: pw.TextStyle(color: textGrey, fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // Footer
                  pw.Center(
                    child: pw.Text(
                      'Generated by Vixo · This report is for informational purposes only',
                      style: pw.TextStyle(color: textGrey, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _buildStatCard(String label, String value, PdfColor color,
      PdfColor cardColor, PdfColor textLight, PdfColor textGrey) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: cardColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color.shade(0.3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(color: textGrey, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(color: color, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildScaleBox(String range, String label, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color.shade(0.1),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: color, width: 0.5),
        ),
        child: pw.Column(
          children: [
            pw.Text(range,
                style: pw.TextStyle(
                    color: color, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: pw.TextStyle(color: PdfColor.fromHex('#B0BEC5'), fontSize: 8)),
          ],
        ),
      ),
    );
  }

  static List<String> _getHealthTips(String category) {
    switch (category) {
      case 'Underweight':
        return [
          'Increase caloric intake with nutrient-dense foods like nuts, avocados, and whole grains.',
          'Incorporate strength training 3-4 times per week to build muscle mass.',
          'Eat 5-6 smaller meals throughout the day instead of 3 large meals.',
          'Consider consulting a nutritionist for a personalized meal plan.',
          'Track your daily calorie intake to ensure you meet energy requirements.',
        ];
      case 'Normal':
        return [
          'Maintain your current healthy habits — you\'re in the optimal BMI range!',
          'Continue with 150 minutes of moderate aerobic activity per week.',
          'Keep a balanced diet rich in fruits, vegetables, lean proteins, and whole grains.',
          'Stay hydrated by drinking at least 8 glasses of water daily.',
          'Aim for 7-9 hours of quality sleep each night.',
        ];
      case 'Overweight':
        return [
          'Aim for a caloric deficit of 300-500 calories per day for gradual weight loss.',
          'Increase physical activity to at least 200-300 minutes per week.',
          'Reduce intake of processed foods, sugary drinks, and high-fat snacks.',
          'Monitor portion sizes and practice mindful eating.',
          'Consider tracking your meals to better understand your eating patterns.',
        ];
      case 'Obese':
        return [
          'Consult with a healthcare provider for a structured weight management plan.',
          'Start with low-impact exercises like walking or swimming to reduce joint stress.',
          'Focus on sustainable dietary changes rather than extreme restriction.',
          'Consider working with a registered dietitian for personalized guidance.',
          'Monitor blood pressure, blood sugar, and cholesterol levels regularly.',
        ];
      default:
        return ['Maintain a balanced diet and regular physical activity.'];
    }
  }
}
