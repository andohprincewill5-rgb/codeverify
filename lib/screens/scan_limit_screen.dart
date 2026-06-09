import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pricing_screen.dart';
import '../main.dart';

class ScanLimitScreen extends StatelessWidget {
  final int scansUsed;
  final int scansLimit;

  const ScanLimitScreen({
    super.key,
    required this.scansUsed,
    required this.scansLimit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFFFB800), width: 2),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Color(0xFFFFB800), size: 60),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 500.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text('Free Limit Reached!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFFFB800),
                      fontSize: 26,
                      fontWeight: FontWeight.w700))
                  .animate()
                  .fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              Text(
                'You have used all $scansLimit free scans.\nUpgrade to continue verifying codes!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 15,
                    height: 1.6),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),

              // Stats card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFFFB800).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Scans Used',
                            style: GoogleFonts.inter(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45)),
                        Text('$scansUsed / $scansLimit',
                            style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFFFB800),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: scansUsed / scansLimit,
                        backgroundColor: const Color(0xFFFFB800).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFB800)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              // Upgrade button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PricingScreen()),
                  ),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: Text('Upgrade Now',
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back',
                    style: GoogleFonts.inter(
                        color: isDark ? Colors.white38 : Colors.black38)),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
