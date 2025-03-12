import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/models/event.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Créer un événement")),
        body: Consumer<EventViewmodel>(
          builder: (context, vmodel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                      Expanded(child:Container()),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final event = Event(
                              organizerId:
                                  Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  ).currentUser!.id,
                              title: title,
                              description: description,
                              location: location,
                              capacity: capacity,
                              dateOfBeginning: DateTime.now(),
                              isPrivate: isPrivate,
                            );
                            await vmodel.createEvent(context, event);
                            if (vmodel.hasError && context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => AlertDialog(
                                      actions: [
                                        FloatingActionButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                      content: Text(
                                        "Une erreur s'est produite lors de la création de l'évènement : ${vmodel.errorMessage}",
                                      ),
                                      title: Text("Erreur"),
                                    ),
                              );
                            }
                          }
                        },
                        child:
                            vmodel.isBusy
                                ? CircularProgressIndicator()
                                : Text("Créer"),
                      ),
                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
