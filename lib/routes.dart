import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/tv_show_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/profile_screen.dart';

// Configuration des routes de l'application
class AppRoutes {
  static const String home = '/';
  static const String movieDetail = '/movie_detail';
  static const String tvShowDetail = '/tv_show_detail';
  static const String favorites = '/favorites';
  static const String recommendations = '/recommendations';
  static const String profile = '/profile';

  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case movieDetail:
        final int movieId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movieId: movieId),
        );
      
      case tvShowDetail:
        final int tvShowId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => TVShowDetailScreen(showId: tvShowId),
        );
      
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      
      case recommendations:
        return MaterialPageRoute(builder: (_) => const RecommendationsScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreenAlt());
      
      default:
        // Route par défaut en cas d'erreur
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route inconnue: ${settings.name}'),
            ),
          ),
        );
    }
  }
}