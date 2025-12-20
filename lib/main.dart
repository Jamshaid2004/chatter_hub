import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/app.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/status/screen/status_cleanup_service.dart';
import 'package:flutter_chatter_hub/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before using any Firebase services
  try {
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    ).then(
      (app) {
        print('✅ Firebase initialized: ${app.name}');
        print('Project ID: ${app.options.projectId}');
      },
      onError: (e) {
        debugPrint('❌ Firebase initialization error: $e');
      },
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

    await initializeDependencies();
    StatusCleanupService.start();
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  runApp(const ChatterHub());
}
