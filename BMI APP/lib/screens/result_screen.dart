// lib/screens/result_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';


class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _gaugeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutBack));
    _gaugeController.forward();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bmi = provider.currentBMI;
    final category = provider.currentCategory;
    final catColor = BMIUtils.getCategoryColor(category);
    // Result screen: white background, deep colors for text
    const bgColor = Color(0xFFF5F7FA);
    const cardColor = Colors.white;
    const textColor = Color(0xFF1A1A2E);
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'BMI Result',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            actions: [
              if (!_saved)
                TextButton.icon(
                  onPressed: () async {
                    // Check if logged in
                    if (!FirebaseService.isLoggedIn) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surfaceCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: Text('Login Required',
                                style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                            content: Text(
                              'Please login to save your BMI records and sync across devices.',
                              style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AuthScreen()));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: Text('Login', style: GoogleFonts.poppins()),
                              ),
                            ],
                          ),
                        );
                      }
                      return;
                    }
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await provider.saveBMIRecord();
                    if (!mounted) return;
                    setState(() => _saved = true);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Record saved to Firebase! ☁️', style: GoogleFonts.poppins()),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, color: AppTheme.primary),
                  label: Text('Save', style: GoogleFonts.poppins(color: AppTheme.primary)),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.check_circle, color: AppTheme.normalColor),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // BMI Gauge
                _buildGaugeCard(bmi, category, catColor, cardColor, textColor)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox('Weight', '${provider.weight.toStringAsFixed(1)} kg',
                              Icons.monitor_weight_outlined, AppTheme.accent, cardColor, textColor)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideX(begin: -0.2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox('Height', '${provider.height.toStringAsFixed(0)} cm',
                              Icons.height, AppTheme.primaryLight, cardColor, textColor)
                          .animate()
                          .fadeIn(delay: 300.ms),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox('Sleep', '${provider.sleepHours.toStringAsFixed(1)} hrs',
                              Icons.bedtime_outlined, AppTheme.gold, cardColor, textColor)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideX(begin: 0.2),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category Distribution Pie Chart
                _buildPieChartCard(bmi, cardColor, textColor)
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Ideal Weight
                _buildIdealWeightCard(provider, catColor, cardColor, textColor)
                    .animate()
                    .fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                // Health Tips
                _buildHealthTipsCard(category, catColor, cardColor, textColor)
                    .animate()
                    .fadeIn(delay: 700.ms),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard(double bmi, String category, Color catColor, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: catColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your BMI Score',
            style: GoogleFonts.poppins(color: const Color(0xFF4A5568), fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Custom Gauge
          AnimatedBuilder(
            animation: _gaugeAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: BMIGaugePainter(
                    bmi: bmi * _gaugeAnimation.value,
                    catColor: catColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          (bmi * _gaugeAnimation.value).toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: catColor,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${BMIUtils.getCategoryEmoji(category)} $category',
                            style: GoogleFonts.poppins(
                              color: catColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // BMI Scale Bar
          _buildBMIScaleBar(bmi),
        ],
      ),
    );
  }

  Widget _buildBMIScaleBar(double bmi) {
    return Column(
      children: [
        Row(
          children: [
            _scaleLabel('Underweight', AppTheme.underweightColor),
            _scaleLabel('Normal', AppTheme.normalColor),
            _scaleLabel('Overweight', AppTheme.overweightColor),
            _scaleLabel('Obese', AppTheme.obeseColor),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.underweightColor,
                    AppTheme.normalColor,
                    AppTheme.overweightColor,
                    AppTheme.obeseColor,
                  ],
                ),
              ),
            ),
            // Indicator
            Positioned(
              left: _getBMIPosition(bmi, MediaQuery.of(context).size.width - 80),
              child: Container(
                width: 14,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10', style: TextStyle(color: Color(0xFF718096), fontSize: 9)),
            Text('18.5', style: TextStyle(color: Color(0xFF718096), fontSize: 9)),
            Text('25', style: TextStyle(color: Color(0xFF718096), fontSize: 9)),
            Text('30', style: TextStyle(color: Color(0xFF718096), fontSize: 9)),
            Text('40+', style: TextStyle(color: Color(0xFF718096), fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _scaleLabel(String label, Color color) {
    return Expanded(
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _getBMIPosition(double bmi, double width) {
    final clamped = bmi.clamp(10.0, 40.0);
    return ((clamped - 10) / 30) * (width - 14);
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: Color(0xFF718096), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(double bmi, Color cardColor, Color textColor) {
    // Pie chart showing how close to each category
    final sections = _getPieSections(bmi);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BMI Category Distribution',
              style: GoogleFonts.poppins(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 45,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pieLegend('Underweight', '<18.5', AppTheme.underweightColor),
                    const SizedBox(height: 10),
                    _pieLegend('Normal', '18.5-24.9', AppTheme.normalColor),
                    const SizedBox(height: 10),
                    _pieLegend('Overweight', '25-29.9', AppTheme.overweightColor),
                    const SizedBox(height: 10),
                    _pieLegend('Obese', '≥30', AppTheme.obeseColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(double bmi) {
    // Show position within spectrum
    final category = BMIUtils.getCategory(bmi);
    return [
      PieChartSectionData(
        value: 25,
        color: category == 'Underweight'
            ? AppTheme.underweightColor
            : AppTheme.underweightColor.withValues(alpha: 0.3),
        radius: category == 'Underweight' ? 35 : 25,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 25,
        color: category == 'Normal'
            ? AppTheme.normalColor
            : AppTheme.normalColor.withValues(alpha: 0.3),
        radius: category == 'Normal' ? 35 : 25,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 25,
        color: category == 'Overweight'
            ? AppTheme.overweightColor
            : AppTheme.overweightColor.withValues(alpha: 0.3),
        radius: category == 'Overweight' ? 35 : 25,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 25,
        color: category == 'Obese'
            ? AppTheme.obeseColor
            : AppTheme.obeseColor.withValues(alpha: 0.3),
        radius: category == 'Obese' ? 35 : 25,
        showTitle: false,
      ),
    ];
  }

  Widget _pieLegend(String label, String range, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(range, style: const TextStyle(color: Color(0xFF718096), fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdealWeightCard(AppProvider provider, Color catColor, Color cardColor, Color textColor) {
    final minW = BMIUtils.getIdealWeightMin(provider.height, provider.gender);
    final maxW = BMIUtils.getIdealWeightMax(provider.height, provider.gender);
    final diff = provider.weight - maxW;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.monitor_weight, color: catColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ideal Weight Range',
                    style: GoogleFonts.poppins(color: const Color(0xFF4A5568), fontSize: 12)),
                Text(
                  '${minW.toStringAsFixed(1)} – ${maxW.toStringAsFixed(1)} kg',
                  style: GoogleFonts.poppins(
                      color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  diff > 0
                      ? '${diff.abs().toStringAsFixed(1)} kg above ideal range'
                      : diff < -5
                          ? '${diff.abs().toStringAsFixed(1)} kg below ideal range'
                          : 'You\'re in your ideal range! 🎉',
                  style: TextStyle(
                    color: diff.abs() < 5 ? AppTheme.normalColor : catColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipsCard(String category, Color catColor, Color cardColor, Color textColor) {
    final tips = _getTips(category);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: catColor, size: 20),
              const SizedBox(width: 8),
              Text('Health Tips',
                  style: GoogleFonts.poppins(
                      color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _getTips(String category) {
    switch (category) {
      case 'Underweight':
        return [
          'Eat calorie-dense foods like nuts, avocados, and whole grains',
          'Do strength training 3-4 times per week to build muscle',
          'Eat 5-6 smaller meals throughout the day',
          'Consult a nutritionist for a personalized meal plan',
        ];
      case 'Normal':
        return [
          'Maintain 150+ minutes of moderate exercise per week',
          'Keep eating a balanced diet with fruits, veggies, and lean protein',
          'Stay hydrated — aim for 8 glasses of water daily',
          'Continue your healthy lifestyle — you\'re doing great!',
        ];
      case 'Overweight':
        return [
          'Create a 300-500 calorie deficit per day',
          'Increase physical activity to 200+ minutes per week',
          'Reduce processed foods and sugary drinks',
          'Track your meals to understand eating patterns',
        ];
      case 'Obese':
        return [
          'Consult a healthcare provider for a weight management plan',
          'Start with low-impact exercise like walking or swimming',
          'Focus on sustainable dietary changes, not extreme restriction',
          'Monitor blood pressure and cholesterol regularly',
        ];
      default:
        return ['Maintain a balanced diet and stay active!'];
    }
  }
}

// Custom BMI Gauge Painter
class BMIGaugePainter extends CustomPainter {
  final double bmi;
  final Color catColor;

  BMIGaugePainter({required this.bmi, required this.catColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = math.min(size.width, size.height) * 0.45;

    // Background arc (multiple colors)
    final colors = [
      AppTheme.underweightColor,
      AppTheme.normalColor,
      AppTheme.overweightColor,
      AppTheme.obeseColor,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.3)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + (i * math.pi / 4),
        math.pi / 4,
        false,
        paint,
      );
    }

    // Active arc
    final bmiClamped = bmi.clamp(10.0, 40.0);
    final sweepAngle = ((bmiClamped - 10) / 30) * math.pi;
    final activePaint = Paint()
      ..color = catColor
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      activePaint,
    );

    // Needle
    final angle = math.pi + sweepAngle;
    final needleEnd = Offset(
      center.dx + (radius - 22) * math.cos(angle),
      center.dy + (radius - 22) * math.sin(angle),
    );
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 6, Paint()..color = catColor);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(BMIGaugePainter oldDelegate) => oldDelegate.bmi != bmi;
}
