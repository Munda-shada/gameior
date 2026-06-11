import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/calendar/application/calendar_providers.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';

import 'package:gameior/features/calendar/presentation/widgets/event_tile.dart';
import 'package:gameior/shared/widgets/notification_bell.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool _showNextWeek = false;
  String _rsvpFilter = 'All';

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final startMonday = _showNextWeek ? monday.add(const Duration(days: 7)) : monday;
    return List.generate(7, (i) => startMonday.add(Duration(days: i)));
  }

  void _setWeek(bool showNext) {
    if (_showNextWeek == showNext) return;
    setState(() {
      _showNextWeek = showNext;
      final currentWeekdayIndex = _selectedDay.weekday - 1; // 0 to 6
      final weekDays = _getWeekDays();
      _selectedDay = weekDays[currentWeekdayIndex];
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getWeekdayLetter(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday    => 'Mon',
      DateTime.tuesday   => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday  => 'Thu',
      DateTime.friday    => 'Fri',
      DateTime.saturday  => 'Sat',
      DateTime.sunday    => 'Sun',
      _                  => '',
    };
  }

  List<dynamic> _filterGames(List<dynamic> games, String? currentUserId) {
    if (_rsvpFilter == 'All') return games;

    return games.where((game) {
      final rsvps = game['rsvps'] as List<dynamic>? ?? [];
      final myRsvp = rsvps.whereType<Map<String, dynamic>>().firstWhere(
            (r) => r['user_id'] == currentUserId,
            orElse: () => <String, dynamic>{},
          );

      final status = myRsvp['status'];
      if (_rsvpFilter == 'Playing') {
        return myRsvp.isNotEmpty && (status == 'yes' || status == 'guest' || myRsvp['user_is_playing'] == true);
      } else if (_rsvpFilter == 'Maybe') {
        return myRsvp.isNotEmpty && (status == 'maybe' || status == 'waitlist');
      } else if (_rsvpFilter == 'No') {
        return myRsvp.isNotEmpty && status == 'no';
      }
      return false;
    }).toList();
  }

  Widget _buildWeekToggle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTogglePill(
              label: 'This Week',
              isActive: !_showNextWeek,
              onTap: () => _setWeek(false),
            ),
          ),
          Expanded(
            child: _buildTogglePill(
              label: 'Next Week',
              isActive: _showNextWeek,
              onTap: () => _setWeek(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePillScroller(List<DateTime> weekDays, Map<DateTime, List<dynamic>> eventsMap, String? currentUserId, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: weekDays.map((day) {
            final isSelected = _isSameDay(_selectedDay, day);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                width: 52,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getWeekdayLetter(day),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusDots(day, eventsMap, currentUserId, isSelected, theme),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusDots(DateTime day, Map<DateTime, List<dynamic>> eventsMap, String? currentUserId, bool isSelected, ThemeData theme) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final dayEvents = eventsMap[dateKey] ?? [];
    if (dayEvents.isEmpty) return const SizedBox(height: 4);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dayEvents.take(3).map((event) {
        final rsvps = event['rsvps'] as List<dynamic>? ?? [];
        final myRsvp = rsvps.whereType<Map<String, dynamic>>().firstWhere(
              (r) => r['user_id'] == currentUserId,
              orElse: () => <String, dynamic>{},
            );

        Color dotColor = isSelected ? theme.colorScheme.onSurface.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.4);
        if (myRsvp.isNotEmpty) {
          final status = myRsvp['status'];
          if (status == 'yes' || myRsvp['user_is_playing'] == true) {
            dotColor = isSelected ? theme.colorScheme.onSurface : theme.colorScheme.primary;
          } else if (status == 'waitlist') {
            dotColor = isSelected ? theme.colorScheme.tertiary : theme.colorScheme.tertiary;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.0),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterPills(ThemeData theme) {
    final filters = ['All', 'Playing', 'Maybe', 'No'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: filters.map((filter) {
          final isActive = _rsvpFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _rsvpFilter = filter;
                  });
                }
              },
              selectedColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isActive ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: isActive ? theme.colorScheme.secondary : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccordionDay({
    required DateTime day,
    required List<dynamic> games,
    required String? currentUserId,
    required ThemeData theme,
  }) {
    final isExpanded = _isSameDay(_selectedDay, day);
    final dayTitle = DateFormat('EEEE, MMM d').format(day);
    
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dayTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
                      color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: games.isNotEmpty
                        ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${games.length} ${games.length == 1 ? 'session' : 'sessions'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: games.isNotEmpty ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 4),
            child: games.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Center(
                      child: Text(
                        'No sessions scheduled',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: games.map((game) {
                      return GameEventTile(
                        game: game,
                        currentUserId: currentUserId,
                      );
                    }).toList(),
                  ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: const [
          NotificationBell(),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                AppLoadingShimmer(type: ShimmerType.gameCard),
                SizedBox(height: AppSpacing.base),
                AppLoadingShimmer(type: ShimmerType.gameCard),
              ],
            ),
          ),
        ),
        error: (err, stack) => AppErrorState(
          message: 'Error loading schedule: $err',
          onRetry: () => ref.invalidate(calendarEventsProvider),
        ),
        data: (eventsMap) {
          final weekDays = _getWeekDays();
          
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(calendarEventsProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: AppSpacing.sm),
                _buildWeekToggle(theme),
                const SizedBox(height: AppSpacing.xs),
                _buildDatePillScroller(weekDays, eventsMap, currentUserId, theme),
                const SizedBox(height: AppSpacing.xs),
                _buildFilterPills(theme),
                const SizedBox(height: AppSpacing.xs),
                ...weekDays.map((day) {
                  final dateKey = DateTime(day.year, day.month, day.day);
                  final rawGames = eventsMap[dateKey] ?? [];
                  final filteredGames = _filterGames(rawGames, currentUserId);
                  return _buildAccordionDay(
                    day: day,
                    games: filteredGames,
                    currentUserId: currentUserId,
                    theme: theme,
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}