import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TERMS OF SERVICE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing or using the Aura by Kiyara mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
            ),
            _buildSection(
              '2. User Accounts',
              'You are responsible for maintaining the confidentiality of your account credentials. You must immediately notify us of any unauthorized use of your account.',
            ),
            _buildSection(
              '3. Orders and Payments',
              'All orders are subject to acceptance by us. Pricing and availability of products are subject to change without notice. Payments are processed through secure third-party providers.',
            ),
            _buildSection(
              '4. Intellectual Property',
              'All content in the application, including text, graphics, logos, and images, is the property of Aura by Kiyara and is protected by intellectual property laws.',
            ),
            _buildSection(
              '5. Limitation of Liability',
              'Aura by Kiyara shall not be liable for any indirect, incidental, or consequential damages arising out of your use of the application.',
            ),
            _buildSection(
              '6. Governing Law',
              'These Terms of Service are governed by and construed in accordance with the laws of Sri Lanka.',
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
