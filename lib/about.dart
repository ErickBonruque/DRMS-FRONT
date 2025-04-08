import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final String licenseUrl = 'http://www.apache.org/licenses/LICENSE-2.0';

  void _launchURL() async {
    final uri = Uri.parse(licenseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DRMSimulator v1.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'An academic software developed to perform dry methane reforming simulations.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Apache License 2.0',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextButton(
              onPressed: _launchURL,
              child: const Text(
                'http://www.apache.org/licenses/LICENSE-2.0',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Copyright 2023 Evandro Alves Nakajima'),
          ],
        ),
      ),
    );
  }
}
