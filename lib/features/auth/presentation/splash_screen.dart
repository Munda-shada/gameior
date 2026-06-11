import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/auth/presentation/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Floating logo animation: 1.5s loop, bouncing between -8.0 and 8.0 pixels vertically
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);

    // Shimmer text sweep animation: 2.0s loop sweeping left to right
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _shimmerController.repeat();

    // 2-second timer to trigger the splash completed state for navigation
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(splashAnimationCompletedProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating app logo animation
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: const Text('🏸', style: TextStyle(fontSize: 72)),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Shimmering gradient text animation
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                final alignmentOffset = _shimmerController.value;
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(-2.0 + alignmentOffset * 4.0, -1.0),
                      end: Alignment(alignmentOffset * 4.0, 1.0),
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        theme.colorScheme.primary,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                  },
                  child: child,
                );
              },
              child: Text(
                'Gameior',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}