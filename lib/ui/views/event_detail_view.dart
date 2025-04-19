import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';

import 'package:eventura/ui/widgets/destructive_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EventViewmodel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadEvent(eventId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),
      body: Consumer<EventViewmodel>(
        builder: (context, vmodel, child) {
          if (vmodel.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "An error occurred: ${vmodel.errorMessage}",
                  style: TextStyle(color: AppColors.errorRed, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (vmodel.event == null) {
            return const Center(child: Text("This event does not exist."));
          }
          final event = vmodel.event!;
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Location",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.title}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Description",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.description}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DestructiveButton(
                      icon: Icons.delete,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Delete?"),
                                content: const Text(
                                  "Are you sure you want to delete this event?",
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: DestructiveButton(
                                      icon: Icons.delete,
                                      onPressed: () async {
                                        await vmodel.deleteEvent(
                                          context,
                                          vmodel.event!.eventId!,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content:
                                                  vmodel.hasError
                                                      ? Text(
                                                        vmodel.errorMessage!,
                                                      )
                                                      : Text(
                                                        "Event deleted successfully",
                                                      ),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      },
                                      label: "Delete",
                                      isLoading: vmodel.isBusy,
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      label: "Delete",
                      isLoading: vmodel.isBusy,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
