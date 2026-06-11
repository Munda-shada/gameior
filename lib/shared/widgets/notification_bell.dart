import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/features/notifications/application/notifications_providers.dart';
import 'package:gameior/features/notifications/presentation/widgets/notifications_sheet.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);

    return IconButton(
      icon: countAsync.when(
        data: (count) => Badge(
          isLabelVisible: count > 0,
          label: Text(count.toString()),
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          child: Icon(
            Icons.notifications_none,
            color: theme.colorScheme.onSurface,
          ),
        ),
        loading: () => Icon(
          Icons.notifications_none,
          color: theme.colorScheme.onSurface,
        ),
        error: (error, stackTrace) => Icon(
          Icons.notifications_none,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onPressed: () {
        showAppBottomSheet(
          context: context,
          title: 'Notifications',
          initialChildSizeRatio: 0.75,
          child: const NotificationsSheet(),
        );
      },
    );
  }
}
