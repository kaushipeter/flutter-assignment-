import 'package:flutter/foundation.dart';

class AppConfig {
  // For Android Emulator use: 'http://10.0.2.2:8000/api'
  // For iOS Simulator use: 'http://127.0.0.1:8000/api'
  // For Real Device use your machine's IP: 'http://192.168.1.x:8000/api'
  static const String baseUrl = kIsWeb 
      ? 'http://127.0.0.1:8001/api' 
      : 'http://10.0.2.2:8001/api'; // Android Emulator default 
}
