import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:eventura/ui/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key});

  @override
  EventListViewState createState() => EventListViewState();
}

class EventListViewState extends State<EventListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventListViewmodel>(
      builder: (context, vmodel, child) {
        if (vmodel.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${vmodel.errorMessage!}",
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vmodel.refreshEvents(),
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }
        if (vmodel.events.isEmpty) {
          return Center(
            child: Text(
              "No events found",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => vmodel.refreshEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vmodel.events.length,
            itemBuilder: (context, index) {
              final event = vmodel.events[index];
              return EventCard(event: event);
            },
          ),
        );
      },
    );
  }
}
