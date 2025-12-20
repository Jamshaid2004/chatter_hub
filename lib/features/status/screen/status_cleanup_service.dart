import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';

/// Service to periodically clean up expired statuses
class StatusCleanupService {
  static Timer? _cleanupTimer;

  /// Start the cleanup service
  static void start() {
    // Run cleanup immediately on start
    _runCleanup();

    // Then run every hour
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _runCleanup(),
    );

    debugPrint('✅ Status cleanup service started');
  }

  /// Stop the cleanup service
  static void stop() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    debugPrint('🛑 Status cleanup service stopped');
  }

  /// Run the cleanup operation
  static Future<void> _runCleanup() async {
    try {
      debugPrint('🧹 Running status cleanup...');
      await injector<FirebaseFirestoreService>().deleteExpiredStatuses();
      debugPrint('✅ Status cleanup completed');
    } catch (e) {
      debugPrint('❌ Status cleanup failed: $e');
    }
  }
}

// HOW TO USE:
// Add this line in your main.dart, after initializeDependencies():
// StatusCleanupService.start();
