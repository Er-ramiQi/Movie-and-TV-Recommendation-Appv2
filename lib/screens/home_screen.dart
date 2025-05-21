import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/tmdb_api.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_show_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDBApi _api = TMDBApi();
  final TextEditingController _searchController = TextEditingController();
  
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<TvShow> _popularTvShows = [];
  List<int> _favoriteMovieIds = [];
  List<int> _favoriteTvShowIds = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Movie> _searchResultMovies = [];
  List<TvShow> _searchResultTvShows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
      
      final trendingMovies = await _api.getTrendingMovies();
      final popularMovies = await _api.getPopularMovies();
      final popularTvShows = await _api.getPopularTvShows();

      if (mounted) {
        setState(() {
          _trendingMovies = trendingMovies;
          _popularMovies = popularMovies;
          _popularTvShows = popularTvShows;
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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResultMovies = [];
        _searchResultTvShows = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final movieResults = await _api.searchMovies(query);
      final tvShowResults = await _api.searchTvShows(query);
      
      if (mounted) {
        setState(() {
          _searchResultMovies = movieResults;
          _searchResultTvShows = tvShowResults;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppColors.primaryDark,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _performSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rechercher des films et séries...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _isSearching = false;
                                    _searchResultMovies = [];
                                    _searchResultTvShows = [];
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (_isSearching)
              _buildSearchResults()
            else
              _buildHomeContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        
        _buildSectionHeader('Films tendance'),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _trendingMovies.length,
            itemBuilder: (context, index) {
              final movie = _trendingMovies[index];
              return MovieCard(
                movie: movie,
                isFavorite: _favoriteMovieIds.contains(movie.id),
                onToggleFavorite: _toggleFavoriteMovie,
              );
            },
          ),
        ),
        
        _buildSectionHeader('Films populaires'),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _popularMovies.length,
            itemBuilder: (context, index) {
              final movie = _popularMovies[index];
              return MovieCard(
                movie: movie,
                isFavorite: _favoriteMovieIds.contains(movie.id),
                onToggleFavorite: _toggleFavoriteMovie,
              );
            },
          ),
        ),
        
        _buildSectionHeader('Séries populaires'),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _popularTvShows.length,
            itemBuilder: (context, index) {
              final tvShow = _popularTvShows[index];
              return TvShowCard(
                tvShow: tvShow,
                isFavorite: _favoriteTvShowIds.contains(tvShow.id),
                onToggleFavorite: _toggleFavoriteTvShow,
              );
            },
          ),
        ),
        
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResultMovies.isEmpty && _searchResultTvShows.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        if (_searchResultMovies.isNotEmpty) ...[
          _buildSectionHeader('Films'),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchResultMovies.length,
              itemBuilder: (context, index) {
                final movie = _searchResultMovies[index];
                return MovieCard(
                  movie: movie,
                  isFavorite: _favoriteMovieIds.contains(movie.id),
                  onToggleFavorite: _toggleFavoriteMovie,
                );
              },
            ),
          ),
        ],
        
        if (_searchResultTvShows.isNotEmpty) ...[
          _buildSectionHeader('Séries'),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchResultTvShows.length,
              itemBuilder: (context, index) {
                final tvShow = _searchResultTvShows[index];
                return TvShowCard(
                  tvShow: tvShow,
                  isFavorite: _favoriteTvShowIds.contains(tvShow.id),
                  onToggleFavorite: _toggleFavoriteTvShow,
                );
              },
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Voir plus'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}