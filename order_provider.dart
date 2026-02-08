import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import 'cart_provider.dart';

import 'package:http/http.dart' as http;
import '../config.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  String? _authToken;

  List<OrderModel> get orders {
    return [..._orders];
  }
  
  void update(String? token) {
    _authToken = token;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    if (_authToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _orders = data.map((item) => OrderModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch Orders Error: $e');
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    if (_authToken == null) return;
    
    try {
        // We are triggering order creation from existing cart on server
        // So we don't strictly need to send products/total if the server uses the cart
        // But to follow the existing flow, let's just trigger the endpoint
        
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/orders'),
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
             // Optional: if we wanted to send specific items, we could.
             // But our backend implementation uses the server-side cart.
          }),
        );
        
        if (response.statusCode == 201) {
            // Refresh orders list
            await fetchOrders();
        } else {
            throw Exception('Failed to place order');
        }

    } catch (e) {
        print('Place Order Error: $e');
        rethrow;
    }
  }
}
