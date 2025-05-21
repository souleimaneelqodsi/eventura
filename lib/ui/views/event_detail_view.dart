import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/ui/shared/app_colors.dart';

import 'package:eventura/ui/widgets/destructive_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';

class EventDetailView extends StatefulWidget {
  final int eventId;

  const EventDetailView({required this.eventId, super.key});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventViewmodel>(
        context,
        listen: false,
      ).loadEvent(widget.eventId, context);

      Provider.of<FriendsViewmodel>(
        context,
        listen: false,
      ).fetchFriendsAndRequests(
        Provider.of<AuthService>(context, listen: false).currentUser!.id,
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          if (vmodel.event == null ||
              vmodel.isParticipating == null ||
              vmodel.isPublic == null ||
              vmodel.isOrganizer == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final event = vmodel.event!;
          final isParticipating = vmodel.isParticipating!;
          final isPublic = vmodel.isPublic!;
          final isOrganizer = vmodel.isOrganizer!;

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.coverPicture != null &&
                      event.coverPicture!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        event.coverPicture!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            ),
                      ),
                    ),
                  if (event.coverPicture != null &&
                      event.coverPicture!.isNotEmpty)
                    const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        IconButton(
                          icon: Icon(
                            vmodel.isCurrentEventFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color:
                              vmodel.isCurrentEventFavorited
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                          onPressed: () async {
                            await vmodel.toggleDetailFavoriteStatus(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Location",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " : ${event.location}",
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
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

                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isParticipating || isOrganizer)
                          ElevatedButton(
                            onPressed:
                                vmodel.isBusy
                                    ? null
                                    : () {
                                      _showAddFriendToEventDialog(
                                        context,
                                        vmodel,
                                        event.eventId!,
                                      );
                                    },
                            child:
                                vmodel.isBusy
                                    ? const CircularProgressIndicator()
                                    : const Text('Add a friend'),
                          ),
                        const SizedBox(height: 8),

                        if (isPublic && !isParticipating && !isOrganizer)
                          ElevatedButton(
                            onPressed:
                                vmodel.isBusy
                                    ? null
                                    : () async {
                                      await vmodel.joinPublicEvent(
                                        widget.eventId,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                vmodel.hasError
                                                    ? Text(vmodel.errorMessage!)
                                                    : const Text(
                                                      "Joined event successfully!",
                                                    ),
                                          ),
                                        );
                                        if (!vmodel.hasError) {
                                          vmodel.loadEvent(
                                            widget.eventId,
                                            context,
                                          );
                                        }
                                      }
                                    },
                            child:
                                vmodel.isBusy
                                    ? const CircularProgressIndicator()
                                    : const Text('Join Event'),
                          ),
                        const SizedBox(height: 8),

                        if (isParticipating && !isOrganizer)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warningOrange,
                              foregroundColor: AppColors.onWarningOrange,
                            ),
                            onPressed:
                                vmodel.isBusy
                                    ? null
                                    : () async {
                                      await vmodel.leaveEvent(widget.eventId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                vmodel.hasError
                                                    ? Text(vmodel.errorMessage!)
                                                    : const Text(
                                                      "Left event successfully",
                                                    ),
                                          ),
                                        );
                                        if (!vmodel.hasError) {
                                          vmodel.loadEvent(
                                            widget.eventId,
                                            context,
                                          );
                                        }
                                      }
                                    },
                            child:
                                vmodel.isBusy
                                    ? const CircularProgressIndicator()
                                    : const Text('Leave event'),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (isOrganizer)
                    Center(
                      child: DestructiveButton(
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
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddFriendToEventDialog(
    BuildContext context,
    EventViewmodel vmodel,
    int eventId,
  ) {
    final friendsViewmodel = Provider.of<FriendsViewmodel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add friend to event",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Search your friends by email to add them to this event.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SearchAnchor.bar(
                      barHintText: "Search your friends",
                      viewConstraints: const BoxConstraints(maxHeight: 300),
                      viewBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      viewElevation: 4.0,
                      suggestionsBuilder: (
                        BuildContext context,
                        SearchController controller,
                      ) async {
                        final query = controller.value.text.toLowerCase();

                        if (query.isEmpty) {
                          return [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Search your friends"),
                              ),
                            ),
                          ];
                        }

                        final List<UserModel?> filteredFriends =
                            friendsViewmodel.friends.values.where((friend) {
                              if (friend == null) return false;

                              return friend.email.toLowerCase().contains(
                                    query,
                                  ) ||
                                  (friend.firstName?.toLowerCase().contains(
                                        query,
                                      ) ??
                                      false) ||
                                  (friend.lastName?.toLowerCase().contains(
                                        query,
                                      ) ??
                                      false);
                            }).toList();

                        if (filteredFriends.isEmpty) {
                          return [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No friends found matching your search",
                                ),
                              ),
                            ),
                          ];
                        }

                        return filteredFriends
                            .map(
                              (user) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  title: Text(
                                    '${user!.firstName} ${user.lastName}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Text(user.email),
                                  onTap: () {
                                    Navigator.pop(context, user);
                                  },
                                ),
                              ),
                            )
                            .toList();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
    ).then((selectedUser) {
      if (selectedUser != null && selectedUser is UserModel) {
        _confirmAddFriendToEvent(context, vmodel, eventId, selectedUser);
      }
    });
  }

  void _confirmAddFriendToEvent(
    BuildContext context,
    EventViewmodel vmodel,
    int eventId,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Add ${user.firstName} ${user.lastName} to this event?',
            ),
            actions: [
              TextButton(
                onPressed:
                    vmodel.isBusy
                        ? null
                        : () async {
                          Navigator.pop(context);

                          await vmodel.addFriendToEvent(user.userId, eventId);

                          if (context.mounted) {
                            if (!vmodel.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${user.firstName} ${user.lastName} to the event!',
                                  ),
                                ),
                              );

                              vmodel.loadEvent(eventId, context);

                              Navigator.of(context, rootNavigator: true).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to add ${user.firstName} ${user.lastName} to the event: ${vmodel.errorMessage}',
                                  ),
                                ),
                              );
                              vmodel.setError(null);
                            }
                          }
                        },
                child:
                    vmodel.isBusy
                        ? const CircularProgressIndicator()
                        : const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
            ],
          ),
    );
  }
}
