import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/event_detail_viewmodel.dart';

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<EventDetailViewModel>(context, listen: false);

    // Charger l'événement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      model.loadEvent(eventId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Détails de l'événement")),
      body: Consumer<EventDetailViewModel>(
        builder: (context, model, child) {
          if (model.event == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = model.event!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Lieu: ${event.location}"),
                const SizedBox(height: 8),
                Text("Description: ${event.description}"),
                const SizedBox(height: 16),
                //Ajouter les boutons "Modifier" et "Supprimer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/edit_event",
                            arguments: event);
                      },
                      child: const Text("Modifier"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Supprimer l'événement ?"),
                            content: const Text(
                                "Êtes-vous sûr de vouloir supprimer cet événement ?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Annuler"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await model.deleteEvent();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Supprimer"),
                              ),
                            ],
                          ),
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Supprimer"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
