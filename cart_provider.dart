import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  // Internal private state
  final Map<int, CartItem> _items = {};

  // Auth State
  String? _authToken;
  bool _isAuthenticated = false;

  CartProvider() {
    _loadCart();
  }

  void update(String? token, bool isAuthenticated) {
    _authToken = token;
    _isAuthenticated = isAuthenticated;
    
    // If user just logged in, sync local cart to server
    if (_isAuthenticated) {
      _syncCartWithServer();
    }
  }

  // Public getter to access state (encapsulation)
  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // =========================================================
  // STATE MODIFICATION (Actions)
  // ---------------------------------------------------------
  // These methods change the internal state of the Cart.
  // After every change, we call notifyListeners().
  // =========================================================
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    
    // CRITICAL: Tells all listening widgets (Consumers) to rebuild!
    // This is how the Cart Screen and Cart Badge update instantly.
    notifyListeners();
    
    _saveCart(); // Persist changes
    _addToServer(product.id, 1);
  }

  void removeItem(int productId) {
    _items.remove(productId);
    
    // Update UI immediately
    notifyListeners();
    
    _saveCart();
    _removeFromServer(productId);
  }

  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId]!.quantity = quantity;
      }

      notifyListeners();
      _saveCart();
      _updateServerQuantity(productId, quantity);
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  // =========================================================
  // LOCAL STORAGE (Writing Data)
  // Demonstrates: Writing complex objects to local JSON
  // =========================================================
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the Map of Carts to a JSON String
    // This allows us to store complex objects in simple Key-Value storage
    final String encodedData = json.encode(
      _items.map((key, item) => MapEntry(key.toString(), item.toJson())),
    );
    await prefs.setString('cart_items', encodedData);
    print('Cart saved to local storage.');
  }

  // =========================================================
  // LOCAL STORAGE (Reading Data)
  // Demonstrates: Reading & Hydrating state from local JSON
  // =========================================================
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cart_items')) return;

    // Load the JSON string from storage
    final String? encodedData = prefs.getString('cart_items');
    if (encodedData != null) {
      // Decode JSON back into Dart Objects (Hydration)
      final Map<String, dynamic> extractedData = json.decode(encodedData);
      extractedData.forEach((key, value) {
        _items[int.parse(key)] = CartItem.fromJson(value);
      });
      notifyListeners();
      print('Cart loaded from local storage (Offline Ready).');
    }
  }


  // =========================================================
  // BACKEND SYNC
  // =========================================================
  Future<void> _syncCartWithServer() async {
    if (!_isAuthenticated || _authToken == null) return;

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/cart/sync');
      
      // Prepare local items for sync
      final localItems = _items.entries.map((e) => {
        'product_id': e.key,
        'quantity': e.value.quantity,
      }).toList();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({'items': localItems}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverItems = data['items'] as List;
        
        // Merge server cart into local cart (Server is truth)
        _items.clear();
        for (var item in serverItems) {
           final product = Product.fromJson(item['product']);
           _items[product.id] = CartItem(
             product: product,
             quantity: item['quantity'],
           );
        }
        notifyListeners();
        _saveCart(); // Update local storage with merged data
        print('Cart synced with server.');
      }
    } catch (e) {
      print('Sync Cart Error: $e');
    }
  }

  Future<void> _addToServer(int productId, int quantity) async {
    if (!_isAuthenticated || _authToken == null) return;
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/cart/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );
    } catch (e) {
      print('Add to Server Error: $e');
    }
  }
  
  Future<void> _updateServerQuantity(int productId, int quantity) async {
    if (!_isAuthenticated || _authToken == null) return;
    try {
      await http.put(
        Uri.parse('${AppConfig.baseUrl}/cart/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );
    } catch (e) {
      print('Update Server Error: $e');
    }
  }

  Future<void> _removeFromServer(int productId) async {
    if (!_isAuthenticated || _authToken == null) return;
    try {
      await http.delete(
        Uri.parse('${AppConfig.baseUrl}/cart/items/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );
    } catch (e) {
      print('Remove from Server Error: $e');
    }
  }
}
