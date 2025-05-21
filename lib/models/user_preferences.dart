import 'dart:convert';

class UserPreferences {
  final List<int> favoriteMovieIds;
  final List<int> favoriteTvShowIds;
  final List<String> preferredGenres;
  final bool darkMode;

  UserPreferences({
    this.favoriteMovieIds = const [],
    this.favoriteTvShowIds = const [],
    this.preferredGenres = const [],
    this.darkMode = true,
  });

  UserPreferences copyWith({
    List<int>? favoriteMovieIds,
    List<int>? favoriteTvShowIds,
    List<String>? preferredGenres,
    bool? darkMode,
  }) {
    return UserPreferences(
      favoriteMovieIds: favoriteMovieIds ?? this.favoriteMovieIds,
      favoriteTvShowIds: favoriteTvShowIds ?? this.favoriteTvShowIds,
      preferredGenres: preferredGenres ?? this.preferredGenres,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteMovieIds': favoriteMovieIds,
      'favoriteTvShowIds': favoriteTvShowIds,
      'preferredGenres': preferredGenres,
      'darkMode': darkMode,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      favoriteMovieIds: List<int>.from(json['favoriteMovieIds'] ?? []),
      favoriteTvShowIds: List<int>.from(json['favoriteTvShowIds'] ?? []),
      preferredGenres: List<String>.from(json['preferredGenres'] ?? []),
      darkMode: json['darkMode'] ?? true,
    );
  }

  String serialize() {
    return jsonEncode(toJson());
  }

  factory UserPreferences.deserialize(String data) {
    return UserPreferences.fromJson(jsonDecode(data));
  }
}