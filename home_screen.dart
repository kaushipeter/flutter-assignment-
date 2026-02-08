import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_shell.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_image.dart';
import '../providers/wishlist_provider.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Visual Search removed by user request.
  final TextEditingController _searchController = TextEditingController();

  void _navigateToShopWithSearch(String query) {
     // Not used for visual search anymore, but kept for text search
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(action: SnackBarAction(label: 'GO', onPressed: (){
             Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NavigationShell(initialIndex: 1)),
                              );
        }), content: Text('Search for "$query"?')),
     );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredProducts = dummyProducts.where((p) => p.isFeatured).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 600,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/hero.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black45,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AURA BY KIYARA',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.goldLight,
                              fontSize: 48, // Slightly smaller to fit
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Essence of Elegance',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),

                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NavigationShell(initialIndex: 1)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              foregroundColor: AppTheme.charcoalDark,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text(
                              'SHOP COLLECTION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Featured Collections
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'DISCOVER',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Featured Collections',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 2,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 900 ? 5 : constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: featuredProducts.length,
                        itemBuilder: (context, index) {
                          final product = featuredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.zero,
                                            child: ProductImage(
                                              imagePath: product.image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
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
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Playfair Display',
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
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
