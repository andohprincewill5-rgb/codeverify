import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/subscription_service.dart';
import '../main.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _emailController = TextEditingController();
  String _selectedPlan = 'basic';
  bool _loading = false;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'free',
      'name': 'Free',
      'price': '0',
      'scans': 50,
      'features': ['50 scans/month', 'Manual entry only', 'Basic verification'],
      'color': const Color(0xFF6C63FF),
    },
    {
      'id': 'basic',
      'name': 'Basic',
      'price': '5,000',
      'scans': 500,
      'features': ['500 scans/month', 'Camera scanning', 'Scan history', 'Email support'],
      'color': const Color(0xFF00E5A0),
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'price': '12,000',
      'scans': 99999,
      'features': ['Unlimited scans', 'All features', 'CSV export', 'Priority support'],
      'color': const Color(0xFFFFB800),
    },
    {
      'id': 'business',
      'name': 'Business',
      'price': '25,000',
      'scans': 99999,
      'features': ['Unlimited scans', 'Multiple users', 'Custom registry', 'Dedicated support'],
      'color': const Color(0xFFFF6B6B),
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showPaymentDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeNotifier.isDark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        title: Text('Subscribe to ${plan['name']}',
            style: GoogleFonts.spaceGrotesk(
                color: themeNotifier.isDark ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5A0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF00E5A0).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💳 Payment Instructions',
                        style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFF00E5A0),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('1. Send ${plan['price']} FCFA via MTN Mobile Money',
                        style: GoogleFonts.inter(
                            color: themeNotifier.isDark
                                ? Colors.white70
                                : Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('2. Number: ',
                            style: GoogleFonts.inter(
                                color: themeNotifier.isDark
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 13)),
                        Text('674067324',
                            style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFF00E5A0),
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: '674067324'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Number copied!')),
                            );
                          },
                          child: const Icon(Icons.copy_rounded,
                              color: Color(0xFF00E5A0), size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('3. Name: TIBUNG STEPHENE ENTUM',
                        style: GoogleFonts.inter(
                            color: themeNotifier.isDark
                                ? Colors.white70
                                : Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('4. Enter your email below and click "I\'ve Paid"',
                        style: GoogleFonts.inter(
                            color: themeNotifier.isDark
                                ? Colors.white70
                                : Colors.black87,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: TextStyle(
                    color: themeNotifier.isDark
                        ? Colors.white
                        : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'example@gmail.com',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.email_rounded,
                      color: Colors.white38),
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
                        color: Color(0xFF00E5A0), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '⚠️ Your plan will be activated within 24 hours after payment confirmation.',
                style: GoogleFonts.inter(
                    color: themeNotifier.isDark
                        ? Colors.white38
                        : Colors.black38,
                    fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5A0),
              foregroundColor: Colors.black,
            ),
            onPressed: _loading
                ? null
                : () async {
                    if (_emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter your email!')),
                      );
                      return;
                    }
                    setState(() => _loading = true);
                    try {
                      await SubscriptionService().registerPendingSubscription(
                        email: _emailController.text.trim(),
                        plan: plan['id'],
                        scansLimit: plan['scans'],
                      );
                      Navigator.pop(ctx);
                      _showSuccessDialog(plan);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                    setState(() => _loading = false);
                  },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text("I've Paid"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeNotifier.isDark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF00E5A0), size: 64),
            const SizedBox(height: 16),
            Text('Payment Submitted!',
                style: GoogleFonts.spaceGrotesk(
                    color: themeNotifier.isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Your ${plan['name']} plan will be activated within 24 hours after we confirm your payment.\n\nThank you for subscribing! 🎉',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: themeNotifier.isDark ? Colors.white54 : Colors.black45,
                  fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5A0),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor =
        isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        title: Text('Pricing Plans',
            style: GoogleFonts.spaceGrotesk(color: textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Choose Your Plan',
                style: GoogleFonts.spaceGrotesk(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('All prices in FCFA per month',
                style: GoogleFonts.inter(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14)),
            const SizedBox(height: 24),
            ..._plans.asMap().entries.map((entry) {
              final i = entry.key;
              final plan = entry.value;
              final color = plan['color'] as Color;
              final isPopular = plan['id'] == 'basic';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isPopular
                          ? color
                          : color.withOpacity(0.3),
                      width: isPopular ? 2 : 1),
                ),
                child: Column(
                  children: [
                    if (isPopular)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Text('⭐ MOST POPULAR',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.workspace_premium_rounded,
                                    color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(plan['name'],
                                  style: GoogleFonts.spaceGrotesk(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    plan['price'] == '0'
                                        ? 'FREE'
                                        : '${plan['price']} FCFA',
                                    style: GoogleFonts.spaceGrotesk(
                                        color: color,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  if (plan['price'] != '0')
                                    Text('/month',
                                        style: GoogleFonts.inter(
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.black38,
                                            fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...(plan['features'] as List<String>).map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: color, size: 16),
                                  const SizedBox(width: 8),
                                  Text(f,
                                      style: GoogleFonts.inter(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: plan['price'] == '0'
                                    ? color.withOpacity(0.2)
                                    : color,
                                foregroundColor: plan['price'] == '0'
                                    ? color
                                    : Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: plan['price'] == '0'
                                  ? null
                                  : () => _showPaymentDialog(plan),
                              child: Text(
                                plan['price'] == '0'
                                    ? 'Current Plan'
                                    : 'Subscribe Now',
                                style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: i * 100), duration: 500.ms);
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: Color(0xFF00E5A0)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need help?',
                            style: GoogleFonts.spaceGrotesk(
                                color: textColor,
                                fontWeight: FontWeight.w600)),
                        Text('Contact us on MTN: 674067324',
                            style: GoogleFonts.inter(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
