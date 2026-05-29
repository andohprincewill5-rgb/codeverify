import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/verification_service.dart';
import '../main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = VerificationService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _service.getScanHistory();
      setState(() {
        _history = history;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeNotifier.isDark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFF6B6B), size: 22),
            const SizedBox(width: 8),
            Text('Clear History',
                style: GoogleFonts.spaceGrotesk(
                    color: themeNotifier.isDark
                        ? Colors.white
                        : Colors.black87)),
          ],
        ),
        content: Text(
            'Are you sure you want to delete all ${_history.length} scan records? This cannot be undone.',
            style: GoogleFonts.inter(
                color: themeNotifier.isDark
                    ? Colors.white54
                    : Colors.black45)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.clearHistory();
              _loadHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ History cleared!',
                        style: GoogleFonts.inter()),
                    backgroundColor: const Color(0xFF1A1A2E),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Color _verdictColor(String verdict) {
    final v = verdict.toLowerCase();
    if (v.contains('legit') || v.contains('valid') || v.contains('appears')) {
      return const Color(0xFF00E5A0);
    } else if (v.contains('suspicious') ||
        v.contains('fake') ||
        v.contains('not legit') ||
        v.contains('invalid') ||
        v.contains('not secure')) {
      return const Color(0xFFFF6B6B);
    }
    return const Color(0xFFFFB800);
  }

  IconData _verdictIcon(String verdict) {
    final v = verdict.toLowerCase();
    if (v.contains('legit') || v.contains('valid') || v.contains('appears')) {
      return Icons.verified_rounded;
    } else if (v.contains('suspicious') ||
        v.contains('fake') ||
        v.contains('not legit') ||
        v.contains('not secure')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.help_outline_rounded;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
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
        title: Text('Scan History',
            style: GoogleFonts.spaceGrotesk(color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5A0)))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded,
                          color: isDark ? Colors.white24 : Colors.black12,
                          size: 64),
                      const SizedBox(height: 16),
                      Text('No scan history yet',
                          style: GoogleFonts.spaceGrotesk(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Start scanning codes to see history here',
                          style: GoogleFonts.inter(
                              color:
                                  isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                              label: 'Total Scans',
                              value: _history.length.toString(),
                              color: textColor,
                            ),
                            _StatItem(
                              label: 'Legit',
                              value: _history
                                  .where((h) =>
                                      _verdictColor(h['verdict'] ?? '') ==
                                      const Color(0xFF00E5A0))
                                  .length
                                  .toString(),
                              color: const Color(0xFF00E5A0),
                            ),
                            _StatItem(
                              label: 'Suspicious',
                              value: _history
                                  .where((h) =>
                                      _verdictColor(h['verdict'] ?? '') ==
                                      const Color(0xFFFF6B6B))
                                  .length
                                  .toString(),
                              color: const Color(0xFFFF6B6B),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Clear history button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                            side: const BorderSide(
                                color: Color(0xFFFF6B6B), width: 1),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _clearHistory,
                          icon: const Icon(Icons.delete_sweep_rounded,
                              size: 18),
                          label: Text('Clear All History',
                              style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _history.length,
                        itemBuilder: (ctx, i) {
                          final item = _history[i];
                          final verdict = item['verdict'] ?? 'Unknown';
                          final color = _verdictColor(verdict);
                          final icon = _verdictIcon(verdict);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: color.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['code_value'] ?? '',
                                        style: GoogleFonts.inter(
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(verdict,
                                              style: GoogleFonts.inter(
                                                  color: color,
                                                  fontSize: 12)),
                                          const SizedBox(width: 8),
                                          Text(
                                            '· ${_formatDate(item['created_at'])}',
                                            style: GoogleFonts.inter(
                                                color: isDark
                                                    ? Colors.white38
                                                    : Colors.black38,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(
                              delay: Duration(milliseconds: i * 50));
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
                color: themeNotifier.isDark
                    ? Colors.white38
                    : Colors.black38,
                fontSize: 12)),
      ],
    );
  }
}
