import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final String url;

  const ClickableText({
    super.key,
    required this.text,
    required this.url,
  });

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openLink(url),
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(255, 78, 164, 235),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}