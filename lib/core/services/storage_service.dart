import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ---------------------------
  /// Upload a new image
  /// ---------------------------
  Future<String?> uploadImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');

      final uploadTask = await ref.putFile(File(filePath));

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print(" Upload Error: $e");
      return null;
    }
  }

// Add these methods to your FirebaseStorageService class

  /// Upload group icon
  Future<String> uploadGroupIcon(File file, String groupId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'group_icon_${groupId}_$timestamp.jpg';
      final ref = _storage.ref().child('groups/$groupId/icon/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Group icon uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading group icon: $e');
      rethrow;
    }
  }

  /// Upload group media (images/videos)
  Future<String> uploadGroupMedia({
    required File file,
    required String groupId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = 'media_${timestamp}.$extension';
      final ref = _storage.ref().child('groups/$groupId/media/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Group media uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading group media: $e');
      rethrow;
    }
  }
// Add this method to your FirebaseStorageService class

  /// Upload status image
  Future<String> uploadStatusImage(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'status_${userId}_$timestamp.jpg';
      final ref = _storage.ref().child('statuses/$userId/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Status image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading status image: $e');
      rethrow;
    }
  }

  Future<String> uploadChatMedia({
    required File file,
    required String chatId,
  }) async {
    final ext = file.path.split('.').last;
    final id = const Uuid().v4();

    final ref = _storage.ref("chats/$chatId/$id.$ext");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// ---------------------------
  /// Update existing image (delete → upload)
  /// ---------------------------
  Future<String?> updateImage({
    required String newFilePath,
    required String userId,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');

      // Delete old file if it exists
      await _safeDelete(ref);

      // Upload new file
      final uploadTask = await ref.putFile(File(newFilePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print(" Update Error: $e");
      return null;
    }
  }

  /// ---------------------------
  /// Delete image
  /// ---------------------------
  Future<bool> deleteImage(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      print(" Delete Error: $e");
      return false;
    }
  }

  /// ---------------------------
  /// Get download URL if exists
  /// ---------------------------
  Future<String?> getImageUrl(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print("⚠ No image found: $e");
      return null;
    }
  }

  /// ---------------------------
  /// Private Safe Delete
  /// ---------------------------
  Future<void> _safeDelete(Reference ref) async {
    try {
      await ref.delete();
    } catch (_) {
      // Ignore errors — file may not exist
    }
  }
}
