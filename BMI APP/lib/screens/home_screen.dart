// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/login_dropdown.dart';
import 'result_screen.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _showFt = false;

  final _heightCmCtrl = TextEditingController();
  final _heightFtCtrl = TextEditingController();
  final _heightInCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _heartCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AppProvider>();
      _heightCmCtrl.text = p.height.toStringAsFixed(0);
      _weightCtrl.text = p.weight.toStringAsFixed(1);
      _syncFtIn(p.height);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    for (final c in [
      _heightCmCtrl,
      _heightFtCtrl,
      _heightInCtrl,
      _weightCtrl,
      _bpSysCtrl,
      _bpDiaCtrl,
      _heartCtrl,
      _sugarCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncFtIn(double cm) {
    final totalIn = cm / 2.54;
    _heightFtCtrl.text = (totalIn ~/ 12).toString();
    _heightInCtrl.text = (totalIn % 12).toStringAsFixed(0);
  }

  void _syncCm(String ft, String inch) {
    final cm =
        ((double.tryParse(ft) ?? 0) * 12 + (double.tryParse(inch) ?? 0)) * 2.54;
    _heightCmCtrl.text = cm.toStringAsFixed(0);
    context.read<AppProvider>().setHeight(cm);
  }

  String get _greeting {
    final h = _now.hour;
    if (h >= 5 && h < 12) return 'Good Morning';
    if (h >= 12 && h < 17) return 'Good Afternoon';
    if (h >= 17 && h < 21) return 'Good Evening';
    return 'Good Night';
  }

  String get _greetingIcon {
    final h = _now.hour;
    if (h >= 5 && h < 12) return '🌅';
    if (h >= 12 && h < 17) return '☀️';
    if (h >= 17 && h < 21) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final textColor = AppTheme.getTextColor(isDark);
    final cardColor = AppTheme.getCardColor(isDark);
    final bgColor = AppTheme.getBgColor(isDark);
    final secColor = AppTheme.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppTheme.surface : Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? AppTheme.surface : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 44, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Vixo',
                        style: GoogleFonts.playfairDisplay(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 24)),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(DateFormat('hh:mm:ss a').format(_now),
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        Text(DateFormat('EEE, d MMM').format(_now),
                            style: TextStyle(
                                color: AppTheme.getTextMuted(isDark),
                                fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const LoginDropdownButton(),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting
                _greetingCard(provider, textColor)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.15),
                const SizedBox(height: 14),

                // Gender
                _genderCard(provider, cardColor, textColor, secColor)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 80.ms),
                const SizedBox(height: 14),

                // Height + Weight
                Row(children: [
                  Expanded(
                      child:
                          _heightCard(provider, cardColor, textColor, secColor)
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 160.ms)),
                  const SizedBox(width: 12),
                  Expanded(
                      child:
                          _weightCard(provider, cardColor, textColor, secColor)
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)),
                ]),
                const SizedBox(height: 14),

                // Birthdate
                _birthDateCard(provider, cardColor, textColor)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 240.ms),
                const SizedBox(height: 14),

                // Sleep
                _sleepCard(provider, cardColor, textColor)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 280.ms),
                const SizedBox(height: 14),

                // Health Metrics
                _healthMetrics(provider, cardColor, textColor, secColor)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 320.ms),
                const SizedBox(height: 20),

                // Calculate
                _calcButton(provider)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 360.ms),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _greetingCard(AppProvider provider, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_greetingIcon $_greeting,',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              provider.userName.isNotEmpty
                  ? provider.userName
                  : 'Health Champion!',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            if (provider.age > 0)
              Text('${provider.age} yrs · ${provider.gender}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        )),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child:
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
        ),
      ]),
    );
  }

  Widget _genderCard(
      AppProvider provider, Color cardColor, Color textColor, Color secColor) {
    return _card(cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender',
                style: GoogleFonts.poppins(
                    color: secColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _genderOpt(
                      'Male', Icons.man_rounded, provider, textColor)),
              const SizedBox(width: 8),
              Expanded(
                  child: _genderOpt(
                      'Female', Icons.woman_rounded, provider, textColor)),
              const SizedBox(width: 8),
              Expanded(
                  child: _genderOpt(
                      'Other', Icons.wc_rounded, provider, textColor)),
            ]),
          ],
        ));
  }

  Widget _genderOpt(
      String label, IconData icon, AppProvider provider, Color textColor) {
    final selected = provider.gender == label;
    return GestureDetector(
      onTap: () => provider.setGender(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent),
        ),
        child: Column(children: [
          Icon(icon,
              color: selected ? Colors.white : AppTheme.primary, size: 24),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.poppins(
                  color: selected ? Colors.white : textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _heightCard(
      AppProvider provider, Color cardColor, Color textColor, Color secColor) {
    return _card(cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.straighten_rounded,
                  color: AppTheme.primaryLight, size: 16),
              const SizedBox(width: 5),
              Text('Height',
                  style: GoogleFonts.poppins(color: secColor, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showFt = !_showFt),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(_showFt ? 'ft' : 'cm',
                      style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            if (!_showFt) ...[
              _numField(_heightCmCtrl, textColor, 'cm', AppTheme.primaryLight,
                  (v) {
                final val = double.tryParse(v);
                if (val != null && val >= 100 && val <= 220) {
                  provider.setHeight(val);
                  _syncFtIn(val);
                }
              }),
              _miniSlider(provider.height.clamp(100.0, 220.0), 100, 220,
                  AppTheme.primaryLight, (v) {
                provider.setHeight(v);
                _heightCmCtrl.text = v.toStringAsFixed(0);
                _syncFtIn(v);
              }),
            ] else ...[
              Row(children: [
                Expanded(
                    child: _numField(
                        _heightFtCtrl,
                        textColor,
                        'ft',
                        AppTheme.primaryLight,
                        (v) => _syncCm(v, _heightInCtrl.text))),
                const SizedBox(width: 6),
                Expanded(
                    child: _numField(
                        _heightInCtrl,
                        textColor,
                        'in',
                        AppTheme.primaryLight,
                        (v) => _syncCm(_heightFtCtrl.text, v))),
              ]),
            ],
          ],
        ));
  }

  Widget _weightCard(
      AppProvider provider, Color cardColor, Color textColor, Color secColor) {
    return _card(cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.scale_rounded, color: AppTheme.accent, size: 16),
              const SizedBox(width: 5),
              Text('Weight',
                  style: GoogleFonts.poppins(color: secColor, fontSize: 12)),
              const Spacer(),
              Text('kg',
                  style: GoogleFonts.poppins(
                      color: AppTheme.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            _numField(_weightCtrl, textColor, 'kg', AppTheme.accent, (v) {
              final val = double.tryParse(v);
              if (val != null && val >= 30 && val <= 200) {
                provider.setWeight(val);
              }
            }),
            _miniSlider(
                provider.weight.clamp(30.0, 200.0), 30, 200, AppTheme.accent,
                (v) {
              provider.setWeight(v);
              _weightCtrl.text = v.toStringAsFixed(1);
            }),
          ],
        ));
  }

  Widget _numField(TextEditingController ctrl, Color textColor, String unit,
      Color color, Function(String) onChange) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: GoogleFonts.poppins(
          color: color, fontSize: 22, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        suffix: Text(unit,
            style: TextStyle(color: AppTheme.getTextMuted(true), fontSize: 12)),
      ),
      onChanged: onChange,
    );
  }

  Widget _miniSlider(double val, double min, double max, Color color,
      ValueChanged<double> onChange) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: color,
        thumbColor: color,
        inactiveTrackColor: color.withValues(alpha: 0.18),
        overlayColor: color.withValues(alpha: 0.12),
      ),
      child: Slider(value: val, min: min, max: max, onChanged: onChange),
    );
  }

  Widget _birthDateCard(
      AppProvider provider, Color cardColor, Color textColor) {
    final isDark = provider.isDarkMode;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: provider.birthDate ?? DateTime(1995),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primary, surface: AppTheme.surfaceCard),
            ),
            child: child!,
          ),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
        );
        if (picked != null) provider.setBirthDate(picked);
      },
      child: _card(AppTheme.getCardColor(isDark),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.cake_outlined,
                  color: AppTheme.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date of Birth',
                    style: TextStyle(
                        color: AppTheme.getTextMuted(isDark), fontSize: 11)),
                Text(
                  provider.birthDate != null
                      ? DateFormat('MMMM dd, yyyy').format(provider.birthDate!)
                      : 'Tap to select',
                  style: GoogleFonts.poppins(
                      color: provider.birthDate != null
                          ? textColor
                          : AppTheme.getTextMuted(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            )),
            if (provider.age > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16)),
                child: Text('${provider.age} yrs',
                    style: GoogleFonts.poppins(
                        color: AppTheme.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                color: AppTheme.getTextMuted(isDark), size: 18),
          ])),
    );
  }

  Widget _sleepCard(AppProvider provider, Color cardColor, Color textColor) {
    final status = BMIUtils.getSleepStatus(provider.sleepHours);
    final color = status == 'Optimal'
        ? AppTheme.normalColor
        : status == 'Insufficient'
            ? AppTheme.accentLight
            : AppTheme.overweightColor;
    return _card(cardColor,
        child: Column(
          children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.bedtime_outlined, color: color, size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sleep Hours',
                    style: TextStyle(
                        color: AppTheme.getTextMuted(provider.isDarkMode),
                        fontSize: 11)),
                Row(children: [
                  Text('${provider.sleepHours.toStringAsFixed(1)} hrs',
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(status,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            ]),
            _miniSlider(provider.sleepHours, 1, 14, color,
                (v) => provider.setSleepHours(v)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('1 hr',
                  style: TextStyle(
                      color: AppTheme.getTextMuted(provider.isDarkMode),
                      fontSize: 9)),
              Text('14 hrs',
                  style: TextStyle(
                      color: AppTheme.getTextMuted(provider.isDarkMode),
                      fontSize: 9)),
            ]),
          ],
        ));
  }

  Widget _healthMetrics(
      AppProvider provider, Color cardColor, Color textColor, Color secColor) {
    return _card(cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.favorite_border_rounded,
                      color: AppTheme.accent, size: 16)),
              const SizedBox(width: 9),
              Text('Health Metrics',
                  style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme.normalColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Optional',
                    style: TextStyle(
                        color: AppTheme.normalColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _metricBox(
                      'Systolic',
                      _bpSysCtrl,
                      '120',
                      'mmHg',
                      const Color(0xFFE53935),
                      textColor,
                      (v) => provider.setBpSystolic(double.tryParse(v)))),
              Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(' / ',
                      style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700))),
              Expanded(
                  child: _metricBox(
                      'Diastolic',
                      _bpDiaCtrl,
                      '80',
                      'mmHg',
                      const Color(0xFFE53935),
                      textColor,
                      (v) => provider.setBpDiastolic(double.tryParse(v)))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _metricBox(
                      'Heart Rate',
                      _heartCtrl,
                      '72',
                      'bpm',
                      AppTheme.accent,
                      textColor,
                      (v) => provider.setHeartRate(double.tryParse(v)))),
              const SizedBox(width: 10),
              Expanded(
                  child: _metricBox(
                      'Blood Sugar',
                      _sugarCtrl,
                      '100',
                      'mg/dL',
                      AppTheme.gold,
                      textColor,
                      (v) => provider.setBloodSugar(double.tryParse(v)))),
            ]),
          ],
        ));
  }

  Widget _metricBox(String label, TextEditingController ctrl, String hint,
      String unit, Color color, Color textColor, Function(String) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(color: AppTheme.getTextMuted(true), fontSize: 10)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(children: [
          Expanded(
              child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
                color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: AppTheme.getTextMuted(true), fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: onChange,
          )),
          Text(unit,
              style: TextStyle(
                  color: color, fontSize: 8, fontWeight: FontWeight.w700)),
        ]),
      ),
    ]);
  }

  Widget _calcButton(AppProvider provider) {
    return GestureDetector(
      onTap: () {
        // Check if user is logged in
        if (!FirebaseService.isLoggedIn) {
          // Show toast notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please login first to calculate BMI',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
          // Navigate to login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
          return;
        }

        // Existing calculation logic (same as before)
        provider.calculateBMI();
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ResultScreen(),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 9),
          Text('Calculate BMI',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _card(Color color, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  // ignore: unused_element
  void _editName(AppProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(provider.isDarkMode),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Name',
            style: GoogleFonts.poppins(
                color: AppTheme.getTextColor(provider.isDarkMode),
                fontWeight: FontWeight.w700)),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            style: GoogleFonts.poppins(
                color: AppTheme.getTextColor(provider.isDarkMode)),
            decoration: const InputDecoration(
                hintText: 'Enter your name',
                prefixIcon:
                    Icon(Icons.person_outline, color: AppTheme.primary))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: AppTheme.textMuted))),
          ElevatedButton(
              onPressed: () {
                provider.setUserName(ctrl.text.trim());
                Navigator.pop(ctx);
              },
              child: Text('Save', style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
}
