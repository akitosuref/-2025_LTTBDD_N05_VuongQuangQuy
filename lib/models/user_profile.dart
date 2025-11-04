class UserProfile {
  final String name;
  final String email;
  final String? phone;
  final String? avatarPath;

  UserProfile({
    required this.name,
    required this.email,
    this.phone,
    this.avatarPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatarPath': avatarPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarPath: json['avatarPath'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
