import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/viewmodels/activity_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityDetailView extends StatefulWidget {
  final int activityId;

  const ActivityDetailView({super.key, required this.activityId});

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  final DateFormat _dateFormatter = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormatter = DateFormat.jm();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityViewModel>(
        context,
        listen: false,
      ).loadActivity(widget.activityId);
    });
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityViewModel>(
      builder: (context, viewModel, child) {
        final activity = viewModel.activity;

        if (viewModel.isBusy && activity == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (viewModel.hasError && activity == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Text("Error loading activity: ${viewModel.errorMessage}"),
            ),
          );
        }
        if (activity == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Activity not found.")),
          );
        }

        String startTimeStr = "Not set";
        String endTimeStr = "Not set";
        if (activity.startTime != null) {
          startTimeStr =
              "${_dateFormatter.format(activity.startTime!)} at ${_timeFormatter.format(activity.startTime!)}";
        }
        if (activity.endTime != null) {
          endTimeStr =
              "${_dateFormatter.format(activity.endTime!)} at ${_timeFormatter.format(activity.endTime!)}";
        }

        return Scaffold(
          appBar: AppBar(title: Text(activity.title ?? "Activity Details")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title ?? "Untitled Activity",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (activity.status == ActivityStatus.pendingSuggestion)
                  Chip(
                    label: const Text("Pending Suggestion"),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                if (activity.status == ActivityStatus.accepted ||
                    activity.status == ActivityStatus.organizerCreated)
                  Chip(
                    label: const Text("Accepted"),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                const SizedBox(height: 24),

                _buildDetailRow(
                  context,
                  Icons.schedule_outlined,
                  "Starts",
                  startTimeStr,
                ),
                _buildDetailRow(
                  context,
                  Icons.update_outlined,
                  "Ends",
                  endTimeStr,
                ),
                if (activity.location != null && activity.location!.isNotEmpty)
                  _buildDetailRow(
                    context,
                    Icons.location_on_outlined,
                    "Location",
                    activity.location!,
                  ),
                if (activity.description != null &&
                    activity.description!.isNotEmpty)
                  _buildDetailRow(
                    context,
                    Icons.description_outlined,
                    "Description",
                    activity.description!,
                  ),

                const SizedBox(height: 30),

                if (viewModel.isCurrentUserEventOrganizer &&
                    activity.status == ActivityStatus.pendingSuggestion)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Organizer Actions:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Accept Suggestion"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed:
                            viewModel.isBusy
                                ? null
                                : () async {
                                  bool success = await viewModel
                                      .acceptSuggestion(context);
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Suggestion accepted!"),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else if (mounted && viewModel.hasError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error: ${viewModel.errorMessage}",
                                        ),
                                      ),
                                    );
                                  }
                                },
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text("Reject Suggestion"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                          side: BorderSide(color: AppColors.errorRed),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed:
                            viewModel.isBusy
                                ? null
                                : () async {
                                  bool success = await viewModel
                                      .rejectSuggestion(context);
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Suggestion rejected and removed.",
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else if (mounted && viewModel.hasError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error: ${viewModel.errorMessage}",
                                        ),
                                      ),
                                    );
                                  }
                                },
                      ),
                    ],
                  ),

                if (viewModel.isCurrentUserSuggester &&
                    activity.status == ActivityStatus.pendingSuggestion)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Retract Suggestion"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        onPressed:
                            viewModel.isBusy
                                ? null
                                : () async {
                                  bool success = await viewModel
                                      .retractSuggestion(context);
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Suggestion retracted."),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else if (mounted && viewModel.hasError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error: ${viewModel.errorMessage}",
                                        ),
                                      ),
                                    );
                                  }
                                },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
