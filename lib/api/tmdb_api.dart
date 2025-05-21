import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/tv_show.dart';

class TMDBApi {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = 'e747e5245d83d51e158ee925031ff90d';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<TvShow>> getPopularTvShows() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/popular?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((show) => TvShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&append_to_response=credits,videos,similar'),
    );

    if (response.statusCode == 200) {
      return Movie.fromDetailJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<TvShow> getTvShowDetails(int tvShowId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$tvShowId?api_key=$apiKey&append_to_response=credits,videos,similar'),
    );

    if (response.statusCode == 200) {
      return TvShow.fromDetailJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load TV show details');
    }
  }

  Future<List<Movie>> getRecommendedMovies(List<int> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return getPopularMovies();
    }

    final movieId = favoriteIds.first;
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/recommendations?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load recommended movies');
    }
  }

  Future<List<TvShow>> getRecommendedTvShows(List<int> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return getPopularTvShows();
    }

    final tvShowId = favoriteIds.first;
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$tvShowId/recommendations?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((show) => TvShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load recommended TV shows');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<TvShow>> searchTvShows(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/tv?api_key=$apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((show) => TvShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to search TV shows');
    }
  }
}