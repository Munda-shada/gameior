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
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child ?? _buildSkeleton(),
    );
  }

  Widget _buildSkeleton() {
    switch (type) {
      case ShimmerType.card:
        return Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 10, color: Colors.white),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 140, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 180, height: 10, color: Colors.white),
                    const Spacer(),
                    Container(width: double.infinity, height: 6, color: Colors.white),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 10, color: Colors.white),
                  ],
                ),
              ),
              Container(width: 50, height: 16, color: Colors.white),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 130, height: 10, color: Colors.white),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 40, height: 12, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 60, height: 14, color: Colors.white),
                ],
              ),
            ],
          ),
        );
    }
  }
}