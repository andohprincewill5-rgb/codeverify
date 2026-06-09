import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class DeviceService {
  final _supabase = Supabase.instance.client;

  // Generate a random unique device ID
  String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (i) => chars[random.nextInt(chars.length)]).join();
  }

  // Get or create device ID stored in Supabase
  Future<Map<String, dynamic>> getOrCreateDevice(String deviceId) async {
    try {
      final existing = await _supabase
          .from('device_usage')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      if (existing != null) return existing;

      // Create new device
      await _supabase.from('device_usage').insert({
        'device_id': deviceId,
        'scans_used': 0,
        'plan': 'free',
        'scans_limit': 15,
        'activated': false,
      });

      final newDevice = await _supabase
          .from('device_usage')
          .select()
          .eq('device_id', deviceId)
          .single();

      return newDevice;
    } catch (e) {
      throw Exception('Device service error: $e');
    }
  }

  Future<bool> canScan(String deviceId) async {
    try {
      final device = await getOrCreateDevice(deviceId);
      final scansUsed = device['scans_used'] as int? ?? 0;
      final scansLimit = device['scans_limit'] as int? ?? 15;
      final plan = device['plan'] as String? ?? 'free';

      // Unlimited for pro and business
      if (plan == 'pro' || plan == 'business') return true;

      return scansUsed < scansLimit;
    } catch (e) {
      return true; // Allow scan if error
    }
  }

  Future<void> incrementScan(String deviceId) async {
    try {
      final device = await getOrCreateDevice(deviceId);
      final scansUsed = device['scans_used'] as int? ?? 0;
      await _supabase
          .from('device_usage')
          .update({'scans_used': scansUsed + 1})
          .eq('device_id', deviceId);
    } catch (e) {
      // Silently fail
    }
  }

  Future<Map<String, dynamic>> getDeviceStats(String deviceId) async {
    return await getOrCreateDevice(deviceId);
  }

  Future<void> upgradePlan(String deviceId, String plan) async {
    int limit;
    switch (plan) {
      case 'basic':
        limit = 500;
        break;
      case 'pro':
      case 'business':
        limit = 999999;
        break;
      default:
        limit = 15;
    }
    await _supabase.from('device_usage').update({
      'plan': plan,
      'scans_limit': limit,
      'activated': true,
    }).eq('device_id', deviceId);
  }
}
