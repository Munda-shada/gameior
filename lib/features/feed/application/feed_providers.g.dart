// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedUpcomingGamesHash() => r'68be4bd2a5a749ac3ae1548f70fc82346fd82fa2';

/// All upcoming games across all the user's active groups, ordered by date.
/// Returns full game data including rsvps nested so we can show RSVP status.
///
/// Copied from [feedUpcomingGames].
@ProviderFor(feedUpcomingGames)
final feedUpcomingGamesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      feedUpcomingGames,
      name: r'feedUpcomingGamesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedUpcomingGamesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedUpcomingGamesRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$feedAnnouncementsHash() => r'e990038af00bfd0548c995a8c41e2c2dc5dc86c7';

/// Global announcements across all the user's active groups.
///
/// Copied from [feedAnnouncements].
@ProviderFor(feedAnnouncements)
final feedAnnouncementsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      feedAnnouncements,
      name: r'feedAnnouncementsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedAnnouncementsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedAnnouncementsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
