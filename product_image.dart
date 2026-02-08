import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/${imagePath.split('/').last}',
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to network if asset not found
        return Image.network(
           imagePath.startsWith('http') 
              ? imagePath 
              : 'http://localhost:8000/api/image?path=$imagePath',
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
             return Image.asset(
              'assets/images/logo.jpg', 
              fit: fit,
            );
          },
        );
      },
    );
  }
}
