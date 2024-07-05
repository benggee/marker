import 'package:shared_preferences/shared_preferences.dart';

class BarcodeContent {
  BarcodeContent._privateConstructor();

  static final BarcodeContent _instance = BarcodeContent._privateConstructor();

  static BarcodeContent get instance => _instance;

  Future<String?> getContent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(id);
  }

  Future<void> saveContent(String id, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(id, content);
  }
}