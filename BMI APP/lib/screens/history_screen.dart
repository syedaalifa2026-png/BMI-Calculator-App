// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record.dart';
import '../services/app_provider.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/login_dropdown.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? AppTheme.surface : const Color(0xFFF0F4F8);
    final cardColor = isDark ? AppTheme.surfaceCard : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surface : Colors.white,
        title: Text('BMI History', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: textColor)),
        actions: [
          if (provider.history.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primary),
              tooltip: 'Generate PDF',
              onPressed: () => _generatePDF(context, provider),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.accent),
              tooltip: 'Clear All',
              onPressed: () => _showClearDialog(context, provider),
            ),
          ],
          const LoginDropdownButton(),
        ],
      ),
      body: provider.history.isEmpty
          ? _buildEmptyState(textColor)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.history.length >= 2)
                    _buildProgressChart(provider, cardColor, textColor)
                        .animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  _buildStatsSummary(provider, cardColor, textColor)
                      .animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 20),
                  Text('All Records (${provider.history.length})',
                      style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...provider.history.asMap().entries.map((entry) {
                    return _buildHistoryCard(context, entry.value, provider, cardColor, textColor)
                        .animate().fadeIn(delay: Duration(milliseconds: 80 * entry.key)).slideX(begin: 0.1);
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.history, size: 60, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text('No Records Yet', style: GoogleFonts.poppins(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Calculate your BMI and save it\nto build your health history',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProgressChart(AppProvider provider, Color cardColor, Color textColor) {
    final records = provider.history.reversed.toList();
    final spots = records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.bmi)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BMI Progress Chart', style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
          const Text('Your BMI trend over time', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.textMuted.withValues(alpha: 0.1), strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35,
                    getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                    getTitlesWidget: (v, m) {
                      final idx = v.toInt();
                      if (idx >= 0 && idx < records.length) {
                        return Text(DateFormat('d/M').format(records[idx].date), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9));
                      }
                      return const SizedBox.shrink();
                    })),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots, isCurved: true, curveSmoothness: 0.3,
                  color: AppTheme.primary, barWidth: 3, isStrokeCapRound: true,
                  dotData: FlDotData(show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 5,
                          color: BMIUtils.getCategoryColor(BMIUtils.getCategory(spot.y)),
                          strokeWidth: 2, strokeColor: Colors.white)),
                  belowBarData: BarAreaData(show: true, color: AppTheme.primary.withValues(alpha: 0.05)),
                ),
              ],
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(y: 18.5, color: AppTheme.underweightColor.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5],
                    label: HorizontalLineLabel(show: true, labelResolver: (_) => '18.5', style: const TextStyle(color: AppTheme.underweightColor, fontSize: 9))),
                HorizontalLine(y: 25, color: AppTheme.normalColor.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5],
                    label: HorizontalLineLabel(show: true, labelResolver: (_) => '25', style: const TextStyle(color: AppTheme.normalColor, fontSize: 9))),
                HorizontalLine(y: 30, color: AppTheme.overweightColor.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5],
                    label: HorizontalLineLabel(show: true, labelResolver: (_) => '30', style: const TextStyle(color: AppTheme.overweightColor, fontSize: 9))),
              ]),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(AppProvider provider, Color cardColor, Color textColor) {
    if (provider.history.isEmpty) return const SizedBox.shrink();
    final bmis = provider.history.map((r) => r.bmi).toList();
    final avg = bmis.reduce((a, b) => a + b) / bmis.length;
    final minBmi = bmis.reduce((a, b) => a < b ? a : b);
    final maxBmi = bmis.reduce((a, b) => a > b ? a : b);
    final trend = provider.history.length >= 2 ? provider.history.first.bmi - provider.history.last.bmi : 0.0;

    return Row(
      children: [
        Expanded(child: _summaryBox('Average', avg.toStringAsFixed(1), AppTheme.primary, cardColor, textColor)),
        const SizedBox(width: 10),
        Expanded(child: _summaryBox('Lowest', minBmi.toStringAsFixed(1), AppTheme.normalColor, cardColor, textColor)),
        const SizedBox(width: 10),
        Expanded(child: _summaryBox('Highest', maxBmi.toStringAsFixed(1), AppTheme.obeseColor, cardColor, textColor)),
        const SizedBox(width: 10),
        Expanded(child: _summaryBox('Trend', '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}',
            trend < 0 ? AppTheme.normalColor : AppTheme.accent, cardColor, textColor)),
      ],
    );
  }

  Widget _summaryBox(String label, String value, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      ]),
    );
  }

  Widget _buildHistoryCard(BuildContext context, BmiRecord record, AppProvider provider, Color cardColor, Color textColor) {
    final catColor = BMIUtils.getCategoryColor(record.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showRecordDetail(context, record, provider, catColor, textColor),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: catColor.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: catColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(record.bmi.toStringAsFixed(1),
                    style: GoogleFonts.poppins(color: catColor, fontSize: 13, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${BMIUtils.getCategoryEmoji(record.category)} ${record.category}',
                        style: GoogleFonts.poppins(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${record.weight.toStringAsFixed(1)}kg · ${record.height.toStringAsFixed(0)}cm · ${record.sleepHours.toStringAsFixed(1)}hrs sleep',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    if (record.heartRate != null || record.bpSystolic != null)
                      Text(
                        '${record.heartRate != null ? '❤️ ${record.heartRate!.toStringAsFixed(0)}bpm' : ''}'
                        '${record.bpSystolic != null ? '  🩸 ${record.bpSystolic!.toStringAsFixed(0)}/${record.bpDiastolic?.toStringAsFixed(0)}' : ''}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('d MMM\nyyyy').format(record.date),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  // Delete button
                  GestureDetector(
                    onTap: () => _confirmDelete(context, record, provider),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppTheme.accent, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetail(BuildContext context, BmiRecord record, AppProvider provider, Color catColor, Color textColor) {
    final isDark = provider.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceCard : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: catColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),

            // BMI score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: catColor.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                // Big BMI number
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(record.bmi.toStringAsFixed(1),
                      style: GoogleFonts.poppins(color: catColor, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${BMIUtils.getCategoryEmoji(record.category)} ${record.category}',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
                const Spacer(),
                // Date & gender
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(DateFormat('d MMM yyyy').format(record.date),
                      style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(DateFormat('hh:mm a').format(record.date),
                      style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 10)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(record.gender,
                        style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            ),

            const SizedBox(height: 12),

            // Stats row — small chips
            Row(children: [
              Expanded(child: _miniStatChip('Weight', '${record.weight.toStringAsFixed(1)} kg', AppTheme.accent, isDark)),
              const SizedBox(width: 8),
              Expanded(child: _miniStatChip('Height', '${record.height.toStringAsFixed(0)} cm', AppTheme.primaryLight, isDark)),
              const SizedBox(width: 8),
              Expanded(child: _miniStatChip('Sleep', '${record.sleepHours.toStringAsFixed(1)} hrs', AppTheme.normalColor, isDark)),
              const SizedBox(width: 8),
              Expanded(child: _miniStatChip('Age', '${record.age} yrs', AppTheme.gold, isDark)),
            ]),

            // Health metrics if present
            if (record.heartRate != null || record.bpSystolic != null || record.bloodSugar != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                if (record.heartRate != null) ...[
                  Expanded(child: _miniStatChip('Heart Rate', '${record.heartRate!.toStringAsFixed(0)} bpm', AppTheme.accent, isDark)),
                  const SizedBox(width: 8),
                ],
                if (record.bpSystolic != null) ...[
                  Expanded(child: _miniStatChip('Blood Pressure',
                      '${record.bpSystolic!.toStringAsFixed(0)}/${record.bpDiastolic?.toStringAsFixed(0)}',
                      const Color(0xFFE53935), isDark)),
                  const SizedBox(width: 8),
                ],
                if (record.bloodSugar != null)
                  Expanded(child: _miniStatChip('Blood Sugar', '${record.bloodSugar!.toStringAsFixed(0)} mg/dL', AppTheme.gold, isDark)),
              ]),
            ],

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _miniStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w700),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 9),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, BmiRecord record, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: provider.isDarkMode ? AppTheme.surfaceCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Record?', style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'BMI ${record.bmi.toStringAsFixed(1)} recorded on ${DateFormat('d MMM yyyy').format(record.date)} will be deleted.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () { provider.deleteRecord(record); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(BuildContext context, AppProvider provider) async {
    if (provider.history.isEmpty) return;
    await PdfService.generateBMIReport(
      userName: provider.userName, age: provider.age,
      gender: provider.gender, history: provider.history,
      latestRecord: provider.history.first,
    );
  }

  void _showClearDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All History?', style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('All ${provider.history.length} records will be permanently deleted.',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () { provider.clearHistory(); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: Text('Clear All', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
