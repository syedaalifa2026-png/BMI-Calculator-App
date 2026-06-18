// lib/widgets/login_dropdown.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_provider.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import '../screens/auth_screen.dart';

class LoginDropdownButton extends StatelessWidget {
  const LoginDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? provider.userName;

    return GestureDetector(
      onTap: () => _showDropdown(context, provider, isDark, user),
      child: Container(
        margin: const EdgeInsets.only(right: 10, top: 9, bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            user != null ? Icons.account_circle : Icons.account_circle_outlined,
            color: AppTheme.primary, size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            name.isNotEmpty ? name.split(' ')[0] : 'Login',
            style: GoogleFonts.poppins(
                color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.arrow_drop_down, color: AppTheme.primary, size: 15),
        ]),
      ),
    );
  }

  void _showDropdown(BuildContext context, AppProvider provider, bool isDark, User? user) {
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (ctx) {
        final textColor = AppTheme.getTextColor(isDark);
        final cardColor = AppTheme.getCardColor(isDark);
        return Stack(children: [
          GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Colors.transparent)),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(ctx).padding.top + 2,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.07),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: user != null
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                        child: Text(
                          _initial(user, provider),
                          style: const TextStyle(color: Colors.white,
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (user?.displayName ?? provider.userName).isNotEmpty
                                  ? (user?.displayName ?? provider.userName)
                                  : 'Guest',
                              style: GoogleFonts.poppins(color: textColor,
                                  fontSize: 12, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user != null ? (user.email ?? '') : 'Not logged in',
                              style: TextStyle(
                                  color: AppTheme.getTextMuted(isDark),
                                  fontSize: 9),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ])),
                    ]),
                  ),

                  if (user == null) ...[
                    _item(ctx, Icons.login_rounded, 'Login / Register',
                        AppTheme.primary, textColor, isDark, () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()));
                    }),
                    Divider(height: 1, color: AppTheme.getBorderColor(isDark)),
                  ],

                  if (user != null) ...[
                    _item(ctx, Icons.person_outline_rounded, 'Edit Profile',
                        AppTheme.primary, textColor, isDark, () {
                      Navigator.pop(ctx);
                      _editName(context, provider, isDark);
                    }),
                    Divider(height: 1, color: AppTheme.getBorderColor(isDark)),
                  ],

                  _item(ctx,
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      isDark ? 'Light Mode' : 'Dark Mode',
                      AppTheme.gold, textColor, isDark, () {
                    provider.toggleTheme();
                    Navigator.pop(ctx);
                  }),

                  Divider(height: 1, color: AppTheme.getBorderColor(isDark)),

                  _item(ctx, Icons.logout_rounded, 'Logout',
                      AppTheme.accent, textColor, isDark, () async {
                    Navigator.pop(ctx);
                    await FirebaseService.logout();
                    provider.setUserName('');
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    }
                  }),
                ]),
              ),
            ),
          ),
        ]);
      },
    );
  }

  String _initial(User? user, AppProvider provider) {
    final name = user?.displayName ?? provider.userName;
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _item(BuildContext ctx, IconData icon, String label,
      Color color, Color textColor, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.transparent,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 9),
          Text(label, style: GoogleFonts.poppins(
              color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  void _editName(BuildContext context, AppProvider provider, bool isDark) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Edit Name', style: GoogleFonts.poppins(
            color: AppTheme.getTextColor(isDark), fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: GoogleFonts.poppins(color: AppTheme.getTextColor(isDark)),
          decoration: const InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              provider.setUserName(name);
              await FirebaseService.updateDisplayName(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
