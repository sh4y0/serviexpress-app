import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsConfig {
  static Future<void> initialize(VoidCallback runAppCallback) async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    runZonedGuarded(
      () {
        runAppCallback();
      },
      (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        );
      },
    );
  }

  static Future<void> logNonFatalError(
    dynamic error,
    StackTrace stackTrace,
  ) async {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }

  static void forceCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
