import 'package:flutter/material.dart';

class FAQEntry {
  final String question;
  final String answer;

  FAQEntry({required this.question, required this.answer});
}

class FAQ extends StatelessWidget {
  FAQ({super.key});

  final List<FAQEntry> faqData = [
    FAQEntry(
      question: 'What is Eventura?',
      answer:
          'Eventura is a mobile application that helps you easily plan and organize events and outings with friends. It simplifies coordinating details like the date, location, and managing participants.',
    ),
    FAQEntry(
      question: 'How can I create an account?',
      answer:
          'You can create an account directly from the app by clicking on "Sign Up" on the home screen. You will need a valid email address and a password.',
    ),
    FAQEntry(
      question: 'How to create an event?',
      answer:
          'Once logged in, you will find a "+" button or a "Create Event" option (usually on the home page). You can then fill in all the details of your event: title, description, date, location, capacity, and whether it is public or private.',
    ),
    FAQEntry(
      question: 'Can I invite friends who don\'t have the app?',
      answer:
          'Currently, to participate in an event via Eventura, your friends will also need to have the application and an account. You can invite them to download Eventura!',
    ),
    FAQEntry(
      question: 'How does adding friends to a private event work?',
      answer:
          'For private events, if you are already participating in the event, you can directly add your friends (people you are already friends with on Eventura) to that event, provided the maximum capacity is not reached.',
    ),
    FAQEntry(
      question: 'How to join a public event?',
      answer:
          'Public events are visible in the "Events" section. If you are interested in a public event and it is not full, you can join it directly from its details page.',
    ),
    FAQEntry(
      question: 'Is my personal data safe?',
      answer:
          'We take the security of your data seriously. Eventura uses Supabase for backend management, which offers robust security features. We recommend choosing a strong password and not sharing it.',
    ),
    FAQEntry(
      question: 'Who developed Eventura?',
      answer:
          'Eventura is a student project developed by a group from the Licence 3 MIAGE at Paris-Saclay University: Souleimane El Qodsi, Chahinez Morakeb, Yacine Tetah, Cylia Kasdi, and Youssef Dekhail.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ (Frequently Asked Questions)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final entry = faqData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: Text(
                entry.question,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0).copyWith(top: 0),
                  child: Text(
                    entry.answer,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
