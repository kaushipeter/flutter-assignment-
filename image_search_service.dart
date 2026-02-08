import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';

class ImageSearchService {
  
  // Singleton pattern (optional, but good for services)
  static final ImageSearchService _instance = ImageSearchService._internal();
  factory ImageSearchService() => _instance;
  ImageSearchService._internal();

  /// Compares the captured image with a list of products and returns the best match.
  /// Returns null if no match is found within the threshold.
  Future<Product?> searchByVisualSimilarity(XFile capturedImageFile, List<Product> products) async {
    try {
      // 1. Load and Decode Captured Image
      final capturedBytes = await capturedImageFile.readAsBytes();
      img.Image? capturedImage = img.decodeImage(capturedBytes);

      if (capturedImage == null) return null;

      // 2. Pre-process Captured Image (Resize to 32x32, Grayscale)
      // Crop to square first to match asset aspect ratio better
      img.Image processedCaptured = img.grayscale(img.copyResizeCropSquare(capturedImage, size: 32));

      Product? bestMatch;
      int lowestDifference = 999999;
      // Threshold: Increased to allow for lighting/angle variations.
      // 32x32 = 1024 pixels. Max diff per pixel is 255.
      // Total max diff = 261,120.
      // 100,000 is about 38% difference allowed.
      const int threshold = 100000; 

      // 3. Compare with Product Assets
      Product? colorMatch;
      double lowestColorDistance = 999999.0;
      
      // Calculate dominant color of captured image
      final capturedColor = _calculateDominantColor(processedCaptured);

      for (var product in products) {
        try {
          final ByteData assetData = await rootBundle.load(product.image);
          final Uint8List assetBytes = assetData.buffer.asUint8List();
          img.Image? assetImage = img.decodeImage(assetBytes);

          if (assetImage != null) {
             // Pre-process Asset Image
             img.Image processedAsset = img.grayscale(img.copyResize(assetImage, width: 32, height: 32));

             // 1. Pixel Difference
             int diff = _calculatePixelDifference(processedCaptured, processedAsset);
             print('Pixel Diff for ${product.name}: $diff');

             if (diff < lowestDifference) {
               lowestDifference = diff;
               bestMatch = product;
             }

             // 2. Color Difference (Fallback)
             // Use original resized asset (not grayscale) for color
             img.Image colorAsset = img.copyResize(assetImage, width: 32, height: 32);
             final assetColor = _calculateDominantColor(colorAsset);
             final colorDist = _calculateColorDistance(capturedColor, assetColor);
             print('Color Dist for ${product.name}: $colorDist');

             if (colorDist < lowestColorDistance) {
               lowestColorDistance = colorDist;
               colorMatch = product;
             }
          }
        } catch (e) {
          print('Error processing product ${product.name}: $e');
        }
      }

      // 4. Return Match
      // Priority 1: Pixel Difference (Shape/Pattern)
      if (lowestDifference < threshold) {
        return bestMatch;
      }
      
      // Priority 2: Color Difference (Fallback if shape fails)
      // If color is very close (e.g. < 50 distance), return it
      if (lowestColorDistance < 50.0) {
        print('Returning color match: ${colorMatch?.name}');
        return colorMatch;
      }

      return null;

    } catch (e) {
      print('Error in visual search: $e');
      return null;
    }
  }

  int _calculatePixelDifference(img.Image img1, img.Image img2) {
    int diff = 0;
    for (int y = 0; y < img1.height; y++) {
      for (int x = 0; x < img1.width; x++) {
        int p1 = img1.getPixel(x, y).r.toInt();
        int p2 = img2.getPixel(x, y).r.toInt();
        diff += (p1 - p2).abs();
      }
    }
    return diff;
  }

  // Calculate average RGB color
  List<int> _calculateDominantColor(img.Image image) {
    int r = 0, g = 0, b = 0;
    int count = 0;
    for (var pixel in image) {
      r += pixel.r.toInt();
      g += pixel.g.toInt();
      b += pixel.b.toInt();
      count++;
    }
    return [r ~/ count, g ~/ count, b ~/ count];
  }

  // Euclidean distance between two RGB colors
  double _calculateColorDistance(List<int> c1, List<int> c2) {
    return (
      (c1[0] - c2[0]) * (c1[0] - c2[0]) + 
      (c1[1] - c2[1]) * (c1[1] - c2[1]) + 
      (c1[2] - c2[2]) * (c1[2] - c2[2])
    ).toDouble(); // Sqrt is expensive, we can compare squared distance if needed, but for print standard deviation use sqrt
    // Actually simpler: Manhattan distance for speed? No, let's use Euclidean.
    // Wait, dart requires sqrt from dart:math.
    // Let's just use sum of abs diffs (Manhattan) for simplicity.
    // return ((c1[0] - c2[0]).abs() + (c1[1] - c2[1]).abs() + (c1[2] - c2[2]).abs()).toDouble();
    // Re-implementing simplified distance
     return ((c1[0] - c2[0]).abs() + (c1[1] - c2[1]).abs() + (c1[2] - c2[2]).abs()).toDouble();
  }

  void dispose() {
    // Nothing to dispose
  }
}
