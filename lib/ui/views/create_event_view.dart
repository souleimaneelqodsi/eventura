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
        appBar: AppBar(title: const Text("Create an event")),
        body: Consumer<EventViewmodel>(
          builder: (context, vmodel, child) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Title"),
                        onChanged: (value) => title = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        onChanged: (value) => description = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location",
                        ),
                        onChanged: (value) => location = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Capacity",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => capacity = int.parse(value),
                      ),
                      SwitchListTile(
                        title: const Text("Private Event"),
                        value: isPrivate,
                        onChanged: (value) => setState(() => isPrivate = value),
                      ),
                      Container(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 27,
                          ),
                        ),
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
                                : Text(
                                  "Create",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
