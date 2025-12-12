import 'package:shared_preferences/shared_preferences.dart';

/// Shared Pref service
class SharedPref {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save a value to SharedPreferences
  Future<bool> saveValue(String key, dynamic value) async {
    if (_preferences == null) {
      await init();
    }

    if (value is String) {
      return await _preferences!.setString(key, value);
    } else if (value is int) {
      return await _preferences!.setInt(key, value);
    } else if (value is double) {
      return await _preferences!.setDouble(key, value);
    } else if (value is bool) {
      return await _preferences!.setBool(key, value);
    } else if (value is List<String>) {
      return await _preferences!.setStringList(key, value);
    } else {
      throw Exception('Unsupported value type');
    }
  }

  bool hasValue(String key) {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _preferences!.containsKey(key);
  }

  /// Retrieve a value from SharedPreferences
  dynamic getValue(String key) {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _preferences!.get(key);
  }

  /// Remove a value from SharedPreferences
  Future<bool> removeValue(String key) async {
    if (_preferences == null) {
      await init();
    }
    return await _preferences!.remove(key);
  }

  /// Clear all values from SharedPreferences
  Future<bool> clearAll() async {
    if (_preferences == null) {
      await init();
    }
    return await _preferences!.clear();
  }
}
