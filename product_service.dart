import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../config.dart';

class ProductService {
  // Key for storing cached products in local storage (SharedPreferences)
  static const String _storageKey = 'cached_products';

  // =========================================================
  // GET PRODUCTS Method
  // Demonstrates Exceptional Data Integration:
  // 1. Online:     Fetches fresh data from External API (JSON).
  // 2. Caching:    Save fresh data to Local Storage (SharedPreferences).
  // 3. Offline:    Read from Local Storage if API fails.
  // 4. Fallback:   Read from Local Asset JSON if all else fails.
  // =========================================================
  Future<List<Product>> getProducts() async {
    try {
      // ---------------------------------------------------------
      // Step 1: Online Data Fetching (External JSON)
      // ---------------------------------------------------------
      print('Attempting to fetch products from API...');
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/products'))
          .timeout(const Duration(seconds: 5)); // Add timeout to prevent hanging

      if (response.statusCode == 200) {
        // API Success: Parse the JSON response
        final List<dynamic> data = json.decode(response.body);
        
        // ---------------------------------------------------------
        // Step 2: Seamless Data Management (Write to Local Storage)
        // ---------------------------------------------------------
        // We cache the fresh API data locally so it's available offline later.
        // This ensures the user sees the latest data even without internet next time.
        _saveToLocalCache(response.body);
        
        print('Products loaded from API and cached.');
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products from API: ${response.statusCode}');
      }
    } catch (e) {
      // ---------------------------------------------------------
      // Step 3: Offline Data Management (Read from Local Storage)
      // ---------------------------------------------------------
      print('API Error: $e. Switching to offline mode.');
      
      try {
        // Check if we have previously cached data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(_storageKey)) {
          print('Loading products from Local Storage Cache...');
          final String cachedData = prefs.getString(_storageKey)!;
          final List<dynamic> data = json.decode(cachedData);
          return data.map((json) => Product.fromJson(json)).toList();
        }
      } catch (cacheError) {
        print('Cache Error: $cacheError');
      }

      // ---------------------------------------------------------
      // Step 4: Fallback Handling (Local Asset JSON)
      // ---------------------------------------------------------
      // If no internet AND no cache (first run offline), load default data from app bundle.
      try {
        print('Loading products from Local Asset JSON (Emergency Fallback)...');
        final String response = await rootBundle.loadString('assets/data/products.json');
        final List<dynamic> data = json.decode(response);
        return data.map((json) => Product.fromJson(json)).toList();
      } catch (assetError) {
        print('Critical Error loading local products: $assetError');
        return []; // Return empty list only if absolutely everything fails
      }
    }
  }

  // Helper method to write data to local storage
  Future<void> _saveToLocalCache(String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Failed to cache products: $e');
    }
  }
}
