import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:eventura/ui/widgets/event_card.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({super.key});

  @override
  _EventsListViewState createState() =>
      _EventsListViewState(); //Utilisation de _EventsListViewState pour gérer l’état de l’écran
}

//initialisation des évebements
class _EventsListViewState extends State<EventsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventsListViewModel>(context, listen: false).loadEvents();
    });
  }

//Construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des événements")),
      body: Consumer<EventsListViewModel>(
        builder: (context, model, child) {
          if (model.events.isEmpty) {
            return const Center(child: Text("Aucun événement disponible"));
          }

          return ListView.builder(
            itemCount: model.events.length,
            itemBuilder: (context, index) {
              final event = model.events[index];
              return EventCard(
                  event: event); // Widget pour afficher un événement
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context,
              "/create_event"); //Quand l’utilisateur clique sur le FloatingActionButton, il est redirigé vers la page de création d’événement
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
