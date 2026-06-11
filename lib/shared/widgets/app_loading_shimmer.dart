import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerType { card, listTile, gameCard, memberRow, paymentRow }

class AppLoadingShimmer extends StatelessWidget {
  final Widget? child;
  final ShimmerType type;

  const AppLoadingShimmer({
    super.key,
    this.child,
    this.type = ShimmerType.card,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;
    final baseColor = surfaceColor.withValues(alpha: 0.6);
    final highlightColor = surfaceColor.withValues(alpha: 0.2);
    final skeletonColor = surfaceColor;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child ?? _buildSkeleton(skeletonColor),
    );
  }

  Widget _buildSkeleton(Color skeletonColor) {
    switch (type) {
      case ShimmerType.card:
        return Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ShimmerType.listTile:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 12, color: skeletonColor),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 10, color: skeletonColor),
                  ],
                ),
              ),
            ],
          ),
        );
      case ShimmerType.gameCard:
        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 140, height: 14, color: skeletonColor),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: skeletonColor),
                    const SizedBox(height: 6),
                    Container(width: 180, height: 10, color: skeletonColor),
                    const Spacer(),
                    Container(width: double.infinity, height: 6, color: skeletonColor),
                  ],
                ),
              ),
            ],
          ),
        );
      case ShimmerType.memberRow:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, color: skeletonColor),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 10, color: skeletonColor),
                  ],
                ),
              ),
              Container(width: 50, height: 16, color: skeletonColor),
            ],
          ),
        );
      case ShimmerType.paymentRow:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 12, color: skeletonColor),
                    const SizedBox(height: 6),
                    Container(width: 130, height: 10, color: skeletonColor),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 40, height: 12, color: skeletonColor),
                  const SizedBox(height: 6),
                  Container(width: 60, height: 14, color: skeletonColor),
                ],
              ),
            ],
          ),
        );
    }
  }
}