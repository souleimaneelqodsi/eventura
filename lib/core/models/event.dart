class Event {
  final int? eventId;
  final String organizerId;
  final String? coverPicture;
  final DateTime dateOfBeginning;
  final String title;
  final String description;
  final String location;
  final int capacity;
  final bool isPrivate;

  Event({
    this.eventId,
    required this.organizerId,
    this.coverPicture,
    required this.dateOfBeginning,
    required this.title,
    required this.description,
    required this.location,
    required this.capacity,
    required this.isPrivate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] as int?,
      organizerId: json['organizer_id'] as String,
      coverPicture: json['cover_picture'] as String?,
      dateOfBeginning: DateTime.parse(json['date_of_beginning'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as int,
      isPrivate: (json['is_private'] as bool),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'organizer_id': organizerId,
      'cover_picture': coverPicture,
      'date_of_beginning': dateOfBeginning.toIso8601String(),
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
    DateTime? dateOfBeginning,
    String? title,
    String? description,
    String? location,
    int? capacity,
    bool? isPrivate,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      organizerId: organizerId ?? this.organizerId,
      coverPicture: coverPicture ?? this.coverPicture,
      dateOfBeginning: dateOfBeginning ?? this.dateOfBeginning,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
