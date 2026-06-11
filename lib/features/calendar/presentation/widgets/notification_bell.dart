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

    return IconButton(
      icon: countAsync.when(
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
    );
  }
}
