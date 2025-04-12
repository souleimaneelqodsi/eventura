// events_list_view.dart
// import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/ui/widgets/event_card.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key});

  @override
  EventListViewState createState() => EventListViewState();
}

class EventListViewState extends State<EventListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventListViewmodel>(
      builder: (context, vmodel, child) {
        if (vmodel.hasError) {
          return Center(
            child: Text(
              "Error: ${vmodel.errorMessage!}",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (vmodel.events.isEmpty) {
          return Center(
            child: Text("No events found", style: TextStyle(fontSize: 17)),
          );
        }
        return RefreshIndicator(
          onRefresh: () => vmodel.refreshEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vmodel.events.length,
            itemBuilder: (context, index) {
              final event = vmodel.events[index];
              return EventCard(event: event);
            },
          ),
        );
      },
    );
  }
}
