import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationResult {
  final bool found;
  final bool? isLegit;
  final String? codeType;
  final String? source;

  VerificationResult({
    required this.found,
    this.isLegit,
    this.codeType,
    this.source,
  });
}

class VerificationService {
  final _supabase = Supabase.instance.client;

  Future<VerificationResult> verifyCode(String codeValue) async {
    try {
      final response = await _supabase
          .from('codes')
          .select()
          .eq('code_value', codeValue)
          .maybeSingle();

      if (response == null) {
        return VerificationResult(found: false);
      }

      return VerificationResult(
        found: true,
        isLegit: response['is_legit'] as bool?,
        codeType: response['code_type'] as String?,
        source: response['source'] as String?,
      );
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<void> addCode({
    required String codeValue,
    required String codeType,
    required bool isLegit,
    required String source,
  }) async {
    await _supabase.from('codes').insert({
      'code_value': codeValue,
      'code_type': codeType,
      'is_legit': isLegit,
      'source': source,
    });
  }

  Future<List<Map<String, dynamic>>> getAllCodes() async {
    final response = await _supabase
        .from('codes')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteCode(int id) async {
    await _supabase.from('codes').delete().eq('id', id);
  }

  Future<void> logScan({
    required String codeValue,
    required String verdict,
  }) async {
    await _supabase.from('scan_history').insert({
      'code_value': codeValue,
      'verdict': verdict,
    });
  }

  Future<List<Map<String, dynamic>>> getScanHistory() async {
    final response = await _supabase
        .from('scan_history')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> clearHistory() async {
    await _supabase.from('scan_history').delete().neq('id', 0);
  }

  Future<bool> verifyAdminPassword(String password) async {
    try {
      final response = await _supabase
          .from('settings')
          .select()
          .eq('key', 'admin_password')
          .maybeSingle();

      if (response == null) return false;
      return response['value'] == password;
    } catch (e) {
      return false;
    }
  }
}
