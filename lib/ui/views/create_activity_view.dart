import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

class CreateActivityView extends StatefulWidget {
  final int eventId;
  final EventViewmodel eventViewModel;

  const CreateActivityView({
    super.key,
    required this.eventId,
    required this.eventViewModel,
  });

  @override
  State<CreateActivityView> createState() => _CreateActivityViewState();
}

class _CreateActivityViewState extends State<CreateActivityView> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _description = "";
  String _location = "";
  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  final DateFormat _dateFormatter = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormatter = DateFormat.jm();

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final EventViewmodel eventVM = widget.eventViewModel;
    final DateTime eventBeginning = eventVM.event?.beginning ?? DateTime.now();
    final DateTime eventEnd =
        eventVM.event?.end ?? DateTime.now().add(const Duration(days: 30));

    DateTime initialDatePickerDate = DateTime.now();
    if (isStart) {
      initialDatePickerDate = _selectedStartDate ?? eventBeginning;
    } else {
      initialDatePickerDate =
          _selectedEndDate ?? _selectedStartDate ?? eventBeginning;
    }

    if (initialDatePickerDate.isBefore(eventBeginning)) {
      initialDatePickerDate = eventBeginning;
    }

    if (initialDatePickerDate.isAfter(eventEnd)) {
      initialDatePickerDate = eventEnd;
    }

    final TimeOfDay initialTimePickerTime =
        (isStart ? _selectedStartTime : _selectedEndTime) ?? TimeOfDay.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: eventBeginning,
      lastDate: eventEnd,
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTimePickerTime,
    );

    if (pickedTime == null) return;

    setState(() {
      if (isStart) {
        _selectedStartDate = pickedDate;
        _selectedStartTime = pickedTime;

        if (_selectedEndDate != null && _selectedEndTime != null) {
          final startDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          final currentEndDateTime = DateTime(
            _selectedEndDate!.year,
            _selectedEndDate!.month,
            _selectedEndDate!.day,
            _selectedEndTime!.hour,
            _selectedEndTime!.minute,
          );
          if (currentEndDateTime.isBefore(startDateTime)) {
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

  String _formatDateTimeDisplay(DateTime? date, TimeOfDay? time) {
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

  void _submitActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedStartDate == null || _selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a start date and time for the activity.',
          ),
        ),
      );
      return;
    }
    if (_selectedEndDate == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an end date and time for the activity.'),
        ),
      );
      return;
    }

    final activityStartTime = DateTime(
      _selectedStartDate!.year,
      _selectedStartDate!.month,
      _selectedStartDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );
    final activityEndTime = DateTime(
      _selectedEndDate!.year,
      _selectedEndDate!.month,
      _selectedEndDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    if (activityEndTime.isBefore(activityStartTime) ||
        activityEndTime.isAtSameMomentAs(activityStartTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity end time must be after its start time.'),
        ),
      );
      return;
    }

    final EventViewmodel eventVM = widget.eventViewModel;
    if (eventVM.event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Parent event details not available.'),
        ),
      );
      return;
    }
    if (activityStartTime.isBefore(eventVM.event!.beginning) ||
        activityEndTime.isAfter(eventVM.event!.end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activity times must be within the main event\'s start and end times.',
          ),
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    final newActivity = ActivityModel(
      eventId: widget.eventId,
      title: _title,
      description: _description,
      location: _location,
      startTime: activityStartTime,
      endTime: activityEndTime,

      status: ActivityStatus.pendingSuggestion,
      suggesterId: eventVM.currentUserId,
    );

    await eventVM.suggestActivity(newActivity);

    if (mounted) {
      if (eventVM.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error suggesting activity: ${eventVM.errorMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity suggested successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventVM = widget.eventViewModel;
    final String eventDateRangeInfo =
        eventVM.event != null
            ? "Event from: ${_dateFormatter.format(eventVM.event!.beginning)} to ${_dateFormatter.format(eventVM.event!.end)}"
            : "Loading event details...";

    return Scaffold(
      appBar: AppBar(title: const Text('Suggest New Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                eventDateRangeInfo,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Activity Title*'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter a title'
                            : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location*'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter a location'
                            : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 20),

              Text(
                "Activity Start Time*",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _formatDateTimeDisplay(
                    _selectedStartDate,
                    _selectedStartTime,
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
              const SizedBox(height: 16),

              Text(
                "Activity End Time*",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _formatDateTimeDisplay(_selectedEndDate, _selectedEndTime),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: eventVM.isBusy ? null : _submitActivity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    eventVM.isBusy
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Suggest Activity',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
