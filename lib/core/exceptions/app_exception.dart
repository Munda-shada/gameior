import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  factory AppException.fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '42501'                        => const PermissionException(),
      '23505'                        => const DuplicateException(),
      'announcement_limit_reached'   => const AnnouncementLimitException(),
      'cost_item_limit_reached'      => const CostItemLimitException(),
      _                              => NetworkException(e.message),
    };
  }

  factory AppException.fromEdgeFunction(FunctionException e) {
    // Parse error code from Edge Function response body
    // Often e.details is a Map, but it can also be a String or null depending on how supabase_flutter behaves.
    Map<String, dynamic>? body;
    if (e.details is Map) {
      body = e.details as Map<String, dynamic>;
    } else if (e.details is String) {
      // In some versions, the body is a raw JSON string
      try {
        // We import dart:convert if we need, but for now we can fall back to standard mapping
      } catch (_) {}
    }
    
    return switch (body?['error']) {
      'capacity_full'         => const CapacityFullException(),
      'rsvp_locked'           => const RsvpLockedException(),
      'duplicate_utr'         => const DuplicateUtrException(),
      'groups_unresolved'     => const UnresolvedGroupsException(),
      'invalid_invite_code'   => const InvalidInviteCodeException(),
      'already_member'        => const AlreadyMemberException(),
      _                       => NetworkException(e.toString()),
    };
  }
}

class PermissionException extends AppException {
  const PermissionException() : super('You don\'t have permission to do this.');
}

class NetworkException extends AppException {
  const NetworkException([String m = 'Something went wrong.']) : super(m);
}

class DuplicateException extends AppException {
  const DuplicateException() : super('This already exists.');
}

class CapacityFullException extends AppException {
  const CapacityFullException() : super('This session is full.');
}

class RsvpLockedException extends AppException {
  const RsvpLockedException() : super('RSVP window is closed.');
}

class DuplicateUtrException extends AppException {
  const DuplicateUtrException() : super('You\'ve already submitted a reference for this game.');
}

class AnnouncementLimitException extends AppException {
  const AnnouncementLimitException() : super('Delete an announcement to post a new one (5/5).');
}

class UnresolvedGroupsException extends AppException {
  const UnresolvedGroupsException() : super('Resolve all your hosted groups before deleting your account.');
}

class CostItemLimitException extends AppException {
  const CostItemLimitException() : super('A game may have at most 5 cost items.');
}

class InvalidInviteCodeException extends AppException {
  const InvalidInviteCodeException() : super('This invite code is invalid.');
}

class AlreadyMemberException extends AppException {
  const AlreadyMemberException() : super('You\'re already in this group.');
}
