import 'package:flutter/material.dart';
import 'package:eventura/core/models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.title, style: TextStyle(fontSize: 20),),
        subtitle: Text(event.location),
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
