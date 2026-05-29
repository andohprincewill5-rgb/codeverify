import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'scanner_screen.dart';
import 'admin_screen.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'pricing_screen.dart';
import '../services/verification_service.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5A0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_sharp,
                        color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'CodeVerify',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => themeNotifier.toggle(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF00E5A0).withOpacity(0.4)),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: const Color(0xFF00E5A0),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

              const SizedBox(height: 16),
              Text(
                'Scan any code and instantly\nverify its authenticity.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: subtitleColor,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 40),

              _ActionCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan Code',
                subtitle: 'Use your camera to scan QR, barcode, or any code',
                color: const Color(0xFF00E5A0),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              _ActionCard(
                icon: Icons.keyboard_alt_outlined,
                title: 'Enter Manually',
                subtitle: 'Type or paste a code to verify it',
                color: const Color(0xFF6C63FF),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => _showManualEntryDialog(context),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              _ActionCard(
                icon: Icons.history_rounded,
                title: 'Scan History',
                subtitle: 'View all previously scanned codes',
                color: const Color(0xFFFFB800),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => _showPasswordDialog(
                  context,
                  onSuccess: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              _ActionCard(
                icon: Icons.workspace_premium_rounded,
                title: 'Pricing Plans',
                subtitle: 'Subscribe to unlock more features',
                color: const Color(0xFF00B4D8),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PricingScreen()),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              _ActionCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Panel',
                subtitle: 'Add and manage codes in your registry',
                color: const Color(0xFFFF6B6B),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => _showPasswordDialog(
                  context,
                  onSuccess: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  'Powered by Supabase + Claude AI',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: subtitleColor.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, {required VoidCallback onSuccess}) {
    final controller = TextEditingController();
    bool obscure = true;
    bool loading = false;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: themeNotifier.isDark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.lock_rounded,
                  color: Color(0xFFFF6B6B), size: 20),
              const SizedBox(width: 8),
              Text('Protected Area',
                  style: GoogleFonts.spaceGrotesk(
                      color: themeNotifier.isDark
                          ? Colors.white
                          : Colors.black87)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your admin password to continue.',
                  style: GoogleFonts.inter(
                      color: themeNotifier.isDark
                          ? Colors.white54
                          : Colors.black45,
                      fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                style: TextStyle(
                    color: themeNotifier.isDark
                        ? Colors.white
                        : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                      color: themeNotifier.isDark
                          ? Colors.white38
                          : Colors.black38),
                  prefixIcon: const Icon(Icons.password_rounded,
                      color: Colors.white38),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white38),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  filled: true,
                  fillColor: themeNotifier.isDark
                      ? const Color(0xFF0A0A0F)
                      : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFFF6B6B), width: 2),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style: GoogleFonts.inter(
                        color: const Color(0xFFFF6B6B), fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) return;
                      setState(() {
                        loading = true;
                        error = null;
                      });
                      final service = VerificationService();
                      final correct = await service
                          .verifyAdminPassword(controller.text.trim());
                      if (correct) {
                        Navigator.pop(ctx);
                        onSuccess();
                      } else {
                        setState(() {
                          loading = false;
                          error = '❌ Incorrect password. Try again.';
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeNotifier.isDark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        title: Text('Enter Code',
            style: GoogleFonts.spaceGrotesk(
                color: themeNotifier.isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          style: TextStyle(
              color: themeNotifier.isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Paste or type code here...',
            hintStyle: TextStyle(
                color: themeNotifier.isDark
                    ? Colors.white38
                    : Colors.black38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E5A0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF00E5A0), width: 2),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5A0),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResultScreen(scannedCode: controller.text.trim()),
                  ),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: subtitleColor, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}
