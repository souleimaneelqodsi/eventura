// events_list_view.dart
import 'package:eventura/core/services/auth_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des événements"),
        leading: IconButton(
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.pushReplacementNamed(context, "/login");
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: Consumer<EventListViewmodel>(
        builder: (context, vmodel, child) {
          // ... (keep your existing condition checks for isBusy, hasError, etc.)

          // Corrected section for the ListView
          return RefreshIndicator(
            onRefresh: () => vmodel.refreshEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0), // Apply padding here
              itemCount: vmodel.events.length,
              itemBuilder: (context, index) {
                final event = vmodel.events[index];
                return EventCard(event: event);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/create_event");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}