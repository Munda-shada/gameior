import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gameior/core/theme/app_colors.dart';

class CalendarGrid extends StatelessWidget {
  final Map<DateTime, List<Map<String, dynamic>>> eventsMap;
  final String? currentUserId;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarGrid({
    required this.eventsMap,
    required this.currentUserId,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: AppColors.surface,
      child: TableCalendar(
        firstDay: DateTime(now.year, now.month - 2, 1),
        lastDay: DateTime(now.year, now.month + 3, 0),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
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
}
