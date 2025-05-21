class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<String>? genres;
  final int? runtime;
  final List<Cast>? cast;
  final String? trailerKey;
  final List<Movie>? similarMovies;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.genres,
    this.runtime,
    this.cast,
    this.trailerKey,
    this.similarMovies,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] ?? '',
    );
  }

  factory Movie.fromDetailJson(Map<String, dynamic> json) {
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

    List<Movie>? similarMovies;
    if (json['similar'] != null && json['similar']['results'] != null) {
      similarMovies = (json['similar']['results'] as List)
          .take(6)
          .map((movie) => Movie.fromJson(movie))
          .toList();
    }

    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genres: json['genres'] != null 
          ? (json['genres'] as List).map((genre) => genre['name'] as String).toList() 
          : null,
      runtime: json['runtime'],
      cast: castList,
      trailerKey: trailerKey,
      similarMovies: similarMovies,
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