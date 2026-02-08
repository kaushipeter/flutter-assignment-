import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRIVACY POLICY'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Aura by Kiyara',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: February 2026',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us when you create an account, make a purchase, or communicate with us. This includes your name, email address, phone number, and delivery address.',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use your information to process orders, provide customer support, and improve our services. We may also use your information to send you promotional messages, which you can opt-out of at any time.',
            ),
            _buildSection(
              'Data Security',
              'We implement industry-standard security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
            ),
            _buildSection(
              'Your Choices',
              'You can access and update your account information through the app settings. You can also request the deletion of your account by contacting our support team.',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at support@aurabykiyara.com',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
