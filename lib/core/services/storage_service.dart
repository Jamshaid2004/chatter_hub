import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
