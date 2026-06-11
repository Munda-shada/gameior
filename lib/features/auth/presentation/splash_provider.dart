import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track whether the splash screen animation has finished.
/// This acts as a guard for the router redirect logic, ensuring the splash
/// screen displays for at least the specified duration.
final splashAnimationCompletedProvider = StateProvider<bool>((ref) => false);
