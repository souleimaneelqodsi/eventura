// import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:eventura/ui/widgets/activity_card.dart';
import 'package:eventura/ui/widgets/suggested_activity_tile.dart';
import 'package:eventura/ui/widgets/destructive_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EventDetailView extends StatefulWidget {
  final int eventId;
  const EventDetailView({required this.eventId, super.key});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final logger = Logger();
  final DateFormat _dateFormatter = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormatter = DateFormat.jm();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventVM = Provider.of<EventViewmodel>(context, listen: false);

      eventVM.loadEvent(widget.eventId, context);

      Provider.of<FriendsViewmodel>(
        context,
        listen: false,
      ).fetchFriendsAndRequests(
        Provider.of<AuthService>(context, listen: false).currentUser?.id ?? '',
        context,
      );
    });
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24.0,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  content,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<EventViewmodel>(
          builder: (context, vmodel, child) {
            return Text(vmodel.event?.title ?? "Event Details");
          },
        ),
        elevation: 1,
      ),
      body: Consumer<EventViewmodel>(
        builder: (context, vmodel, child) {
          if (vmodel.hasError && vmodel.event == null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
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
                      "An error occurred while loading event details: ${vmodel.errorMessage}",
                      style: TextStyle(color: AppColors.errorRed, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => vmodel.loadEvent(widget.eventId, context),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              ),
            );
          }
          if (vmodel.event == null ||
              vmodel.isParticipating == null ||
              vmodel.isOrganizer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = vmodel.event!;
          String formattedBeginning =
              "${_dateFormatter.format(event.beginning)} at ${_timeFormatter.format(event.beginning)}";
          String formattedEnd =
              "${_dateFormatter.format(event.end)} at ${_timeFormatter.format(event.end)}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.coverPicture != null &&
                    event.coverPicture!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      event.coverPicture!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 220,
                          alignment: Alignment.center,
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
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                    ),
                  ),
                if (event.coverPicture != null &&
                    event.coverPicture!.isNotEmpty)
                  const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        vmodel.isCurrentEventFavorited
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 28,
                      ),
                      color:
                          vmodel.isCurrentEventFavorited
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                      onPressed: () async {
                        await vmodel.toggleDetailFavoriteStatus(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  "Scheduled Activities",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (vmodel.acceptedActivities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        vmodel.isOrganizer == true
                            ? "No activities scheduled. Add some or accept suggestions!"
                            : "No activities scheduled yet.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vmodel.acceptedActivities.length,
                      itemBuilder: (context, index) {
                        final activity = vmodel.acceptedActivities[index];
                        return ActivityCard(
                          activity: activity,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/activity_detail',
                              arguments: {
                                'activityId': activity.activityId,
                                'eventViewModel': vmodel,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16.0),
                if (vmodel.isParticipating == true)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Suggest an Activity"),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/create_activity',
                          arguments: {
                            'eventId': event.eventId,
                            'eventViewModel': vmodel,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                if (vmodel.isOrganizer == true) ...[
                  Divider(thickness: 1, height: 32, indent: 20, endIndent: 20),
                  Text(
                    "Pending Suggestions (${vmodel.pendingSuggestedActivities.length})",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (vmodel.pendingSuggestedActivities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          "No pending suggestions.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vmodel.pendingSuggestedActivities.length,
                      itemBuilder: (context, index) {
                        final suggestedActivity =
                            vmodel.pendingSuggestedActivities[index];

                        return SuggestedActivityTile(
                          activity: suggestedActivity,
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],

                Divider(thickness: 1, height: 32),

                _buildDetailItem(
                  icon: Icons.calendar_today_outlined,
                  title: "Event Starts",
                  content: formattedBeginning,
                ),
                _buildDetailItem(
                  icon: Icons.event_available_outlined,
                  title: "Event Ends",
                  content: formattedEnd,
                ),
                if (event.description.isNotEmpty)
                  _buildDetailItem(
                    icon: Icons.description_outlined,
                    title: "Event Description",
                    content: event.description,
                  ),
                _buildDetailItem(
                  icon: Icons.people_alt_outlined,
                  title: "Capacity",
                  content: "${event.nbGuests} / ${event.capacity} guests",
                ),
                _buildDetailItem(
                  icon:
                      event.isPrivate
                          ? Icons.lock_outline
                          : Icons.public_outlined,
                  title: "Privacy",
                  content: event.isPrivate ? "Private Event" : "Public Event",
                ),

                Divider(thickness: 1, height: 32),
                const SizedBox(height: 8),

                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vmodel.isParticipating == true &&
                          vmodel.isOrganizer == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Add a Friend to Event'),
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (vmodel.isOrganizer == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Invite Friend to Event'),
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (vmodel.isPublic == true &&
                          vmodel.isParticipating == false &&
                          vmodel.isOrganizer == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login_outlined),
                            label: const Text('Join Event'),
                            onPressed:
                                vmodel.isBusy
                                    ? null
                                    : () async {
                                      await vmodel.joinPublicEvent(
                                        widget.eventId,
                                        context,
                                      );
                                    },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (vmodel.isParticipating == true &&
                          vmodel.isOrganizer == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout_outlined),
                            label: const Text('Leave Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warningOrange,
                              foregroundColor: AppColors.onWarningOrange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed:
                                vmodel.isBusy
                                    ? null
                                    : () async {
                                      await vmodel.leaveEvent(
                                        widget.eventId,
                                        context,
                                      );
                                    },
                          ),
                        ),
                      if (vmodel.isOrganizer == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DestructiveButton(
                            icon: Icons.delete_outline,
                            label: "Delete Event",
                            isLoading: vmodel.isBusy,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Delete Event?"),
                                      content: const Text(
                                        "Are you sure you want to delete this event? This will also delete all its activities and suggestions.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        DestructiveButton(
                                          icon: Icons.delete_forever,
                                          label: "Delete",
                                          isLoading: vmodel.isBusy,
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await vmodel.deleteEvent(
                                              context,
                                              vmodel.event!.eventId!,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add friend to event",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Search your friends to add them to this event.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SearchAnchor.bar(
                      barHintText: "Search your friends",
                      barElevation: WidgetStateProperty.all(0.0),
                      barBackgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
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
                                child: Text("Type to search your friends"),
                              ),
                            ),
                          ];
                        }

                        final List<UserModel?> filteredFriends =
                            friendsViewmodel.friends.values.where((friend) {
                              if (friend == null) return false;
                              final String fullName =
                                  "${friend.firstName ?? ''} ${friend.lastName ?? ''}"
                                      .toLowerCase();
                              return friend.email.toLowerCase().contains(
                                    query,
                                  ) ||
                                  fullName.contains(query);
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
                              (user) => ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      (user!.profilePicture != null &&
                                              user.profilePicture!.isNotEmpty)
                                          ? NetworkImage(user.profilePicture!)
                                          : null,
                                  child:
                                      (user.profilePicture == null ||
                                              user.profilePicture!.isEmpty)
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(
                                  '${user.firstName} ${user.lastName}',
                                ),
                                subtitle: Text(user.email),
                                onTap: () {
                                  controller.closeView(null);
                                  _confirmAddFriendToEvent(
                                    context,
                                    vmodel,
                                    eventId,
                                    user,
                                  );
                                },
                              ),
                            )
                            .toList();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
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
            content: const Text(
              "They will be notified if the event is private and they are not already a guest.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    vmodel.isBusy
                        ? null
                        : () async {
                          Navigator.pop(context);

                          await vmodel.addFriendToEvent(
                            user.userId,
                            eventId,
                            context,
                          );
                        },
                child:
                    vmodel.isBusy
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}
