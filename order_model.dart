import '../providers/cart_provider.dart';
import '../models/product.dart';

class OrderModel {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderModel({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'products': products.map((item) => item.toJson()).toList(),
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(), // Backend ID is int, frontend uses String
      amount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      products: (json['items'] as List?)
              ?.map((item) => CartItem(
                    product: Product.fromJson(item['product']),
                    quantity: item['quantity'],
                  ))
              .toList() ??
          [],
      dateTime: DateTime.tryParse(json['updated_at'] ?? json['created_at'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}

