// lib/screens/chat_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/ai_chat_service.dart';
import '../utils/app_theme.dart';
import '../widgets/login_dropdown.dart';


class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? imageBase64;
  ChatMessage({required this.text, required this.isUser, required this.time, this.imageBase64});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '🥗 Diet tips for my BMI',
    '🏃 Best exercises',
    '😴 Sleep advice',
    '💧 Hydration tips',
    '📊 Explain my BMI',
    '🧠 Stress management',
    '🔥 Calorie guide',
    '💪 Build muscle',
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>();
    final bmi = p.currentBMI > 0 ? p.currentBMI.toStringAsFixed(1) : 'not yet calculated';
    final cat = p.currentCategory.isNotEmpty ? p.currentCategory : '';
    _messages.add(ChatMessage(
      text: '👋 **Hello, ${p.userName.isNotEmpty ? p.userName : "there"}!**\n\n'
          'I\'m **VixoAI**, your personal health assistant! 🏥\n\n'
          '${p.currentBMI > 0 ? "Your current BMI is **$bmi** ($cat).\n\n" : ""}'
          'Ask me anything about health, diet, exercise, or sleep!\n\n'
          '📎 You can also **upload images or PDF reports** for analysis.',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage(String text, {String? imageBase64}) async {
    if (text.trim().isEmpty && imageBase64 == null) return;
    final provider = context.read<AppProvider>();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now(), imageBase64: imageBase64));
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    String prompt = text;
    if (imageBase64 != null) prompt = text.isNotEmpty ? text : 'Please analyze this uploaded file/image for health insights.';

    final response = await AIChatService.getAIResponse(
      prompt,
      provider.currentCategory.isNotEmpty ? provider.currentCategory : 'Normal',
      provider.currentBMI > 0 ? provider.currentBMI : 22.0,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) {
        final provider = context.read<AppProvider>();
        final isDark = provider.isDarkMode;
        return AlertDialog(
          backgroundColor: AppTheme.getCardColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Clear Chat?', style: GoogleFonts.poppins(color: AppTheme.getTextColor(isDark), fontWeight: FontWeight.w700)),
          content: Text('All messages will be deleted.', style: GoogleFonts.poppins(color: AppTheme.getTextSecondary(isDark))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage(
                    text: '🔄 Chat cleared! How can I help you today?',
                    isUser: false, time: DateTime.now(),
                  ));
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Clear', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showUploadOptions() {
    final provider = context.read<AppProvider>();
    final isDark = provider.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDark),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.getBorderColor(isDark), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Upload for AI Analysis',
                  style: GoogleFonts.poppins(color: AppTheme.getTextColor(isDark), fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Share files for health insights',
                  style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 12)),
            ])),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getTextMuted(isDark).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.close_rounded, color: AppTheme.getTextMuted(isDark), size: 18),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // Upload options grid
          Row(children: [
            Expanded(child: _uploadCard(
              icon: Icons.picture_as_pdf_rounded,
              title: 'PDF Report',
              subtitle: 'Lab results, Medical reports',
              color: const Color(0xFFE53935),
              isDark: isDark,
              onTap: () { Navigator.pop(ctx); _handleFileUpload('pdf'); },
            )),
            const SizedBox(width: 10),
            Expanded(child: _uploadCard(
              icon: Icons.image_rounded,
              title: 'Image / Photo',
              subtitle: 'Food photos, Progress pics',
              color: AppTheme.primary,
              isDark: isDark,
              onTap: () { Navigator.pop(ctx); _handleFileUpload('image'); },
            )),
            const SizedBox(width: 10),
            Expanded(child: _uploadCard(
              icon: Icons.article_outlined,
              title: 'Health Report',
              subtitle: 'Blood test, Diet plan',
              color: AppTheme.gold,
              isDark: isDark,
              onTap: () { Navigator.pop(ctx); _handleFileUpload('report'); },
            )),
          ]),

          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Files are analyzed locally. Tap any option to select a file from your device.',
                style: TextStyle(color: AppTheme.getTextSecondary(isDark), fontSize: 11),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _uploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.poppins(color: AppTheme.getTextColor(isDark), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 10, height: 1.4)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: Text('Select', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }



  Future<void> _handleFileUpload(String type) async {
    try {
      final provider = context.read<AppProvider>();
      FilePickerResult? result;
      String userMsg = '';

      if (type == 'image') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
        if (result == null) return;
        final file = result.files.first;
        userMsg = '🖼️ [Image uploaded: ${file.name}]';
      } else {
        result = await FilePicker.platform.pickFiles(
          type: type == 'pdf' ? FileType.custom : FileType.any,
          allowedExtensions: type == 'pdf' ? ['pdf'] : null,
          allowMultiple: false,
          withData: true,
        );
        if (result == null) return;
        final file = result.files.first;
        userMsg = type == 'pdf'
            ? '📄 [PDF uploaded: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)]'
            : '📊 [Report uploaded: ${file.name}]';
      }

      setState(() {
        _messages.add(ChatMessage(text: userMsg, isUser: true, time: DateTime.now()));
        _isTyping = true;
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 1200));

      String aiResponse = '';
      if (type == 'image') {
        aiResponse = '🔍 **Image Received: ${result.files.first.name}**\n\n'
            'File size: ${(result.files.first.size / 1024).toStringAsFixed(1)} KB\n\n'
            'I can see your image has been uploaded! For full AI image analysis, '
            'you would need to connect this to the Claude Vision API.\n\n'
            'Based on your current health data:\n'
            '• BMI: **${provider.currentBMI.toStringAsFixed(1)}** (${provider.currentCategory})\n'
            '• If this is a food photo, describe what you ate and I\'ll estimate the nutritional value!\n'
            '• If this is a body/progress photo, tell me your goals and I\'ll give personalized advice.\n\n'
            'What would you like to know about this image?';
      } else if (type == 'pdf') {
        aiResponse = '📋 **PDF Received: ${result.files.first.name}**\n\n'
            'File size: ${(result.files.first.size / 1024).toStringAsFixed(1)} KB\n\n'
            'Your PDF has been uploaded successfully! For full text extraction and AI analysis, '
            'the Claude Document API would be used in production.\n\n'
            '**What I can help you with:**\n'
            '• Blood test result interpretation\n'
            '• Normal range explanations\n'
            '• Nutrition and health recommendations\n'
            '• BMI-specific health insights\n\n'
            'Please type out any specific values from your report and I\'ll analyze them in detail!';
      } else {
        aiResponse = '📊 **Report Received: ${result.files.first.name}**\n\n'
            'Your health report has been uploaded!\n\n'
            'Share the key values from your report and I\'ll provide a detailed health analysis based on your BMI (**${provider.currentBMI.toStringAsFixed(1)}**) and health profile.';
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: aiResponse, isUser: false, time: DateTime.now()));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open file picker: $e'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = AppTheme.getBgColor(isDark);
    final cardColor = AppTheme.getCardColor(isDark);
    final textColor = AppTheme.getTextColor(isDark);
    final aiBubble = isDark ? AppTheme.surfaceCard : const Color(0xFFE8F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surface : Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('VixoAI', style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
            Text('Health Assistant', style: TextStyle(color: AppTheme.getTextMuted(isDark), fontSize: 10)),
          ]),
        ]),
        actions: [
          const LoginDropdownButton(),
          // Clear chat
          IconButton(
            icon: Icon(Icons.cleaning_services_outlined, color: AppTheme.getTextMuted(isDark), size: 20),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length && _isTyping) return _typingBubble(aiBubble);
              final msg = _messages[i];
              return _msgBubble(msg, aiBubble, textColor).animate().fadeIn(duration: 280.ms).slideY(begin: 0.08);
            },
          ),
        ),

        if (_messages.length <= 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: bgColor,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _quickPrompts.map((p) {
                return GestureDetector(
                  onTap: () => _sendMessage(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(p, style: GoogleFonts.poppins(color: AppTheme.primary, fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
          ),

        _inputBar(cardColor, textColor, bgColor),
      ]),
    );
  }

  Widget _msgBubble(ChatMessage msg, Color aiBubble, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(width: 30, height: 30,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 16)),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Column(crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: msg.isUser ? AppTheme.primary : aiBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isUser ? 16 : 3),
                    bottomRight: Radius.circular(msg.isUser ? 3 : 16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: _msgText(msg.text, msg.isUser, textColor),
              ),
              const SizedBox(height: 2),
              Text('${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
            ]),
          ),
          if (msg.isUser) const SizedBox(width: 7),
        ],
      ),
    );
  }

  Widget _msgText(String text, bool isUser, Color textColor) {
    final color = isUser ? Colors.white : textColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: text.split('\n').map((line) {
        if (line.isEmpty) return const SizedBox(height: 3);
        final parts = line.split('**');
        if (parts.length > 1) {
          return RichText(text: TextSpan(children: parts.asMap().entries.map((e) =>
            TextSpan(text: e.value, style: GoogleFonts.poppins(color: color, fontWeight: e.key % 2 == 1 ? FontWeight.w700 : FontWeight.normal, fontSize: 13, height: 1.5))
          ).toList()));
        }
        return Text(line, style: GoogleFonts.poppins(color: color, fontSize: 13, height: 1.5));
      }).toList(),
    );
  }

  Widget _typingBubble(Color aiBubble) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 30, height: 30,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 16)),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: aiBubble, borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16),
            bottomRight: Radius.circular(16), bottomLeft: Radius.circular(3),
          )),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7, height: 7,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              )
              .animate(onPlay: (c) => c.repeat())
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: const Duration(milliseconds: 550), delay: Duration(milliseconds: 180 * i))
              .then()
              .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 550));
            }),
          ),
        ),
      ]),
    );
  }

  Widget _inputBar(Color cardColor, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 22),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(children: [
        // Upload button
        GestureDetector(
          onTap: _showUploadOptions,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25))),
            child: const Icon(Icons.attach_file_rounded, color: AppTheme.primary, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
            child: TextField(
              controller: _ctrl,
              style: GoogleFonts.poppins(color: textColor, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ask about health, or upload a report...',
                hintStyle: TextStyle(color: AppTheme.getTextMuted(true), fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: _sendMessage,
              maxLines: null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_ctrl.text),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}
