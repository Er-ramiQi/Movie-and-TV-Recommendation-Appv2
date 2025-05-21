class TvShow {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String firstAirDate;
  final List<String>? genres;
  final int? numberOfSeasons;
  final List<Cast>? cast;
  final String? trailerKey;
  final List<TvShow>? similarShows;

  TvShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.firstAirDate,
    this.genres,
    this.numberOfSeasons,
    this.cast,
    this.trailerKey,
    this.similarShows,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
    );
  }

  factory TvShow.fromDetailJson(Map<String, dynamic> json) {
    List<Cast>? castList;
    if (json['credits'] != null && json['credits']['cast'] != null) {
      castList = (json['credits']['cast'] as List)
          .take(10)
          .map((cast) => Cast.fromJson(cast))
          .toList();
    }

    String? trailerKey;
    if (json['videos'] != null && json['videos']['results'] != null) {
      final videos = json['videos']['results'] as List;
      final trailers = videos.where((video) => 
          video['type'] == 'Trailer' && 
          video['site'] == 'YouTube').toList();
      
      if (trailers.isNotEmpty) {
        trailerKey = trailers.first['key'];
      }
    }

    List<TvShow>? similarShows;
    if (json['similar'] != null && json['similar']['results'] != null) {
      similarShows = (json['similar']['results'] as List)
          .take(6)
          .map((show) => TvShow.fromJson(show))
          .toList();
    }

    return TvShow(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      genres: json['genres'] != null 
          ? (json['genres'] as List).map((genre) => genre['name'] as String).toList() 
          : null,
      numberOfSeasons: json['number_of_seasons'],
      cast: castList,
      trailerKey: trailerKey,
      similarShows: similarShows,
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}