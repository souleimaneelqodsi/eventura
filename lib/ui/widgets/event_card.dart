import 'package:flutter/material.dart';
import 'package:eventura/core/models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        title: Text(event.title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(event.location),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            "/event_detail",
            arguments: event.eventId,
          );
        },
      ),
    );
  }
}
