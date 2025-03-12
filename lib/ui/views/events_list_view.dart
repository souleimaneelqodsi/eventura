// events_list_view.dart
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/ui/widgets/event_card.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
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
          if (vmodel.isBusy) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vmodel.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Erreur: ${vmodel.errorMessage}",
                  style: const TextStyle(color: Colors.red, fontSize: 17),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => vmodel.refreshEvents(),
                  child: const Text("Réessayer"),
                )
              ],
            );
          }

          if (vmodel.events.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Aucun événement disponible",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => vmodel.refreshEvents(),
                  child: const Text("Actualiser"),
                )
              ],
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: () => vmodel.refreshEvents(),
                child: ListView.builder(
                  itemCount: vmodel.events.length,
                  itemBuilder: (context, index) {
                    final event = vmodel.events[index];
                    return EventCard(event: event);
                  },
                ),
              ),
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