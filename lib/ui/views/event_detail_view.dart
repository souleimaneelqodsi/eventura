import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EventViewmodel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadEvent(eventId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Détails de l'événement")),
      body: Consumer<EventViewmodel>(
        builder: (context, vmodel, child) {
          if (vmodel.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Une erreur s'est produite : ${vmodel.errorMessage}",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (vmodel.event == null) {
            return const Center(child: Text("Cet évènement n'existe pas."));
          }
          final event = vmodel.event!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Lieu: ${event.location}"),
                const SizedBox(height: 8),
                Text("Description: ${event.description}"),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /*ElevatedButton(
                      onPressed: () {
                        //Navigator.pushNamed(
                        //context,
                        //"/edit_event",
                        //arguments: event,
                        //);
                      },
                      child: const Text("Modifier"),
                    ),*/
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Supprimer l'événement ?"),
                                content: const Text(
                                  "Êtes-vous sûr de vouloir supprimer cet événement ?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await vmodel.deleteEvent(
                                        context,
                                        vmodel.event!.eventId!,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child:
                                        vmodel.isBusy
                                            ? CircularProgressIndicator()
                                            : Text("Supprimer"),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
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
