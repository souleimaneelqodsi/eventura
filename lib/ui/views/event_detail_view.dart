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
            padding: const EdgeInsets.all(32.0),
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
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Lieu",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.title}",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Description",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.description}",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                vmodel.hasError
                                                    ? Text(vmodel.errorMessage!)
                                                    : Text(
                                                      "Évènement supprimé avec succès",
                                                    ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child:
                                        vmodel.isBusy
                                            ? CircularProgressIndicator()
                                            : Text(
                                              "Supprimer",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
