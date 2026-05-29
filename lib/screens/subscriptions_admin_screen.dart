import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/subscription_service.dart';
import '../main.dart';

class SubscriptionsAdminScreen extends StatefulWidget {
  const SubscriptionsAdminScreen({super.key});

  @override
  State<SubscriptionsAdminScreen> createState() =>
      _SubscriptionsAdminScreenState();
}

class _SubscriptionsAdminScreenState extends State<SubscriptionsAdminScreen> {
  final _service = SubscriptionService();
  List<Map<String, dynamic>> _subscriptions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final subs = await _service.getAllSubscriptions();
      setState(() {
        _subscriptions = subs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _planColor(String plan) {
    switch (plan) {
      case 'basic':
        return const Color(0xFF00E5A0);
      case 'pro':
        return const Color(0xFFFFB800);
      case 'business':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        title: Text('Manage Subscriptions',
            style: GoogleFonts.spaceGrotesk(color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadSubscriptions,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5A0)))
          : _subscriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subscriptions_rounded,
                          color: isDark ? Colors.white24 : Colors.black12,
                          size: 64),
                      const SizedBox(height: 16),
                      Text('No subscriptions yet',
                          style: GoogleFonts.spaceGrotesk(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 18)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Total',
                              value: _subscriptions.length.toString(),
                              color: textColor,
                            ),
                            _StatItem(
                              label: 'Active',
                              value: _subscriptions
                                  .where((s) => s['activated'] == true)
                                  .length
                                  .toString(),
                              color: const Color(0xFF00E5A0),
                            ),
                            _StatItem(
                              label: 'Pending',
                              value: _subscriptions
                                  .where((s) => s['activated'] == false)
                                  .length
                                  .toString(),
                              color: const Color(0xFFFFB800),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _subscriptions.length,
                        itemBuilder: (ctx, i) {
                          final sub = _subscriptions[i];
                          final plan = sub['plan'] ?? 'free';
                          final activated = sub['activated'] == true;
                          final color = _planColor(plan);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: activated
                                      ? color.withOpacity(0.4)
                                      : const Color(0xFFFFB800).withOpacity(0.3),
                                  width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        plan.toUpperCase(),
                                        style: GoogleFonts.spaceGrotesk(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: activated
                                            ? const Color(0xFF00E5A0).withOpacity(0.15)
                                            : const Color(0xFFFFB800).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        activated ? '✅ Active' : '⏳ Pending',
                                        style: GoogleFonts.inter(
                                            color: activated
                                                ? const Color(0xFF00E5A0)
                                                : const Color(0xFFFFB800),
                                            fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(sub['email'] ?? '',
                                    style: GoogleFonts.inter(
                                        color: textColor,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  'Scans: ${sub['scans_used'] ?? 0} / ${sub['scans_limit'] == 99999 ? '∞' : sub['scans_limit']}',
                                  style: GoogleFonts.inter(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black45,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (!activated)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00E5A0),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            await _service.activateSubscription(
                                                sub['email']);
                                            _loadSubscriptions();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          '✅ Subscription activated!')));
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.check_circle_rounded,
                                              size: 16),
                                          label: Text('Activate',
                                              style: GoogleFonts.spaceGrotesk(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                        ),
                                      ),
                                    if (activated) ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFFF6B6B),
                                            side: const BorderSide(
                                                color: Color(0xFFFF6B6B)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            await _service.deactivateSubscription(
                                                sub['email']);
                                            _loadSubscriptions();
                                          },
                                          icon: const Icon(
                                              Icons.cancel_rounded,
                                              size: 16),
                                          label: Text('Deactivate',
                                              style: GoogleFonts.spaceGrotesk(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.inter(
                color: themeNotifier.isDark ? Colors.white38 : Colors.black38,
                fontSize: 12)),
      ],
    );
  }
}
