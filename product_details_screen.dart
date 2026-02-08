import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_image.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name.toUpperCase()),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop: Image on Left (50%)
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: ProductImage(
                      imagePath: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Desktop: Details on Right (50%)
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(context),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildProductDescription(context),
                        const SizedBox(height: 40),
                        _buildAddToCartButton(context),
                        const SizedBox(height: 24),
                        _buildSafetyBadges(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile: Column Layout
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: ProductImage(
                      imagePath: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(context),
                        const SizedBox(height: 16),
                        _buildProductDescription(context),
                        const SizedBox(height: 40),
                        _buildAddToCartButton(context),
                        const SizedBox(height: 24),
                        _buildSafetyBadges(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EAU DE PARFUM',
          style: TextStyle(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'LKR ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            color: AppTheme.gold,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription(BuildContext context) {
    return Text(
      product.description,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.6,
          ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<CartProvider>().addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              backgroundColor: AppTheme.gold,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: AppTheme.charcoalDark,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          'ADD TO CART',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyBadges() {
    return const Row(
      children: [
        Icon(Icons.check, color: AppTheme.gold, size: 20),
        SizedBox(width: 8),
        Text('Authenticity Guaranteed', style: TextStyle(color: Colors.grey)),
        SizedBox(width: 24),
        Icon(Icons.access_time, color: AppTheme.gold, size: 20),
        SizedBox(width: 8),
        Text('Long Lasting', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
