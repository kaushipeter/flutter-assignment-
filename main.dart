import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wishlist_provider.dart';
import 'services/auth_service.dart';
import 'widgets/navigation_shell.dart';
import 'screens/login_screen.dart';

/*
 * Implemented by: Antigravity (AI Assistant)
 * 
 * Purpose: State Management Configuration (Root Level)
 * 
 * Library Used: Provider
 * 
 * Why: 
 * We use the 'Provider' package (specifically MultiProvider) to inject state objects 
 * (AuthService, CartProvider, ThemeProvider, etc.) at the very top of the widget tree.
 * 
 * This approach allows us to:
 * 1. Efficiently manage state across the entire application.
 * 2. Avoid "Prop Drilling" (passing data manually through every widget constructor).
 * 3. Ensure that when state changes (e.g., item added to cart), only the dependent widgets rebuild.
 * 4. Decouple logic from UI code.
 */

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Explicitly allow all orientations (this is the default, but good to be explicit given the request)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // AuthService: Manages User Login/Register State
        ChangeNotifierProvider(create: (_) => AuthService()..tryAutoLogin()),
        
        // CartProvider: Manages Shopping Cart State (Global)
        // CartProvider: Manages Shopping Cart State (Global)
        // Dependent on AuthService for syncing data
        ChangeNotifierProxyProvider<AuthService, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) => cart!..update(auth.token, auth.isAuthenticated),
        ),
        
        // ThemeProvider: Manages Dark/Light Mode State
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // OrderProvider: Manages Order History State
        ChangeNotifierProxyProvider<AuthService, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, orders) => orders!..update(auth.token),
        ),

        // WishlistProvider: Manages Favorite Items State
        ChangeNotifierProxyProvider<AuthService, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, wishlist) => wishlist!..update(auth.token),
        ),
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // CONSUMER WIDGET
    // ---------------------------------------------------------
    // The consumer listens to 'ThemeProvider' changes.
    // When the theme changes, ONLY this widget rebuilds.
    // This is efficient state management in action.
    // =========================================================
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Dynamic Theme Logic:
        // If Eye Friendly mode is active (lux < 20), we override the theme to our warm custom theme.
        // We force ThemeMode.light so it uses the 'theme' property, which we set to accessibleTheme.
        // Otherwise, we respect the user's system/manual preference.
        
        final ThemeData activeTheme = themeProvider.isEyeFriendly 
            ? AppTheme.eyeFriendlyTheme 
            : AppTheme.lightTheme;
            
        final ThemeMode activeMode = themeProvider.isEyeFriendly
            ? ThemeMode.light // Force light mode to use the 'activeTheme' property above
            : themeProvider.themeMode;

        return MaterialApp(
          title: 'Aura by Kiyara',
          debugShowCheckedModeBanner: false,
          theme: activeTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: activeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return authService.isAuthenticated ? const NavigationShell() : const LoginScreen();
  }
}
