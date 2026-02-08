import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../services/product_service.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/product_image.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Men', 'Women', 'Kids', 'Gifts'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ProductService().getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredProducts = _products
        .where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        })
        .toList();

    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OUR COLLECTION'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.gold,
            onTap: (index) {
              setState(() {
                _selectedCategory = _categories[index];
              });
            },
            tabs: _categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for perfumes...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.gold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Product Grid
            Expanded(
              child: filteredProducts.isEmpty 
                  ? Center(child: Text('No products found in $_selectedCategory'))
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          color: Theme.of(context).cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                  child: ProductImage(
                                    imagePath: product.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontFamily: 'Playfair Display',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'LKR ${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'VIEW DETAILS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.0,
                                        color: Colors.grey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Wishlist Heart Icon
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Consumer<WishlistProvider>(
                            builder: (context, wishlist, child) {
                              final isFavorite = wishlist.isFavorite(product.id);
                              return GestureDetector(
                                onTap: () {
                                  wishlist.toggleFavorite(product);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
