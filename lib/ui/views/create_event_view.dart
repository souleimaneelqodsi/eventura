import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  _CreateEventViewState createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";
  String location = "";
  int capacity = 0;
  bool isPrivate = false;
  DateTime? dateOfBeginning;

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un événement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Titre"),
                onChanged: (value) => title = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (value) => description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Lieu"),
                onChanged: (value) => location = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Capacité"),
                keyboardType: TextInputType.number,
                onChanged: (value) => capacity = int.parse(value),
              ),
              SwitchListTile(
                title: const Text("Événement privé"),
                value: isPrivate,
                onChanged: (value) => setState(() => isPrivate = value),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final event = Event(
                      organizerId:
                          1, // À remplacer par l'ID réel de l'utilisateur connecté
                      title: title,
                      description: description,
                      location: location,
                      capacity: capacity,
                      dateOfBeginning: DateTime.now(),
                      isPrivate: isPrivate,
                    );

                    await eventService.createEvent(event);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Créer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
