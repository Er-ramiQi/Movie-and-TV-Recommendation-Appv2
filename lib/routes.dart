import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/tv_show_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/profile_screen_firebase.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Configuration des routes de l'application
class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/';
  static const String movieDetail = '/movie_detail';
  static const String tvShowDetail = '/tv_show_detail';
  static const String favorites = '/favorites';
  static const String recommendations = '/recommendations';
  static const String profile = '/profile';

  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        
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
        return MaterialPageRoute(builder: (_) => const ProfileScreenFirebase());
      
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

  // Navigation avec animations
  static Future<void> navigateWithSlideAnimation(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: routeName, arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) {
          final route = generateRoute(
            RouteSettings(name: routeName, arguments: arguments),
          );
          return route.buildPage(
            context,
            animation,
            secondaryAnimation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  // Remplacement avec animations
  static Future<void> replaceWithFadeAnimation(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: routeName, arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) {
          final route = generateRoute(
            RouteSettings(name: routeName, arguments: arguments),
          );
          return route.buildPage(
            context,
            animation,
            secondaryAnimation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  // Navigation vers l'écran principal et effacement de la pile
  static void navigateToHomeAndClear(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      home,
      (route) => false,
    );
  }
}