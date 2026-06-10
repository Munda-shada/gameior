import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(supabaseClientProvider));
});

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => message;
}

class PaymentsRepository {
  final SupabaseClient _client;
  PaymentsRepository(this._client);

  // ─── ADMIN ───────────────────────────────────────────

  /// Fetch all dues for games created by the caller.
  /// Scoped by payment_owner_id = caller. RLS also enforces this.
  Future<List<PaymentDue>> fetchDuesAsOwner({
    required String groupId,
  }) async {
    final response = await _client
        .from('payment_dues')
        .select('''
          *,
          profiles:player_id (display_name, emoji)
        ''')
        .eq('group_id', groupId)
        .eq('payment_owner_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PaymentDue.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Approve a UTR submission
  Future<void> approveDue(String dueId) async {
    await _client.from('payment_dues').update({
      'status':      'paid',
      'verified_at': DateTime.now().toUtc().toIso8601String(),
      'verified_by': _client.auth.currentUser!.id,
      'updated_at':  DateTime.now().toUtc().toIso8601String(),
    }).eq('id', dueId)
      .eq('payment_owner_id', _client.auth.currentUser!.id); // safety check
  }

  /// Reject a UTR submission — reverts to unpaid
  Future<void> rejectDue(String dueId) async {
    final callerId = _client.auth.currentUser!.id;
    try {
      // 1. Try with RPC increment
      await _client.from('payment_dues').update({
        'status':           'unpaid',
        'utr_reference':    null,
        'submitted_at':     null,
        'verified_by':      callerId,
        'rejection_count':  _client.rpc('increment', params: {
          'table': 'payment_dues', 'field': 'rejection_count', 'id': dueId
        }),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', dueId)
        .eq('payment_owner_id', callerId);
    } catch (e) {
      // 2. Fallback: Fetch current rejection_count, increment locally, and update
      final due = await _client.from('payment_dues').select('rejection_count').eq('id', dueId).single();
      final currentRejections = (due['rejection_count'] as num?)?.toInt() ?? 0;
      await _client.from('payment_dues').update({
        'status':           'unpaid',
        'utr_reference':    null,
        'submitted_at':     null,
        'verified_by':      callerId,
        'rejection_count':  currentRejections + 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', dueId)
        .eq('payment_owner_id', callerId);
    }
  }

  /// Mark due as paid manually (admin override, no UTR needed)
  Future<void> markAsPaid(String dueId) async {
    await _client.from('payment_dues').update({
      'status':      'paid',
      'verified_at': DateTime.now().toUtc().toIso8601String(),
      'verified_by': _client.auth.currentUser!.id,
      'updated_at':  DateTime.now().toUtc().toIso8601String(),
    }).eq('id', dueId)
      .eq('payment_owner_id', _client.auth.currentUser!.id);
  }

  /// Toggle auto-approve setting on the group
  Future<void> setAutoApprove({
    required String groupId,
    required bool enabled,
  }) async {
    await _client.from('groups').update({
      'auto_approve_payments': enabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', groupId);
  }

  // ─── PLAYER ──────────────────────────────────────────

  /// Fetch the caller's own dues in a group
  Future<List<PaymentDue>> fetchMyDues({required String groupId}) async {
    final response = await _client
        .from('payment_dues')
        .select('''
          *,
          games (title, scheduled_at, upi_id, payment_owner_id)
        ''')
        .eq('group_id', groupId)
        .eq('player_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PaymentDue.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Submit a UTR reference for a due
  Future<void> submitUtr({
    required String dueId,
    required String utrReference,
  }) async {
    // Validate 12-digit numeric
    if (!RegExp(r'^\d{12}$').hasMatch(utrReference)) {
      throw const ValidationException('Enter a valid 12-digit reference number.');
    }

    final userId = _client.auth.currentUser!.id;

    // Check group auto-approve settings
    final dueData = await _client
        .from('payment_dues')
        .select('group_id, groups(auto_approve_payments)')
        .eq('id', dueId)
        .single();
    
    final groupsMap = dueData['groups'] as Map<String, dynamic>?;
    final autoApprove = groupsMap?['auto_approve_payments'] as bool? ?? false;

    if (autoApprove) {
      await _client.from('payment_dues').update({
        'status':        'paid',
        'utr_reference': utrReference,
        'submitted_at':  DateTime.now().toUtc().toIso8601String(),
        'verified_at':   DateTime.now().toUtc().toIso8601String(),
        'verified_by':   userId,
        'updated_at':    DateTime.now().toUtc().toIso8601String(),
      }).eq('id', dueId)
        .eq('player_id', userId)
        .eq('status', 'unpaid');
    } else {
      await _client.from('payment_dues').update({
        'status':        'pending_verification',
        'utr_reference': utrReference,
        'submitted_at':  DateTime.now().toUtc().toIso8601String(),
        'updated_at':    DateTime.now().toUtc().toIso8601String(),
      }).eq('id', dueId)
        .eq('player_id', userId)
        .eq('status', 'unpaid');
    }
  }
}
