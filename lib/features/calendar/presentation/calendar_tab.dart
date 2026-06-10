import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/calendar/application/calendar_providers.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/notifications/application/notifications_providers.dart';
import 'package:gameior/features/notifications/presentation/widgets/notifications_sheet.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isListView = false;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          // View Toggle
          IconButton(
            icon: Icon(
              _isListView ? Icons.calendar_month : Icons.format_list_bulleted,
            ),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
          // Notification Bell
          IconButton(
            icon: ref.watch(unreadNotificationCountProvider).when(
                  data: (count) => Badge(
                    isLabelVisible: count > 0,
                    label: Text(count.toString()),
                    child: const Icon(Icons.notifications_none),
                  ),
                  loading: () => const Icon(Icons.notifications_none),
                  error: (_, __) => const Icon(Icons.notifications_none),
                ),
            onPressed: () {
              showAppBottomSheet(
                context: context,
                title: 'Notifications',
                initialChildSizeRatio: 0.75,
                child: const NotificationsSheet(),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading schedule:\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.destructive),
          ),
        ),
        data: (eventsMap) {
          if (_isListView) {
            return _buildContinuousList(eventsMap, currentUserId);
          }
          return Column(
            children: [
              _buildTableCalendar(eventsMap, currentUserId),
              const Divider(height: 1),
              Expanded(child: _buildSelectedDayGames(eventsMap, currentUserId)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCalendar(
    Map<DateTime, List<Map<String, dynamic>>> eventsMap,
    String? currentUserId,
  ) {
    final now = DateTime.now();
    return Container(
      color: AppColors.surface,
      child: TableCalendar(
        firstDay: DateTime(now.year, now.month - 2, 1),
        lastDay: DateTime(now.year, now.month + 3, 0),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) {
          // Normalize TableCalendar's day to our local DateTime keys
          final dateKey = DateTime(day.year, day.month, day.day);
          return eventsMap[dateKey] ?? [];
        },
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();

            final dayEvents = events.cast<Map<String, dynamic>>();

            return Positioned(
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: dayEvents.take(3).map((event) {
                  final rsvps = event['rsvps'] as List<dynamic>? ?? [];
                  final myRsvp = rsvps.whereType<Map<String, dynamic>>().firstWhere(
                        (r) => r['user_id'] == currentUserId,
                        orElse: () => <String, dynamic>{},
                      );

                  Color dotColor = Colors.grey; // Default: unanswered / maybe
                  if (myRsvp.isNotEmpty) {
                    final status = myRsvp['status'];
                    if (status == 'yes' || myRsvp['user_is_playing'] == true) {
                      dotColor = Colors.green;
                    } else if (status == 'waitlist') {
                      dotColor = Colors.orange;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayGames(Map<DateTime, List<Map<String, dynamic>>> eventsMap, String? currentUserId) {
    final dateKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayEvents = eventsMap[dateKey] ?? [];
    return _buildGamesList(dayEvents, currentUserId);
  }

  Widget _buildContinuousList(Map<DateTime, List<Map<String, dynamic>>> eventsMap, String? currentUserId) {
    final allEvents = eventsMap.values.expand((e) => e).toList();
    allEvents.sort((a, b) {
      final dateA = DateTime.parse(a['scheduled_at'] as String);
      final dateB = DateTime.parse(b['scheduled_at'] as String);
      return dateA.compareTo(dateB);
    });
    return _buildGamesList(allEvents, currentUserId);
  }

  Widget _buildGamesList(List<Map<String, dynamic>> games, String? currentUserId) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text('No games scheduled', style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.push('/home/groups'),
              child: const Text('Host a Game'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameEventTile(
          game: games[index],
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class GameEventTile extends StatelessWidget {
  final Map<String, dynamic> game;
  final String? currentUserId;

  const GameEventTile({super.key, required this.game, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final rsvps = game['rsvps'] as List<dynamic>? ?? [];
    final myRsvp = rsvps.whereType<Map<String, dynamic>>().firstWhere(
          (r) => r['user_id'] == currentUserId,
          orElse: () => <String, dynamic>{},
        );

    Color dotColor = Colors.grey;
    final status = myRsvp['status'];
    if (myRsvp.isNotEmpty) {
      if (status == 'yes' || myRsvp['user_is_playing'] == true) {
        dotColor = Colors.green;
      } else if (status == 'waitlist') {
        dotColor = Colors.orange;
      }
    }

    final waitlistPos = myRsvp['waitlist_position'];
    final rsvpLocked = game['rsvp_locked'] == true;
    final scheduledAt = game['scheduled_at'] != null 
        ? DateTime.parse(game['scheduled_at'] as String).toLocal() 
        : null;
    final timeString = scheduledAt != null 
        ? DateFormat('MMM d, yyyy • h:mm a').format(scheduledAt) 
        : 'TBD';

    final group = game['groups'] as Map<String, dynamic>? ?? {};
    final groupName = group['name'] ?? 'Unknown Group';
    final sportRaw = group['sport']?.toString() ?? 'sport';
    final sportName = sportRaw.isNotEmpty ? '${sportRaw[0].toUpperCase()}${sportRaw.substring(1)}' : 'Sport';

    final groupId = game['group_id'];
    final gameId = game['id'];
    
    final title = game['title']?.toString() ?? '';
    final displayTitle = title.isNotEmpty ? title : '$sportName Session';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          if (groupId != null && gameId != null) {
            context.push('/group/$groupId/game/$gameId');
          }
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: dotColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rsvpLocked)
                            const Padding(
                              padding: EdgeInsets.only(left: AppSpacing.xs),
                              child: Icon(Icons.lock, size: 16, color: Colors.grey),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        timeString,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.group, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              groupName,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (status == 'waitlist' && waitlistPos != null)
                            Container(
                              margin: const EdgeInsets.only(left: AppSpacing.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Waitlist #$waitlistPos',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}