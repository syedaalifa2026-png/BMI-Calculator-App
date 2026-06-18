// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/login_dropdown.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _nameController = TextEditingController(text: provider.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? AppTheme.surface : const Color(0xFFF0F4F8);
    final cardColor = AppTheme.getCardColor(isDark);
    final textColor = isDark ? AppTheme.textPrimary : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.getBgColor(isDark),
        title: Text('Settings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: textColor)),
        actions: const [
          LoginDropdownButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(provider, cardColor, textColor)
                .animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),
            _sectionTitle('Appearance', textColor),
            const SizedBox(height: 10),

            // Dark Mode Toggle
            _buildSwitchTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              iconColor: AppTheme.gold,
              title: 'Dark Mode',
              subtitle: isDark ? 'Switch to light theme' : 'Switch to dark theme',
              value: isDark,
              onChanged: (_) => provider.toggleTheme(),
              cardColor: cardColor,
              textColor: textColor,
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 10),

            // Unit System
            _buildDropdownTile(
              icon: Icons.straighten,
              iconColor: AppTheme.primaryLight,
              title: 'Unit System',
              subtitle: 'Measurement units',
              value: provider.unitSystem,
              items: ['Metric', 'Imperial'],
              onChanged: (v) => provider.setUnitSystem(v!),
              cardColor: cardColor,
              textColor: textColor,
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),
            _sectionTitle('Health Goals', textColor),
            const SizedBox(height: 10),

            _buildInfoTile(
              icon: Icons.track_changes,
              iconColor: AppTheme.normalColor,
              title: 'Target BMI',
              subtitle: 'Ideal: 18.5 – 24.9',
              cardColor: cardColor,
              textColor: textColor,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 10),

            _buildInfoTile(
              icon: Icons.bedtime_outlined,
              iconColor: AppTheme.primaryLight,
              title: 'Sleep Goal',
              subtitle: '7 – 9 hours per night',
              cardColor: cardColor,
              textColor: textColor,
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 20),
            _sectionTitle('About', textColor),
            const SizedBox(height: 10),

            _buildAboutCard(cardColor, textColor).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AppProvider provider, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _editName(provider),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      provider.userName.isNotEmpty
                          ? provider.userName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.userName.isNotEmpty ? provider.userName : 'Add your name',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.age > 0
                ? '${provider.age} years · ${provider.gender}'
                : 'Setup your profile',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),

          // Profile details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _profileStatIcon('Gender', provider.gender, 
                provider.gender == 'Male' ? Icons.man_rounded : 
                provider.gender == 'Female' ? Icons.woman_rounded : Icons.wc_rounded,
                provider.gender == 'Male' ? AppTheme.primaryLight :
                provider.gender == 'Female' ? AppTheme.accent : AppTheme.gold),
              _profileStat('Age', provider.age > 0 ? '${provider.age} yrs' : 'N/A', '🎂'),
              _profileStat('BMI', provider.currentBMI > 0 ? provider.currentBMI.toStringAsFixed(1) : 'N/A', '📊'),
            ],
          ),

          const SizedBox(height: 12),

          // Birth date
          GestureDetector(
            onTap: () => _pickBirthDate(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cake_outlined, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    provider.birthDate != null
                        ? DateFormat('MMMM dd, yyyy').format(provider.birthDate!)
                        : 'Set birth date',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _profileStatIcon(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item,
                          style: GoogleFonts.poppins(
                              color: textColor, fontSize: 13)),
                    ))
                .toList(),
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            dropdownColor: cardColor,
            style: GoogleFonts.poppins(color: AppTheme.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.health_and_safety, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          Text('Vixo',
              style: GoogleFonts.playfairDisplay(
                  color: textColor, fontSize: 22, fontWeight: FontWeight.w700)),
          const Text('Advanced BMI Calculator',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('Version 1.0.0',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 12),
          const Text(
            'Track your health journey with BMI monitoring, progress charts, AI health advice, and PDF reports.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Ignore analyzer unused_element warning: function is kept for future use / callbacks
  // ignore: unused_element
  void _showLoginMenu(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(isDark),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        final tColor = AppTheme.getTextColor(isDark);
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            CircleAvatar(radius: 30, backgroundColor: AppTheme.primary,
                child: Text(provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Text(provider.userName.isNotEmpty ? provider.userName : 'Guest User',
                style: GoogleFonts.poppins(color: tColor, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(provider.age > 0 ? '${provider.age} yrs · ${provider.gender}' : 'Set up your profile',
                style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 12)),
            const SizedBox(height: 16),
            Divider(color: AppTheme.getBorderColor(isDark)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () { Navigator.pop(ctx); _editName(provider); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 19),
                  const SizedBox(width: 11),
                  Text('Edit Profile', style: GoogleFonts.poppins(color: tColor, fontSize: 14, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 17),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                provider.setUserName('');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged out', style: GoogleFonts.poppins()),
                  backgroundColor: AppTheme.accent, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.logout_rounded, color: AppTheme.accent, size: 19),
                  const SizedBox(width: 11),
                  Text('Logout', style: GoogleFonts.poppins(color: tColor, fontSize: 14, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 17),
                ]),
              ),
            ),
            const SizedBox(height: 14),
          ]),
        );
      },
    );
  }


  void _editName(AppProvider provider) {
    _nameController.text = provider.userName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Name',
            style: GoogleFonts.poppins(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: _nameController,
          style: GoogleFonts.poppins(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setUserName(_nameController.text.trim());
              Navigator.pop(ctx);
            },
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDate(AppProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.birthDate ?? DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surfaceCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) provider.setBirthDate(picked);
  }
}

// Extension method added at bottom
