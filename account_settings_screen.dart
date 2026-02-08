import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNT SETTINGS'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader('General'),
          SwitchListTile(
            activeColor: AppTheme.gold,
            title: const Text('Notifications'),
            subtitle: const Text('Receive updates about orders and promotions'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            activeColor: AppTheme.gold,
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          SwitchListTile(
            activeColor: AppTheme.gold,
            title: const Text('Simulate Low Light'),
            subtitle: const Text('Test Eye-Friendly Mode (< 20 lux)'),
            value: themeProvider.isEyeFriendly,
            onChanged: (value) {
              themeProvider.toggleManualEyeFriendly(value);
            },
          ),
          const Divider(),
          _buildSectionHeader('Security'),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Legal'),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Aura Mobile v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.gold,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
