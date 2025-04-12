class FriendshipModel {
  int friendshipId;
  String userId1;
  String userId2;
  String status;
  String createdAt;

  FriendshipModel({
    required this.friendshipId,
    required this.userId1,
    required this.userId2,
    required this.status,
    required this.createdAt,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) throw Exception('FriendshipModel.fromJson: Invalid JSON');

    String createdAtStr;
    if (json['created_at'] is String) {
      createdAtStr = json['created_at'];
    } else {
      createdAtStr = json['created_at'].toString();
    }

    final DateTime createdAtDateTime = DateTime.parse(createdAtStr);
    final formattedDate =
        "${createdAtDateTime.year}-${createdAtDateTime.month.toString().padLeft(2, '0')}-${createdAtDateTime.day.toString().padLeft(2, '0')}";

    return FriendshipModel(
      friendshipId: json['friendship_id'] as int,
      userId1: json['user_id_1'] as String,
      userId2: json['user_id_2'] as String,
      status: json['status'] as String,
      createdAt: formattedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id_1': userId1, 'user_id_2': userId2, 'status': status};
  }
}
