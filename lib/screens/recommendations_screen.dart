import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/tmdb_api.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_show_card.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  final TMDBApi _api = TMDBApi();
  late TabController _tabController;
  
  List<Movie> _recommendedMovies = [];
  List<TvShow> _recommendedTvShows = [];
  List<int> _favoriteMovieIds = [];
  List<int> _favoriteTvShowIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storage = Provider.of<LocalStorageService>(context, listen: false);
      final prefs = await storage.getUserPreferences();
      
      setState(() {
        _favoriteMovieIds = prefs.favoriteMovieIds;
        _favoriteTvShowIds = prefs.favoriteTvShowIds;
      });
      
      final recommendedMovies = await _api.getRecommendedMovies(_favoriteMovieIds);
      final recommendedTvShows = await _api.getRecommendedTvShows(_favoriteTvShowIds);

      if (mounted) {
        setState(() {
          _recommendedMovies = recommendedMovies;
          _recommendedTvShows = recommendedTvShows;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.genericErrorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavoriteMovie(int movieId) async {
    final storage = Provider.of<LocalStorageService>(context, listen: false);
    final isFavoriteNow = await storage.toggleFavoriteMovie(movieId);
    
    setState(() {
      if (isFavoriteNow) {
        _favoriteMovieIds.add(movieId);
      } else {
        _favoriteMovieIds.remove(movieId);
      }
    });
  }

  Future<void> _toggleFavoriteTvShow(int tvShowId) async {
    final storage = Provider.of<LocalStorageService>(context, listen: false);
    final isFavoriteNow = await storage.toggleFavoriteTvShow(tvShowId);
    
    setState(() {
      if (isFavoriteNow) {
        _favoriteTvShowIds.add(tvShowId);
      } else {
        _favoriteTvShowIds.remove(tvShowId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandations'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Films'),
            Tab(text: 'Séries'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMoviesTab(),
                _buildTvShowsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecommendations,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMoviesTab() {
    if (_recommendedMovies.isEmpty) {
      return _buildEmptyState(
        'Aucune recommandation disponible',
        'Ajoutez des films à vos favoris pour obtenir des recommandations personnalisées',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      color: AppColors.accent,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _recommendedMovies.length,
        itemBuilder: (context, index) {
          final movie = _recommendedMovies[index];
          return MovieCard(
            movie: movie,
            isFavorite: _favoriteMovieIds.contains(movie.id),
            onToggleFavorite: _toggleFavoriteMovie,
          );
        },
      ),
    );
  }

  Widget _buildTvShowsTab() {
    if (_recommendedTvShows.isEmpty) {
      return _buildEmptyState(
        'Aucune recommandation disponible',
        'Ajoutez des séries à vos favoris pour obtenir des recommandations personnalisées',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      color: AppColors.accent,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _recommendedTvShows.length,
        itemBuilder: (context, index) {
          final tvShow = _recommendedTvShows[index];
          return TvShowCard(
            tvShow: tvShow,
            isFavorite: _favoriteTvShowIds.contains(tvShow.id),
            onToggleFavorite: _toggleFavoriteTvShow,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 80,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}