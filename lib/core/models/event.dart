class Event {
  final int? eventId;
  final String organizerId;
  final String? coverPicture;

  final DateTime createdAt;
  final DateTime beginning;
  final DateTime end;
  final String title;
  final String description;
  final String location;
  final int capacity;
  final bool isPrivate;
  final int nbGuests;

  Event({
    this.eventId,
    required this.organizerId,
    this.coverPicture,

    required this.createdAt,
    required this.beginning,
    required this.end,
    required this.title,
    required this.description,
    required this.location,
    required this.capacity,
    required this.isPrivate,
    required this.nbGuests,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] as int?,
      organizerId: json['organizer_id'] as String,
      coverPicture: json['cover_picture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      beginning: DateTime.parse(json['beginning'] as String),
      end: DateTime.parse(json['end'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as int,
      isPrivate: (json['is_private'] as bool),
      nbGuests: json['nb_guests'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'organizer_id': organizerId,
      'cover_picture': coverPicture,
      'beginning': beginning.toIso8601String(),
      'end': end.toIso8601String(),
      'title': title,
      'description': description,
      'location': location,
      'capacity': capacity,
      'is_private': isPrivate,
    };
    if (eventId != null) {
      data['event_id'] = eventId;
    }

    return data;
  }

  Event copyWith({
    int? eventId,
    String? organizerId,
    String? coverPicture,

    DateTime? createdAt,
    DateTime? beginning,
    DateTime? end,
    String? title,
    String? description,
    String? location,
    int? capacity,
    bool? isPrivate,
    int? nbGuests,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      organizerId: organizerId ?? this.organizerId,
      coverPicture: coverPicture ?? this.coverPicture,

      createdAt: createdAt ?? this.createdAt,
      beginning: beginning ?? this.beginning,
      end: end ?? this.end,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      isPrivate: isPrivate ?? this.isPrivate,
      nbGuests: nbGuests ?? this.nbGuests,
    );
  }
}
