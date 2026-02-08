
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // Added for XFile
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;

  // =========================================================
  // LOGIN Method
  // Connects to SSP API Endpoint: /api/login
  // =========================================================
  Future<bool> login(String email, String password) async {
    try {
      // 1. Send Login credentials
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      // 2. Success (200 OK)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login Response: ${response.body}');
        _token = data['token'];
        if (_token == null) {
             print('Login Error: Token not found in response');
             return false;
        }
        
        // 3. User Data Handling
        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
        }
        
        _isAuthenticated = true;
        
        // 4. Persist Session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        if (_user != null) {
          await prefs.setString('user_data', json.encode(_user!.toJson()));
        }
        
        notifyListeners(); // Notify app to update (show Home)
        return true;
      }

      
      print('Login Failed: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Try to parse error message
      try {
        final body = json.decode(response.body);
        if (body['message'] != null) {
          // Check for validation errors in login too
          if (body['errors'] != null) {
             final errors = body['errors'] as Map<String, dynamic>;
             if (errors.isNotEmpty) {
               // Just return the first error for login is usually enough, or the main message
               return false; 
             }
          }
        }
      } catch (_) {}
      
      return false;
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
         print('Network Error: Server might be down or unreachable.');
      }
      return false;
    }
  }

  // =========================================================
  // REGISTER Method
  // Connects to SSP API Endpoint: /api/register
  // =========================================================
  Future<String?> register(String name, String email, String password) async {
    try {
      // 1. Send HTTP POST request to the Laravel Backend
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'), // e.g., http://127.0.0.1:8000/api/register
        headers: {
          'Content-Type': 'application/json', // Tells server we are sending JSON
          'Accept': 'application/json',       // Tells server we expect JSON response
        },
        // 2. Encode the user data as JSON
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Required by Laravel default validation
        }),
      );

      print('Register status: ${response.statusCode}');
      print('Register body: ${response.body}');

      // 3. Check for Success (200 OK or 201 Created)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token']; // Extract the Sanctum token
         if (_token == null) {
             return 'Token not found in response';
        }
        
        // 4. Parse and store user object
        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
        }

        _isAuthenticated = true;
        
        // 5. Persist Token for Auto-Login (Keep user logged in on restart)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        if (_user != null) {
          await prefs.setString('user_data', json.encode(_user!.toJson()));
        }
        
        notifyListeners(); // Notify UI to update (switch to Home Screen)
        return null; // Null means SUCCESS (No error message)
      }
      
      // 6. Handle Validation Errors (e.g., "Email already taken")
      try {
        final body = json.decode(response.body);
        
        // Check standard 'message' field
        if (body['message'] != null) {
          return body['message'];
        }
        
        // Check specific 'errors' object from Laravel ValidationException
        if (body['errors'] != null) {
           final errors = body['errors'] as Map<String, dynamic>;
           String errorMessage = '';
           // Combine all validation errors into one string
           errors.forEach((key, value) {
             if (value is List) {
               errorMessage += '${value.join('\n')}\n';
             } else {
               errorMessage += '$value\n';
             }
           });
           return errorMessage.trim();
        }
      } catch (_) {}
      
      return 'Registration failed: ${response.statusCode}';
    } catch (e) {
      print('Register error: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
         return 'Network Error: Cannot connect to server. Please check your internet connection.';
      }
      return 'Network error: $e';
    }
  }

  Future<void> logout() async {
    print('AuthService: logout called');
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 2));
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isAuthenticated = false;
      _token = null;
      _user = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      
      print('Logout completed. Notify listeners.');
      notifyListeners();
    }
  }

  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      if (_token == null) return 'Not authenticated';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/user/profile-image'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      // Cross-platform: Read bytes directly
      final bytes = await imageFile.readAsBytes();
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['profile_image'] != null && _user != null) {
            // Update local user object
            _user = User(
                id: _user!.id,
                name: _user!.name,
                email: _user!.email,
                phone: _user!.phone,
                address: _user!.address,
                role: _user!.role,
                profileImage: data['profile_image'],
            );
             // Update SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_data', json.encode(_user!.toJson()));
            
            notifyListeners();
            return null; // Success
        }
      }
      return 'Upload failed: ${response.statusCode} - ${response.body}';
    } catch (e) {
      return 'Error uploading image: $e';
    }
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      if (_token == null) return 'Not authenticated';

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Success
      }

      final body = json.decode(response.body);
      if (body['message'] != null) {
        if (body['errors'] != null) {
           final errors = body['errors'] as Map<String, dynamic>;
           String errorMessage = '';
           errors.forEach((key, value) {
             if (value is List) {
               errorMessage += '${value.join('\n')}\n';
             } else {
               errorMessage += '$value\n';
             }
           });
           return errorMessage.trim();
        }
        return body['message'];
      }

      return 'Failed to change password: ${response.statusCode}';
    } catch (e) {
      return 'Network error: $e';
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;

    _token = prefs.getString('auth_token');
    
    if (prefs.containsKey('user_data')) {
      try {
        final userData = json.decode(prefs.getString('user_data')!);
        _user = User.fromJson(userData);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }

    _isAuthenticated = true;
    notifyListeners();
  }
}
