import 'package:absen_sqflite/models/model_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userPassword', user.password);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<UserModel?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');
    final password = prefs.getString('userPassword');

    if (id != null && name != null && email != null && password != null) {
      return UserModel(id: id, name: name, email: email, password: password);
    }
    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ DITAMBAHKAN
  }
}
