import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SuggestedActivityTile extends StatelessWidget {
  final ActivityModel activity;

  const SuggestedActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final eventViewModel = Provider.of<EventViewmodel>(context, listen: false);
    final DateFormat timeFormatter = DateFormat.jm();
    final DateFormat dateFormatter = DateFormat('MMM d');

    String formattedTime = "Time not set";
    if (activity.startTime != null && activity.endTime != null) {
      formattedTime =
          "${dateFormatter.format(activity.startTime!)}: ${timeFormatter.format(activity.startTime!)} - ${timeFormatter.format(activity.endTime!)}";
    } else if (activity.startTime != null) {
      formattedTime =
          "${dateFormatter.format(activity.startTime!)} at ${timeFormatter.format(activity.startTime!)}";
    }

    bool isCurrentUserTheSuggester =
        activity.suggesterId == eventViewModel.currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.title ?? 'Untitled Suggestion',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (activity.location != null && activity.location!.isNotEmpty)
              Text(
                "Location: ${activity.location}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              "Proposed: $formattedTime",
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (eventViewModel.isOrganizer == true &&
                    !isCurrentUserTheSuggester) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.successGreen,
                    ),
                    tooltip: "Accept Suggestion",
                    onPressed:
                        eventViewModel.isBusy
                            ? null
                            : () async {
                              await eventViewModel.acceptActivitySuggestion(
                                activity,
                              );

                              if (context.mounted && !eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Suggestion accepted!"),
                                  ),
                                );
                              } else if (context.mounted &&
                                  eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error: ${eventViewModel.errorMessage}",
                                    ),
                                  ),
                                );
                              }
                            },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.errorRed,
                    ),
                    tooltip: "Reject Suggestion",
                    onPressed:
                        eventViewModel.isBusy
                            ? null
                            : () async {
                              await eventViewModel.rejectActivitySuggestion(
                                activity,
                              );
                              if (context.mounted && !eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Suggestion rejected."),
                                  ),
                                );
                              } else if (context.mounted &&
                                  eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error: ${eventViewModel.errorMessage}",
                                    ),
                                  ),
                                );
                              }
                            },
                  ),
                ],
                if (isCurrentUserTheSuggester &&
                    activity.status == ActivityStatus.pendingSuggestion)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: "Retract Suggestion",
                    onPressed:
                        eventViewModel.isBusy
                            ? null
                            : () async {
                              if (activity.activityId == null) return;
                              await eventViewModel.retractActivitySuggestion(
                                activity.activityId!,
                              );
                              if (context.mounted && !eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Suggestion retracted."),
                                  ),
                                );
                              } else if (context.mounted &&
                                  eventViewModel.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error: ${eventViewModel.errorMessage}",
                                    ),
                                  ),
                                );
                              }
                            },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
