import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';

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
                  style: TextStyle(color: Colors.red, fontSize: 20),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Location",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          decorationColor: Colors.black,
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.title}",
                        style: TextStyle(color: Colors.black),
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
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          decorationColor: Colors.black,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " : ${event.description}",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
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
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
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
                                                    ? Text(vmodel.errorMessage!)
                                                    : Text(
                                                      "Event deleted successfully",
                                                    ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child:
                                        vmodel.isBusy
                                            ? CircularProgressIndicator()
                                            : Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
