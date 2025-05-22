enum ActivityStatus { pendingSuggestion, accepted, organizerCreated, rejected }

String activityStatusToString(ActivityStatus status) {
  switch (status) {
    case ActivityStatus.pendingSuggestion:
      return 'pending_suggestion';
    case ActivityStatus.accepted:
      return 'accepted';
    case ActivityStatus.organizerCreated:
      return 'organizer_created';
    case ActivityStatus.rejected:
      return 'rejected';
  }
}

ActivityStatus activityStatusFromString(String status) {
  switch (status) {
    case 'pending_suggestion':
      return ActivityStatus.pendingSuggestion;
    case 'accepted':
      return ActivityStatus.accepted;
    case 'organizer_created':
      return ActivityStatus.organizerCreated;
    case 'rejected':
      return ActivityStatus.rejected;
    default:
      return ActivityStatus.organizerCreated;
  }
}

class ActivityModel {
  final int? activityId;
  final int eventId;
  final String? title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final ActivityStatus status;
  final String? suggesterId;
  final DateTime? createdAt;

  ActivityModel({
    this.activityId,
    required this.eventId,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.location,
    required this.status,
    this.suggesterId,
    this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'] as int?,
      eventId: json['event_id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      startTime:
          json['start_time'] == null
              ? null
              : DateTime.parse(json['start_time'] as String),
      endTime:
          json['end_time'] == null
              ? null
              : DateTime.parse(json['end_time'] as String),
      location: json['location'] as String?,
      status: activityStatusFromString(json['status'] as String),
      suggesterId: json['suggester_id'] as String?,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'event_id': eventId,
      'title': title,
      'description': description,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'status': activityStatusToString(status),
      'suggester_id': suggesterId,
    };
    if (activityId != null) {
      data['activity_id'] = activityId;
    }
    return data;
  }

  ActivityModel copyWith({
    int? activityId,
    int? eventId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    ActivityStatus? status,
    String? suggesterId,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      activityId: activityId ?? this.activityId,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      status: status ?? this.status,
      suggesterId: suggesterId ?? this.suggesterId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
