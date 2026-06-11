import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/calendar/application/calendar_providers.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';

import 'package:gameior/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:gameior/features/calendar/presentation/widgets/schedule_list.dart';
import 'package:gameior/features/calendar/presentation/widgets/notification_bell.dart';

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
          const NotificationBell(),
          const SizedBox(width: AppSpacing.sm),
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
          if (_isListView) {
            final allEvents = eventsMap.values.expand((e) => e).toList();
            allEvents.sort((a, b) {
              final dateA = DateTime.parse(a['scheduled_at'] as String);
              final dateB = DateTime.parse(b['scheduled_at'] as String);
              return dateA.compareTo(dateB);
            });
            return ScheduleList(games: allEvents, currentUserId: currentUserId);
          }

          final dateKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          final dayEvents = eventsMap[dateKey] ?? [];

          return Column(
            children: [
              CalendarGrid(
                eventsMap: eventsMap,
                currentUserId: currentUserId,
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ScheduleList(games: dayEvents, currentUserId: currentUserId),
              ),
            ],
          );
        },
      ),
    );
  }
}