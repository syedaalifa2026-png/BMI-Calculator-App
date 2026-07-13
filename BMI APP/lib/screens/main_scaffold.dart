// lib/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const ChatScreen(),
    const SettingsScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'History'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'AI Chat'),
    _NavItem(icon: Icons.tune_outlined, activeIcon: Icons.tune_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final navBg = isDark ? AppTheme.surfaceCard : Colors.white;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
          border: Border(top: BorderSide(color: AppTheme.getBorderColor(isDark), width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? AppTheme.primary : AppTheme.getTextMuted(isDark), size: 22),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          child: isSelected ? Row(children: [
                            const SizedBox(width: 6),
                            Text(item.label, style: GoogleFonts.poppins(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                          ]) : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
