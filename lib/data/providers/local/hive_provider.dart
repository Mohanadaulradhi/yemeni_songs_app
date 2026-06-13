import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class HiveProvider {
  HiveProvider._();

  static const String _userBoxName = 'user_box';
  static const String _songsBoxName = 'songs_box';
  static const String _settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_songsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  static Box get _userBox => Hive.box(_userBoxName);
  static Box get _songsBox => Hive.box(_songsBoxName);
  static Box get _settingsBox => Hive.box(_settingsBoxName);

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _userBox.put('current_user', jsonEncode(user));
  }

  static Map<String, dynamic>? getUser() {
    final raw = _userBox.get('current_user');
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    return null;
  }

  static Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  static Future<void> saveToken(String token) async {
    await _settingsBox.put('auth_token', token);
  }

  static String? getToken() {
    return _settingsBox.get('auth_token');
  }

  static Future<void> clearToken() async {
    await _settingsBox.delete('auth_token');
  }

  static Future<void> saveOfflineSong(String songId, Map<String, dynamic> data) async {
    await _songsBox.put(songId, jsonEncode(data));
  }

  static Map<String, dynamic>? getOfflineSong(String songId) {
    final raw = _songsBox.get(songId);
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    return null;
  }

  static List<Map<String, dynamic>> getAllOfflineSongs() {
    return _songsBox.values
        .whereType<String>()
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> removeOfflineSong(String songId) async {
    await _songsBox.delete(songId);
  }

  static Future<void> clearAll() async {
    await _userBox.clear();
    await _songsBox.clear();
    await _settingsBox.clear();
  }
}
