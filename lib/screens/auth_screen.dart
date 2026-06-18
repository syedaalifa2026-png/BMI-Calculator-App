// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import 'main_scaffold.dart';
import '../services/admin_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _error;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _nameCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (!_isLogin && _passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await FirebaseService.login(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        final cred = await FirebaseService.register(
            _emailCtrl.text.trim(), _passCtrl.text);
        if (cred != null) {
          final name = _nameCtrl.text.trim();
          await FirebaseService.updateDisplayName(name);
          await FirebaseService.saveUserProfile(name: name);
          if (mounted) context.read<AppProvider>().setUserName(name);
        }
      }
      if (mounted) {
        if (AdminService.isAdmin) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/admin', (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScaffold()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = AppTheme.getBgColor(isDark);
    final cardColor = AppTheme.getCardColor(isDark);
    final textColor = AppTheme.getTextColor(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),

              // Logo + Title
              Column(children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Icon(Icons.health_and_safety_rounded,
                      color: Colors.white, size: 44),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text('Vixo',
                        style: GoogleFonts.playfairDisplay(
                            color: AppTheme.primary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800))
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 4),
                Text(
                  _isLogin ? 'Welcome back!' : 'Create your account',
                  style: TextStyle(
                      color: AppTheme.getTextMuted(isDark), fontSize: 14),
                ).animate().fadeIn(delay: 300.ms),
              ]),

              const SizedBox(height: 32),

              // Auth Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Column(children: [
                  // Name (register only)
                  if (!_isLogin) ...[
                    _inputField(
                      ctrl: _nameCtrl,
                      hint: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email
                  _inputField(
                    ctrl: _emailCtrl,
                    hint: 'Email Address',
                    icon: Icons.email_outlined,
                    textColor: textColor,
                    isDark: isDark,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  _passwordField(
                    ctrl: _passCtrl,
                    hint: 'Password',
                    obscure: _obscure,
                    textColor: textColor,
                    isDark: isDark,
                    onToggle: () => setState(() => _obscure = !_obscure),
                  ),

                  // Confirm password (register only)
                  if (!_isLogin) ...[
                    const SizedBox(height: 14),
                    _passwordField(
                      ctrl: _confirmPassCtrl,
                      hint: 'Confirm Password',
                      obscure: _obscureConfirm,
                      textColor: textColor,
                      isDark: isDark,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.accent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: AppTheme.accent, fontSize: 12))),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(_isLogin ? 'Login' : 'Create Account',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  // Forgot password (login only)
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _forgotPassword(context, isDark),
                      child: const Text('Forgot Password?',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Toggle between Login and Register (Link style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(
                          color: AppTheme.getTextMuted(isDark),
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                            // Clear fields when switching
                            _emailCtrl.clear();
                            _passCtrl.clear();
                            _confirmPassCtrl.clear();
                            _nameCtrl.clear();
                          });
                        },
                        child: Text(
                          _isLogin ? "Sign Up" : "Login",
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),

              const SizedBox(height: 20),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required Color textColor,
    required bool isDark,
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: GoogleFonts.poppins(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.primary.withValues(alpha: 0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required Color textColor,
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 13),
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.primary, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppTheme.getTextMuted(isDark),
            size: 18,
          ),
        ),
        filled: true,
        fillColor: AppTheme.primary.withValues(alpha: 0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }

  void _forgotPassword(BuildContext context, bool isDark) {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reset Password',
            style: GoogleFonts.poppins(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter your email to receive a password reset link.',
              style: TextStyle(
                  color: AppTheme.getTextMuted(isDark), fontSize: 13)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
                color: AppTheme.getTextColor(isDark), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Email address',
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppTheme.primary, size: 18),
              filled: true,
              fillColor: AppTheme.primary.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseService.resetPassword(ctrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Reset email sent!', style: GoogleFonts.poppins()),
                    backgroundColor: AppTheme.normalColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text('Send Reset Email', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
