import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/verification_service.dart';
import '../services/code_analyzer.dart';

class ResultScreen extends StatefulWidget {
  final String scannedCode;
  const ResultScreen({super.key, required this.scannedCode});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _service = VerificationService();
  VerificationResult? _result;
  CodeAnalysis? _analysis;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    try {
      final result = await _service.verifyCode(widget.scannedCode);
      CodeAnalysis? analysis;
      String verdict;

      if (!result.found) {
        analysis = CodeAnalyzer.analyze(widget.scannedCode);
        verdict = analysis.verdict;
      } else if (result.isLegit == true) {
        verdict = 'Verified Legit';
      } else {
        verdict = 'Not Legitimate';
      }

      // Log the scan to history
      await _service.logScan(
        codeValue: widget.scannedCode,
        verdict: verdict,
      );

      setState(() {
        _result = result;
        _analysis = analysis;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('Verification Result',
            style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5A0)))
            : _error != null
                ? _buildError()
                : _buildResult(),
      ),
    );
  }

  Widget _buildResult() {
    final result = _result!;

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext;
    bool showAnalysis = false;

    if (!result.found && _analysis != null) {
      showAnalysis = true;
      if (_analysis!.isLegit) {
        statusColor = const Color(0xFF00E5A0);
        statusIcon = Icons.verified_rounded;
        statusText = _analysis!.verdict;
        statusSubtext = _analysis!.reason;
      } else {
        statusColor = const Color(0xFFFF6B6B);
        statusIcon = Icons.warning_amber_rounded;
        statusText = _analysis!.verdict;
        statusSubtext = _analysis!.reason;
      }
    } else if (!result.found) {
      statusColor = const Color(0xFFFFB800);
      statusIcon = Icons.help_outline_rounded;
      statusText = 'Unknown Code';
      statusSubtext = 'This code was not found in the registry.';
    } else if (result.isLegit == true) {
      statusColor = const Color(0xFF00E5A0);
      statusIcon = Icons.verified_rounded;
      statusText = 'Verified Legit';
      statusSubtext = 'This code is authentic and from a trusted source.';
    } else {
      statusColor = const Color(0xFFFF6B6B);
      statusIcon = Icons.dangerous_rounded;
      statusText = 'Not Legitimate';
      statusSubtext = 'This code has been flagged as fake or invalid.';
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Icon(statusIcon, color: statusColor, size: 60),
          ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 500.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  color: statusColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w700))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(statusSubtext,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 15))
              .animate()
              .fadeIn(delay: 400.ms),
          if (showAnalysis) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Text(
                'Auto-analyzed · ${(_analysis!.confidence * 100).toInt()}% confidence',
                style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ).animate().fadeIn(delay: 450.ms),
          ],
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code Details',
                    style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _ClickableDetailRow(
                    label: 'Code Value', value: widget.scannedCode),
                if (result.found) ...[
                  const SizedBox(height: 10),
                  _DetailRow(
                      label: 'Type', value: result.codeType ?? 'N/A'),
                  const SizedBox(height: 10),
                  _DetailRow(
                      label: 'Source', value: result.source ?? 'N/A'),
                ],
                if (showAnalysis) ...[
                  const SizedBox(height: 10),
                  _DetailRow(
                      label: 'Analysis', value: 'Auto (not in registry)'),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
          const SizedBox(height: 24),
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text('Scan Another',
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFFFF6B6B), size: 64),
          const SizedBox(height: 16),
          Text('Connection Error',
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontSize: 20)),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _verify();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}

class _ClickableDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _ClickableDetailRow({required this.label, required this.value});

  bool get _isUrl =>
      value.startsWith('http://') || value.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
        Expanded(
          child: _isUrl
              ? GestureDetector(
                  onTap: () => launchUrl(Uri.parse(value),
                      mode: LaunchMode.externalApplication),
                  child: Text(value,
                      style: GoogleFonts.inter(
                          color: const Color(0xFF00E5A0),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF00E5A0))),
                )
              : Text(value,
                  style:
                      GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}
