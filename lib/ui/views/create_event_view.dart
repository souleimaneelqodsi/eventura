import 'dart:io';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  DateTime? _selectedBeginningDate;
  TimeOfDay? _selectedBeginningTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  final ImagePicker _picker = ImagePicker();

  final DateFormat _dateFormatter = DateFormat('EEE, MMM d, yyyy');

  final DateFormat _timeFormatter = DateFormat.jm();

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

  Future<void> _selectDateTime(BuildContext context, bool isBeginning) async {
    final DateTime initialDate =
        (isBeginning ? _selectedBeginningDate : _selectedEndDate) ??
        DateTime.now();

    final TimeOfDay initialTime =
        (isBeginning ? _selectedBeginningTime : _selectedEndTime) ??
        TimeOfDay.fromDateTime(initialDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    setState(() {
      if (isBeginning) {
        _selectedBeginningDate = pickedDate;
        _selectedBeginningTime = pickedTime;
        if (_selectedEndDate != null && _selectedEndTime != null) {
          final beginningDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          final endDateTime = DateTime(
            _selectedEndDate!.year,
            _selectedEndDate!.month,
            _selectedEndDate!.day,
            _selectedEndTime!.hour,
            _selectedEndTime!.minute,
          );
          if (endDateTime.isBefore(beginningDateTime)) {
            _selectedEndDate = null;
            _selectedEndTime = null;
          }
        }
      } else {
        _selectedEndDate = pickedDate;
        _selectedEndTime = pickedTime;
      }
    });
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) {
      return 'Not set';
    }

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return '${_dateFormatter.format(dateTime)} at ${_timeFormatter.format(dateTime)}';
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        onChanged: (value) => description = value,
                        maxLines: 3,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Description cannot be empty'
                                    : null,
                      ),
                      const SizedBox(height: 16.0),
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
                      const SizedBox(height: 16.0),
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
                          final numValue = int.tryParse(value);
                          if (numValue == null) {
                            return 'Please enter a valid number';
                          }
                          if (numValue <= 0) {
                            return 'Capacity must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      Text(
                        "Beginning Time",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _formatDateTime(
                            _selectedBeginningDate,
                            _selectedBeginningTime,
                          ),
                        ),
                        onPressed: () => _selectDateTime(context, true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          alignment: Alignment.centerLeft,
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      Text(
                        "End Time",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _formatDateTime(_selectedEndDate, _selectedEndTime),
                        ),
                        onPressed: () => _selectDateTime(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          alignment: Alignment.centerLeft,
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      Text(
                        "Cover Image (Optional)",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      _coverImageFile == null
                          ? OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image_search),
                            label: const Text("Select Cover Image"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerLeft,
                              textStyle: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _coverImageFile!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.edit),
                                label: const Text("Change Image"),
                              ),
                            ],
                          ),
                      const SizedBox(height: 20.0),

                      SwitchListTile(
                        title: const Text("Private Event"),
                        value: isPrivate,
                        onChanged: (value) => setState(() => isPrivate = value),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            vmodel.isBusy
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedBeginningDate == null ||
                                        _selectedBeginningTime == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select a beginning date and time.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_selectedEndDate == null ||
                                        _selectedEndTime == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select an end date and time.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final beginningDateTime = DateTime(
                                      _selectedBeginningDate!.year,
                                      _selectedBeginningDate!.month,
                                      _selectedBeginningDate!.day,
                                      _selectedBeginningTime!.hour,
                                      _selectedBeginningTime!.minute,
                                    );

                                    final endDateTime = DateTime(
                                      _selectedEndDate!.year,
                                      _selectedEndDate!.month,
                                      _selectedEndDate!.day,
                                      _selectedEndTime!.hour,
                                      _selectedEndTime!.minute,
                                    );

                                    if (endDateTime.isBefore(
                                          beginningDateTime,
                                        ) ||
                                        endDateTime.isAtSameMomentAs(
                                          beginningDateTime,
                                        )) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'End time must be after beginning time.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

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
                                      beginning: beginningDateTime,
                                      end: endDateTime,
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
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Create Event",
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                      const SizedBox(height: 40),
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
