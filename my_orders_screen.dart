import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when screen loads
    Future.microtask(() => 
      Provider.of<OrderProvider>(context, listen: false).fetchOrders()
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ORDERS'),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  const Text(
                    'No orders found.',
                    style: TextStyle(fontSize: 18, fontFamily: 'Playfair Display'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      'Order #${order.id}', 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime),
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            Text(
                                '${order.products.length} Items',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            )
                        ],
                    ),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Text(
                              'LKR ${order.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange.withOpacity(0.5))
                                ),
                                child: Text('Pending', style: TextStyle(color: Colors.orange[800], fontSize: 10)),
                            )
                        ],
                    ),
                    children: order.products.map((item) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/images/${item.product.image.split('/').last}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to network if asset not found (e.g. for newly uploaded images via admin that are not in assets)
                                return Image.network(
                                  item.product.image.startsWith('http') 
                                      ? item.product.image 
                                      : 'http://localhost:8000/api/image?path=${item.product.image}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                     return Image.asset(
                                      'assets/images/logo.jpg', 
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        title: Text(item.product.name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          'LKR ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
