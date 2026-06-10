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
      child: child ?? Container(height: 100, width: double.infinity, color: Colors.white),
    );
  }
}