class User {
  final String id;
  final String name;
  final String email;
  final String profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'Utilisateur inconnu',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
    };
  }
}
