import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool isScrollControlled = true,
  double initialChildSizeRatio = 0.5, // 0.0 to 1.0
  double maxChildSizeRatio = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: initialChildSizeRatio,
      maxChildSize: maxChildSizeRatio,
      minChildSize: 0.3,
      builder: (_, controller) => AppBottomSheetContainer(
        title: title,
        scrollController: controller,
        child: child,
      ),
    ),
  );
}

class AppBottomSheetContainer extends StatelessWidget {
  final String? title;
  final ScrollController scrollController;
  final Widget child;

  const AppBottomSheetContainer({
    super.key,
    this.title,
    required this.scrollController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12.0),
          // Drag handle
          Container(
            height: 4.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 16.0),
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}