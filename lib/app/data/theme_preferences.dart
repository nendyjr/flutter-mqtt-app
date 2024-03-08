import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  final themePreferencesKey = "THEME_MODE_KEY";
  void saveTheme(String themeMode) async {
    if (themeMode.isEmpty) {
      _deleteTheme();
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(themePreferencesKey, themeMode);
  }

  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themePreferencesKey);
  }

  Future<bool> _deleteTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(themePreferencesKey);
  }
}
