import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemePreference _themePreference = ThemePreference.system;
  
  ThemeMode get themeMode => _themeMode;
  ThemePreference get themePreference => _themePreference;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefString = prefs.getString('theme_preference') ?? 'system';
      
      _themePreference = ThemePreference.values.firstWhere(
        (e) => e.toString().split('.').last == prefString,
        orElse: () => ThemePreference.system,
      );
      
      _setThemeMode(_themePreference);
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
      // Default to system theme if there's an error
      _themePreference = ThemePreference.system;
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    if (_themePreference == preference) return;
    
    _themePreference = preference;
    _setThemeMode(preference);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preference', preference.toString().split('.').last);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
    
    notifyListeners();
  }

  void _setThemeMode(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        _themeMode = ThemeMode.light;
        break;
      case ThemePreference.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemePreference.system:
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }
}

