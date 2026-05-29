import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../services/verification_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _service = VerificationService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _codes = [];
  List<Map<String, dynamic>> _filteredCodes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCodes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCodes = _codes.where((code) {
        final value = (code['code_value'] ?? '').toLowerCase();
        final type = (code['code_type'] ?? '').toLowerCase();
        final source = (code['source'] ?? '').toLowerCase();
        return value.contains(query) ||
            type.contains(query) ||
            source.contains(query);
      }).toList();
    });
  }

  Future<void> _loadCodes() async {
    try {
      final codes = await _service.getAllCodes();
      setState(() {
        _codes = codes;
        _filteredCodes = codes;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading codes: $e')));
      }
    }
  }

  void _exportToCSV() {
    if (_codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No codes to export!')));
      return;
    }

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('ID,Code Value,Code Type,Is Legit,Source,Created At');
    for (final code in _codes) {
      final id = code['id'] ?? '';
      final value = (code['code_value'] ?? '').toString().replaceAll(',', ';');
      final type = (code['code_type'] ?? '').toString().replaceAll(',', ';');
      final isLegit = (code['is_legit'] == true) ? 'Yes' : 'No';
      final source = (code['source'] ?? '').toString().replaceAll(',', ';');
      final createdAt = code['created_at'] ?? '';
      buffer.writeln('$id,$value,$type,$isLegit,$source,$createdAt');
    }

    // Download the file in browser
    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'codeverify_codes.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ CSV exported successfully!')));
  }

  void _showAddCodeDialog() {
    final codeController = TextEditingController();
    final typeController = TextEditingController();
    final sourceController = TextEditingController();
    bool isLegit = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text('Add New Code',
              style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(codeController, 'Code Value', 'Enter the code'),
                const SizedBox(height: 12),
                _buildTextField(
                    typeController, 'Code Type', 'e.g. QR, barcode, license'),
                const SizedBox(height: 12),
                _buildTextField(
                    sourceController, 'Source', 'Where is this code from?'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Is Legit?',
                        style: GoogleFonts.inter(color: Colors.white70)),
                    const Spacer(),
                    Switch(
                      value: isLegit,
                      activeColor: const Color(0xFF00E5A0),
                      onChanged: (v) => setDialogState(() => isLegit = v),
                    ),
                    Text(isLegit ? 'Yes' : 'No',
                        style: GoogleFonts.inter(
                            color: isLegit
                                ? const Color(0xFF00E5A0)
                                : const Color(0xFFFF6B6B))),
                  ],
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5A0),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (codeController.text.trim().isEmpty) return;
                try {
                  await _service.addCode(
                    codeValue: codeController.text.trim(),
                    codeType: typeController.text.trim().isEmpty
                        ? 'Unknown'
                        : typeController.text.trim(),
                    isLegit: isLegit,
                    source: sourceController.text.trim().isEmpty
                        ? 'Unknown'
                        : sourceController.text.trim(),
                  );
                  Navigator.pop(ctx);
                  _searchController.clear();
                  _loadCodes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Code added successfully!')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Add Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00E5A0), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('Admin Panel',
            style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export to CSV',
            onPressed: _exportToCSV,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _searchController.clear();
              _loadCodes();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCodeDialog,
        backgroundColor: const Color(0xFF00E5A0),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Code',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5A0)))
          : Column(
              children: [
                // Stats bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: _codes.length.toString(),
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Legit',
                        value: _codes
                            .where((c) => c['is_legit'] == true)
                            .length
                            .toString(),
                        color: const Color(0xFF00E5A0),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Fake',
                        value: _codes
                            .where((c) => c['is_legit'] == false)
                            .length
                            .toString(),
                        color: const Color(0xFFFF6B6B),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by code, type or source...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white38),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: Colors.white38),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF00E5A0), width: 2),
                      ),
                    ),
                  ),
                ),

                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_filteredCodes.length} result${_filteredCodes.length == 1 ? '' : 's'} found',
                        style: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                Expanded(
                  child: _filteredCodes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.inbox_rounded,
                                color: Colors.white24,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'No codes match your search'
                                    : 'No codes yet',
                                style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white54, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'Try a different search term'
                                    : 'Tap + Add Code to get started',
                                style:
                                    GoogleFonts.inter(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _filteredCodes.length,
                          itemBuilder: (ctx, i) {
                            final code = _filteredCodes[i];
                            final isLegit =
                                code['is_legit'] as bool? ?? false;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLegit
                                      ? const Color(0xFF00E5A0)
                                          .withOpacity(0.3)
                                      : const Color(0xFFFF6B6B)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isLegit
                                        ? Icons.verified_rounded
                                        : Icons.dangerous_rounded,
                                    color: isLegit
                                        ? const Color(0xFF00E5A0)
                                        : const Color(0xFFFF6B6B),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          code['code_value'] ?? '',
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${code['code_type'] ?? 'Unknown'} · ${code['source'] ?? 'Unknown'}',
                                          style: GoogleFonts.inter(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white38),
                                    onPressed: () async {
                                      await _service
                                          .deleteCode(code['id'] as int);
                                      _searchController.clear();
                                      _loadCodes();
                                    },
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}