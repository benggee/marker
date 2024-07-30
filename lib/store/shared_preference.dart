

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  SharedPreference._privateConstructor();

  static final SharedPreference _instance = SharedPreference._privateConstructor();

  static SharedPreference get instance => _instance;

  Future<String?> getContent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(id);
  }

  Future<void> saveContent(String id, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(id, content);
  }
}