// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headlineStyle = textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
    final bodyStyle = textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('A question, a suggestion?', style: headlineStyle),
            const SizedBox(height: 16.0),
            Text(
              'For any inquiries regarding the Eventura project, you can contact the development team via the project manager:',
              style: bodyStyle,
            ),
            const SizedBox(height: 12.0),
            SelectableText(
              'Souleimane El Qodsi: souleimane.e@proton.me',
              style: bodyStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            Text(
              'You can also check out the project repository on GitHub for more technical details or to report issues:',
              style: bodyStyle,
            ),
            const SizedBox(height: 12.0),
            SelectableText(
              'github.com/souleimaneelqodsi/eventura',
              style: bodyStyle?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
              onTap: () {
                final Uri url = Uri.parse(
                  'https://github.com/souleimaneelqodsi/eventura',
                );
                bool canLaunch = false;
                canLaunchUrl(url).then((value) => canLaunch = value);
                if (canLaunch) {
                  launchUrl(url);
                } else {
                  print('Could not launch $url');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
