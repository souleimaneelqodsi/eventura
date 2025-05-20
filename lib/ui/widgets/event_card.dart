import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:eventura/core/models/event.dart';
import 'package:provider/provider.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final eventListVM = Provider.of<EventListViewmodel>(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        trailing: IconButton(
          icon: Icon(
            eventListVM.isEventFavorited(event.eventId!)
                ? Icons.favorite
                : Icons.favorite_border,
          ),
          color:
              eventListVM.isEventFavorited(event.eventId!)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          onPressed: () => eventListVM.toggleFavoriteStatus(event.eventId!),
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
