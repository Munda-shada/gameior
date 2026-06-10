import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/supabase/supabase_client.dart';
import 'core/firebase/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  try {
    await Firebase.initializeApp();
    
    // Set up Crashlytics
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    print("⚠️ Firebase initialization failed: $e");
  }

  final container = ProviderContainer();
  try {
    await container.read(fcmServiceProvider).init();
  } catch (e) {
    print("⚠️ FcmService initialization failed: $e");
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const GameiorApp(),
  ));
}