class Event {
  final int? eventId;
  final int organizerId;
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

  // Convertir un JSON en objet Event
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      organizerId: json['organizer_id'],
      coverPicture: json['cover_picture'],
      dateOfBeginning: DateTime.parse(json['date_of_beginning']),
      title: json['title'],
      description: json['description'],
      location: json['location'],
      capacity: json['capacity'],
      isPrivate: json['is_private'] == 1, // Stocké en int (1/0)
    );
  }

  // Convertir un objet Event en JSON
  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'organizer_id': organizerId,
      'cover_picture': coverPicture,
      'date_of_beginning': dateOfBeginning.toIso8601String(),
      'title': title,
      'description': description,
      'location': location,
      'capacity': capacity,
      'is_private': isPrivate ? 1 : 0, // Stocké en int (1/0)
    };
  }
}
