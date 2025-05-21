import 'dart:convert';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    required this.lastLogin,
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  String serialize() {
    return jsonEncode(toJson());
  }

  factory UserProfile.deserialize(String data) {
    return UserProfile.fromJson(jsonDecode(data));
  }
}