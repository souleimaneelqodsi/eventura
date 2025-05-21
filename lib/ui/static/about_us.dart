import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headlineStyle = textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
    final bodyStyle = textTheme.bodyLarge?.copyWith(height: 1.5);
    final listItemStyle = textTheme.bodyMedium?.copyWith(height: 1.4);

    return Scaffold(
      appBar: AppBar(title: const Text('About Eventura')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Eventura: Simplify Your Events', style: headlineStyle),
            const SizedBox(height: 16.0),
            Text(
              'Eventura is a mobile application designed to facilitate the planning and coordination of social events among friends. Our goal is to make organizing gatherings simpler, more intuitive, and enjoyable for everyone.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24.0),
            Text('The Project', style: headlineStyle),
            const SizedBox(height: 16.0),
            Text(
              'This application was developed as part of the annual "Tutored Project" of the Licence 3 MIAGE (Methods Applied to Business Management Informatics) at Paris-Saclay University.',
              style: bodyStyle,
            ),
            const SizedBox(height: 16.0),
            Text(
              'It is the result of a team effort aimed at applying the knowledge acquired during our training in software development and project management.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24.0),
            Text('The Development Team', style: headlineStyle),
            const SizedBox(height: 16.0),
            Text(
              'The code was primarily developed by Souleimane El Qodsi, in valuable collaboration with:',
              style: bodyStyle,
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chahinez Morakeb', style: listItemStyle),
                  Text('Yacine Tetah', style: listItemStyle),
                  Text('Cylia Kasdi', style: listItemStyle),
                  Text('Youssef Dekhail', style: listItemStyle),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Text(
                'Thank you for using Eventura!',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
