import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        appBar: AppBar(title: const Text("Create an event")),
        body: Consumer<EventViewmodel>(
          builder: (context, vmodel, child) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Title"),
                        onChanged: (value) => title = value,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        onChanged: (value) => description = value,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location",
                        ),
                        onChanged: (value) => location = value,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Capacity",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => capacity = int.parse(value),
                      ),
                      SizedBox(height: 8.0),
                      SwitchListTile(
                        title: const Text("Private Event"),
                        value: isPrivate,
                        onChanged: (value) => setState(() => isPrivate = value),
                      ),
                      SizedBox(height: 16),
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
                            if (!vmodel.hasError && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Event created successfully!"),
                                ),
                              );
                            } else if (vmodel.hasError && context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Error"),
                                      content: Text(
                                        "An error occurred while creating the event: ${vmodel.errorMessage}",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          }
                        },
                        child:
                            vmodel.isBusy
                                ? CircularProgressIndicator()
                                : Text("Create"),
                      ),
                      SizedBox(height: 40),
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
