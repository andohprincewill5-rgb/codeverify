import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final _supabase = Supabase.instance.client;

  Future<void> registerPendingSubscription({
    required String email,
    required String plan,
    required int scansLimit,
  }) async {
    // Check if email already exists
    final existing = await _supabase
        .from('subscriptions')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      // Update existing subscription
      await _supabase.from('subscriptions').update({
        'plan': plan,
        'scans_limit': scansLimit,
        'activated': false,
      }).eq('email', email);
    } else {
      // Create new subscription
      await _supabase.from('subscriptions').insert({
        'email': email,
        'plan': plan,
        'scans_limit': scansLimit,
        'scans_used': 0,
        'activated': false,
      });
    }
  }

  Future<Map<String, dynamic>?> getSubscription(String email) async {
    final response = await _supabase
        .from('subscriptions')
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getAllSubscriptions() async {
    final response = await _supabase
        .from('subscriptions')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> activateSubscription(String email) async {
    final now = DateTime.now();
    final expires = DateTime(now.year, now.month + 1, now.day);
    await _supabase.from('subscriptions').update({
      'activated': true,
      'expires_at': expires.toIso8601String(),
    }).eq('email', email);
  }

  Future<void> deactivateSubscription(String email) async {
    await _supabase.from('subscriptions').update({
      'activated': false,
    }).eq('email', email);
  }
}
