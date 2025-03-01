class UserModel {

  final String userId; 
  final bool? genre; 
  final String? profilePicture; // URL to the profile picture
  final String? timezone;
  final String? language;
  final String? userRole; // "user", "admin", "organizer"
  final String? accStatus; //"active", "inactive", "banned"
  final DateTime? lastLogin;
  final bool? firstLogin;
  final Map<String, dynamic>? notificationsPreferences;
  final String? firstName;
  final String? lastName;
  final DateTime? birthday;
  final String? email;
  final String? phoneNumber;
  final String? socials; 
  final int? gold;
  final String? bio;
  final Map<String, dynamic>? allergies; 
  final String? membershipLevel;

  UserModel({
    required this.userId,
    this.genre,
    this.profilePicture,
    this.timezone,
    this.language,
    this.userRole,
    this.accStatus,
    this.lastLogin,
    this.firstLogin,
    this.notificationsPreferences,
    this.firstName,
    this.lastName,
    this.birthday,
    required this.email,
    this.phoneNumber,
    this.socials,
    this.gold,
    this.bio,
    this.allergies,
    this.membershipLevel,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      genre: json['genre'] as bool?,
      profilePicture: json['profile_picture'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      userRole: json['user_role'] as String?,
      accStatus: json['acc_status'] as String?,
      lastLogin: json['last_login'] == null ? null : DateTime.parse(json['last_login'] as String),
      firstLogin: json['first_login'] as bool?,
      notificationsPreferences: json['notifications_preferences'] as Map<String, dynamic>?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      birthday: json['birthday'] == null ? null : DateTime.parse(json['birthday'] as String),
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      socials: json['socials'] as String?,
      gold: json['gold'] as int?,
      bio: json['bio'] as String?,
      allergies: json['allergies'] as Map<String, dynamic>?,
      membershipLevel: json['membership_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId, 
      'genre': genre,
      'profile_picture': profilePicture,
      'timezone': timezone,
      'language': language,
      'user_role': userRole,
      'acc_status': accStatus,
      'last_login': lastLogin?.toIso8601String(), 
      'first_login': firstLogin,
      'notifications_preferences': notificationsPreferences,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday?.toIso8601String(), 
      'email': email,
      'phone_number': phoneNumber,
      'socials': socials,
      'gold': gold,
      'bio': bio,
      'allergies': allergies,
      'membership_level': membershipLevel,
    };
  }
    UserModel copyWith({
    String? userId,
    bool? genre,
    String? profilePicture,
    String? timezone,
    String? language,
    String? userRole,
    String? accStatus,
    DateTime? lastLogin,
    bool? firstLogin,
    Map<String, dynamic>? notificationsPreferences,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? email,
    String? phoneNumber,
    String? socials,
    int? gold,
    String? bio,
    Map<String, dynamic>? allergies,
    String? membershipLevel,
    }) {
    return UserModel(
    userId: userId ?? this.userId,
    genre: genre ?? this.genre,
    profilePicture: profilePicture ?? this.profilePicture,
    timezone: timezone ?? this.timezone,
    language: language ?? this.language,
    userRole: userRole ?? this.userRole,
    accStatus: accStatus ?? this.accStatus,
    lastLogin: lastLogin ?? this.lastLogin,
    firstLogin: firstLogin ?? this.firstLogin,
    notificationsPreferences: notificationsPreferences ?? this.notificationsPreferences,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    birthday: birthday ?? this.birthday,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    socials: socials ?? this.socials,
    gold: gold ?? this.gold,
    bio: bio ?? this.bio,
    allergies: allergies ?? this.allergies,
    membershipLevel: membershipLevel ?? this.membershipLevel,
    );
    }
}