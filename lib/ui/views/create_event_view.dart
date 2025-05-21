import 'dart:io';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _coverImageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _coverImageFile = File(pickedFile.path);
      });
    }
  }

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
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Title cannot be empty'
                                    : null,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        onChanged: (value) => description = value,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Description cannot be empty'
                                    : null,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location",
                        ),
                        onChanged: (value) => location = value,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Location cannot be empty'
                                    : null,
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Capacity",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            capacity = parsedValue;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Capacity cannot be empty';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Capacity must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),

                      SizedBox(height: 16),
                      _coverImageFile == null
                          ? ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            label: Text("Select Cover Image"),
                          )
                          : Column(
                            children: [
                              Image.file(
                                _coverImageFile!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.edit),
                                label: Text("Change Image"),
                              ),
                            ],
                          ),
                      SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text("Private Event"),
                        value: isPrivate,
                        onChanged: (value) => setState(() => isPrivate = value),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            vmodel.isBusy
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    final event = Event(
                                      organizerId:
                                          Provider.of<AuthService>(
                                            context,
                                            listen: false,
                                          ).currentUser!.id,
                                      title: title,
                                      nbGuests: 1,
                                      description: description,
                                      location: location,
                                      capacity: capacity,
                                      isPrivate: isPrivate,
                                      createdAt: DateTime.now(),
                                      beginning: DateTime.now(),
                                      end: DateTime.now().add(
                                        Duration(days: 10),
                                      ),
                                    );

                                    await vmodel.createEvent(
                                      context,
                                      event,
                                      imageFile: _coverImageFile,
                                    );

                                    if (!vmodel.hasError && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Event created successfully!",
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else if (vmodel.hasError &&
                                        context.mounted) {
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
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
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
