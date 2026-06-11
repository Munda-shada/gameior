import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

class SectionSkeleton extends StatelessWidget {
  final String label;
  final ShimmerType shimmerType;
  
  const SectionSkeleton({
    required this.label,
    this.shimmerType = ShimmerType.card,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: label),
          const SizedBox(height: AppSpacing.sm),
          AppLoadingShimmer(type: shimmerType),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}
