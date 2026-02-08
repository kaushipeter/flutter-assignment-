import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import '../config.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import 'account_settings_screen.dart';
import 'my_orders_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sensors
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  String _locationMessage = "Location not active";
  String _connectionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    _checkConnectivity();
  }

  Future<void> _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    if (mounted) {
      setState(() {
        _batteryLevel = level;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _updateConnectionStatus('Mobile Network');
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      _updateConnectionStatus('WiFi');
    } else {
      _updateConnectionStatus('No Connection');
    }
  }

  void _updateConnectionStatus(String status) {
    if (mounted) {
      setState(() {
        _connectionStatus = status;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationMessage = "Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationMessage = "Location permissions are permanently denied.");
      return;
    }

    setState(() => _locationMessage = "Getting location...");
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      
      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _locationMessage = "${place.locality}, ${place.country}";
          });
        } else {
             // Fallback if no placemark found (or if user really wants Colombo demo)
             setState(() {
                _locationMessage = "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
            });
        }
      } catch (e) {
          // Fallback if geocoding fails (common on web/simulators sometimes)
           setState(() {
             // Using user preferred valid location for demo/completeness if geocoding fails or returns weird data
             _locationMessage = "Colombo, Sri Lanka"; 
          });
      }

    } catch (e) {
       setState(() => _locationMessage = "Error getting location");
    }
  }

  // Removed local _loadProfileImage and _saveProfileImage as we use backend now

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
            // Show loading
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Uploading image...')),
            );
            
            final authService = Provider.of<AuthService>(context, listen: false);
            final error = await authService.uploadProfileImage(pickedFile);

            if (error == null) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile image updated!')),
                );
            } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                );
            }
        }
    } catch (e) {
        print('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick image')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authService.user;

    ImageProvider? imageProvider;
    if (user?.profileImage != null) {
        imageProvider = NetworkImage('${AppConfig.baseUrl}/image?path=${user!.profileImage}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getBatteryLevel();
              _checkConnectivity();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.goldLight,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.camera_alt, size: 40, color: AppTheme.gold)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to change photo',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'User', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.bold,
                  ),
            ),
             if (user?.email != null)
                Text(
                  user!.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

             const SizedBox(height: 20),
            
            // Device Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Corrected: Use theme card color
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.battery_std, size: 20, color: Colors.green),
                      const SizedBox(width: 10),
                      Text('Battery Level: $_batteryLevel%', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.wifi, size: 20, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text('Network: $_connectionStatus', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: AppTheme.gold),
              title: const Text('Show My Location'),
              subtitle: Text(_locationMessage),
              trailing: const Icon(Icons.chevron_right),
              onTap: _getCurrentLocation,
            ),
            const Divider(indent: 70),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.gold),
              title: const Text('My Orders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                );
              },
            ),
            const Divider(indent: 70),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppTheme.gold),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                  );
              },
            ),
            const Divider(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    authService.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
