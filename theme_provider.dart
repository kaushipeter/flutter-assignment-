
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:light_sensor/light_sensor.dart'; // Added dependency

/*
 * Implemented by: Antigravity (AI Assistant)
 * 
 * Purpose: Dynamic Theme State Management
 * 
 * Library Used: Provider (ChangeNotifier)
 * 
 * Why: 
 * We need to switch between Light, Dark, and Eye-Friendly modes dynamically.
 * Provider allows the MaterialApp at the root to listen to these changes and 
 * hot-swap the entire app's theme (colors, fonts) in real-time based on 
 * user preference or sensor data (Ambient Light).
 */
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
    initLightSensor(); // Start listening to ambient light
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveTheme();
  }
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('is_dark_mode')) {
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
  // Light Sensor
  bool _isEyeFriendly = false;
  bool get isEyeFriendly => _isEyeFriendly;

  // Stream Subscription for Light Sensor
  // We need to cancel this when not needed, but for this app it's always on
  // In a real app, you might want to pause this stream when app is paused
  // or only enable it based on a user setting.
  void initLightSensor() {
    // Check if the platform supports sensors (Mobile only usually)
    // For web/desktop this might throw or do nothing
    if (kIsWeb) return; // Skip on web

    try {
      // Import dynamically or check platform if needed, but package usually handles safe fail
       LightSensor.luxStream().listen((lux) {
        // Threshold Logic:
        // If lux is low (example: < 20 lux) -> enable Eye-Friendly Mode
        // warm/yellow background
        // dark text that’s still readable
        // reduce harsh white/blue tones
        if (lux < 20 && !_isEyeFriendly && !_manualOverride) {
           _isEyeFriendly = true;
           notifyListeners();
        } 
        // If lux is high -> normal theme (revert to user preference)
        else if (lux >= 20 && _isEyeFriendly && !_manualOverride) {
           _isEyeFriendly = false;
           notifyListeners();
        }
      });
    } catch (e) {
      print('Light Sensor initialization failed (likely not on mobile): $e');
    }
  }

  // Manual Override for Testing/Web
  bool _manualOverride = false;
  
  void toggleManualEyeFriendly(bool value) {
      _manualOverride = true; // Use this to ignore sensor updates temporarily if needed, or just let it override
      _isEyeFriendly = value;
      notifyListeners();
  }

  // Helper to get the actual ThemeData based on current state
  ThemeMode get currentThemeMode {
      // If Eye Friendly mode is active, we force the UI to render the warm theme
      // However, ThemeMode is an enum (system, light, dark).
      // We can't return a custom ThemeMode.
      // So instead, we will use a boolean in the View (main.dart) to decide which ThemeData to use.
      // But for this provider, we just expose the state.
      return _themeMode;
  }
}
