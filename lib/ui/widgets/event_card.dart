import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final EventListViewmodel _ = Provider.of<EventListViewmodel>(
      context,
      listen: false,
    );

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final locationStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/event_detail", arguments: event.eventId);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.coverPicture != null && event.coverPicture!.isNotEmpty)
              Image.network(
                event.coverPicture!,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
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
                      height: 180,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[700],
                      ),
                    ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(color: Colors.grey[300]),
                alignment: Alignment.center,
                child: Icon(
                  Icons.event_seat,
                  size: 60,
                  color: Colors.grey[500],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (event.location.isNotEmpty)
                          Text(
                            event.location,
                            style: locationStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  Consumer<EventListViewmodel>(
                    builder: (context, vm, child) {
                      bool isFavorited = vm.isEventFavorited(event.eventId!);
                      return IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorited
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                          size: 28,
                        ),
                        onPressed: () {
                          vm.toggleFavoriteStatus(event.eventId!);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
