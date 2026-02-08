import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config.dart';

/*
 * Implemented by: Antigravity (AI Assistant)
 * 
 * Purpose: Wishlist/Favorites State Management
 * 
 * Library Used: Provider (ChangeNotifier)
 * 
 * Why: 
 * Users expect to see their favorite items reflected immediately across the app.
 * By using Provider, we can toggle the heart icon on a product card in the 'Shop' screen
 * and have it instantly appear in the 'Wishlist' screen without manual data passing.
 */
class WishlistProvider with ChangeNotifier {
  Map<int, Product> _items = {};
  String? _authToken;

  WishlistProvider();

  void update(String? token) {
    _authToken = token;
    if (_authToken != null) {
      _loadWishlist();
    } else {
      _items = {};
      notifyListeners();
    }
  }

  Map<int, Product> get items => {..._items};

  bool isFavorite(int productId) {
    return _items.containsKey(productId);
  }

  Future<void> toggleFavorite(Product product) async {
    final isFav = _items.containsKey(product.id);
    
    // Optimistic update
    if (isFav) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }
    notifyListeners();

    try {
      if (_authToken == null) return;

      if (isFav) {
        // Remove from API
        await http.delete(
          Uri.parse('${AppConfig.baseUrl}/wishlist/${product.id}'),
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Accept': 'application/json',
          },
        );
      } else {
        // Add to API
        await http.post(
          Uri.parse('${AppConfig.baseUrl}/wishlist'),
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'product_id': product.id}),
        );
      }
    } catch (e) {
      print('Wishlist sync error: $e');
      // Revert on error
      if (isFav) {
        _items[product.id] = product;
      } else {
        _items.remove(product.id);
      }
      notifyListeners();
    }
  }

  Future<void> _loadWishlist() async {
    try {
      if (_authToken == null) return;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/wishlist'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<int, Product> loadedItems = {};
        for (var item in data) {
           final product = Product.fromJson(item);
           loadedItems[product.id] = product;
        }
        _items = loadedItems;
        notifyListeners();
      }
    } catch (e) {
      print('Load wishlist error: $e');
    }
  }
}
