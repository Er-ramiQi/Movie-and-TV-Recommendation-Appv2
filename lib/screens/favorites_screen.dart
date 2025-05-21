import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../api/tmdb_api.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_show_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final TMDBApi _api = TMDBApi();
  late TabController _tabController;
  
  List<Movie> _favoriteMovies = [];
  List<TvShow> _favoriteTvShows = [];
  bool _isLoading = true;
  bool _isGridView = true;  
  String _sortOption = 'title';  
  bool _sortAscending = true;
  
  
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});  
      }
    });
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storage = Provider.of<LocalStorageService>(context, listen: false);
      final prefs = await storage.getUserPreferences();
      
      final List<Future<Movie>> movieFutures = [];
      for (final id in prefs.favoriteMovieIds) {
        movieFutures.add(_api.getMovieDetails(id));
      }
      
      final List<Future<TvShow>> tvShowFutures = [];
      for (final id in prefs.favoriteTvShowIds) {
        tvShowFutures.add(_api.getTvShowDetails(id));
      }
      
      List<Movie> movies = [];
      List<TvShow> tvShows = [];
      
      if (movieFutures.isNotEmpty) {
        movies = await Future.wait(movieFutures);
      }
      
      if (tvShowFutures.isNotEmpty) {
        tvShows = await Future.wait(tvShowFutures);
      }
      
      if (mounted) {
        setState(() {
          _favoriteMovies = movies;
          _favoriteTvShows = tvShows;
          _sortFavorites();
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sortFavorites() {
  
    switch (_sortOption) {
      case 'title':
        _favoriteMovies.sort((a, b) => _sortAscending 
          ? a.title.compareTo(b.title) 
          : b.title.compareTo(a.title));
        break;
      case 'date':
        _favoriteMovies.sort((a, b) {
          if (a.releaseDate.isEmpty) return _sortAscending ? 1 : -1;
          if (b.releaseDate.isEmpty) return _sortAscending ? -1 : 1;
          return _sortAscending 
            ? a.releaseDate.compareTo(b.releaseDate) 
            : b.releaseDate.compareTo(a.releaseDate);
        });
        break;
      case 'rating':
        _favoriteMovies.sort((a, b) => _sortAscending 
          ? a.voteAverage.compareTo(b.voteAverage) 
          : b.voteAverage.compareTo(a.voteAverage));
        break;
    }
    
  
    switch (_sortOption) {
      case 'title':
        _favoriteTvShows.sort((a, b) => _sortAscending 
          ? a.name.compareTo(b.name) 
          : b.name.compareTo(a.name));
        break;
      case 'date':
        _favoriteTvShows.sort((a, b) {
          if (a.firstAirDate.isEmpty) return _sortAscending ? 1 : -1;
          if (b.firstAirDate.isEmpty) return _sortAscending ? -1 : 1;
          return _sortAscending 
            ? a.firstAirDate.compareTo(b.firstAirDate) 
            : b.firstAirDate.compareTo(a.firstAirDate);
        });
        break;
      case 'rating':
        _favoriteTvShows.sort((a, b) => _sortAscending 
          ? a.voteAverage.compareTo(b.voteAverage) 
          : b.voteAverage.compareTo(a.voteAverage));
        break;
    }
  }

  Future<void> _toggleFavoriteMovie(int movieId) async {
    final storage = Provider.of<LocalStorageService>(context, listen: false);
    await storage.toggleFavoriteMovie(movieId);
    
    setState(() {
      _favoriteMovies.removeWhere((movie) => movie.id == movieId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Retiré des favoris'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
          
            _loadFavorites();
          },
        ),
      ),
    );
  }

  Future<void> _toggleFavoriteTvShow(int tvShowId) async {
    final storage = Provider.of<LocalStorageService>(context, listen: false);
    await storage.toggleFavoriteTvShow(tvShowId);
    
    setState(() {
      _favoriteTvShows.removeWhere((tvShow) => tvShow.id == tvShowId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Retiré des favoris'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            
            _loadFavorites();
          },
        ),
      ),
    );
  }

  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.sort),
                      const SizedBox(width: 16),
                      const Text(
                        'Trier par',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 18,
                        ),
                        label: Text(_sortAscending ? 'Ascendant' : 'Descendant'),
                        onPressed: () {
                          setModalState(() {
                            _sortAscending = !_sortAscending;
                          });
                          setState(() {
                            _sortFavorites();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                _buildSortOption(
                  title: 'Titre',
                  value: 'title',
                  setModalState: setModalState,
                ),
                _buildSortOption(
                  title: 'Date de sortie',
                  value: 'date',
                  setModalState: setModalState,
                ),
                _buildSortOption(
                  title: 'Note',
                  value: 'rating',
                  setModalState: setModalState,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required String value,
    required StateSetter setModalState,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _sortOption,
      activeColor: AppColors.accent,
      onChanged: (newValue) {
        setModalState(() {
          _sortOption = newValue!;
        });
        setState(() {
          _sortFavorites();
        });
      },
    );
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
        title: const Text('Mes Favoris'),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              key: ValueKey<bool>(_isGridView),
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortingOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Films (${_favoriteMovies.length})',
            ),
            Tab(
              text: 'Séries (${_favoriteTvShows.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement de vos favoris...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMoviesTab(),
                _buildTvShowsTab(),
              ],
            ),
      floatingActionButton: !_isLoading ? FloatingActionButton(
        onPressed: () {
          _refreshIndicatorKey.currentState?.show();
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.refresh),
      ) : null,
    );
  }

  Widget _buildMoviesTab() {
    if (_favoriteMovies.isEmpty) {
      return _buildEmptyState('Aucun film favori');
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadFavorites,
      color: AppColors.accent,
      child: _isGridView 
        ? _buildMoviesGrid() 
        : _buildMoviesList(),
    );
  }

  Widget _buildMoviesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _favoriteMovies.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return MovieCard(
          movie: _favoriteMovies[index],
          isFavorite: true,
          onToggleFavorite: _toggleFavoriteMovie,
        );
      },
    );
  }

  Widget _buildMoviesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _favoriteMovies.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final movie = _favoriteMovies[index];
        return Dismissible(
          key: Key('movie_${movie.id}'),
          background: Container(
            color: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _toggleFavoriteMovie(movie.id);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: Hero(
                tag: 'movie_list_${movie.id}',
                child: Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: movie.posterPath.isNotEmpty
                        ? Image.network(
                            ApiEndpoints.getPosterUrl(movie.posterPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primaryDark,
                            child: const Icon(
                              Icons.movie,
                              size: 30,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                ),
              ),
              title: Text(
                movie.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (movie.releaseDate.isNotEmpty)
                    Text(
                      movie.releaseDate.split('-')[0],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.starYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.accent),
                onPressed: () => _toggleFavoriteMovie(movie.id),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/movie_detail',
                  arguments: movie.id,
                ).then((_) => _loadFavorites()); // Rafraîchir au retour
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTvShowsTab() {
    if (_favoriteTvShows.isEmpty) {
      return _buildEmptyState('Aucune série favorite');
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.accent,
      child: _isGridView 
        ? _buildTvShowsGrid() 
        : _buildTvShowsList(),
    );
  }

  Widget _buildTvShowsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _favoriteTvShows.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return TvShowCard(
          tvShow: _favoriteTvShows[index],
          isFavorite: true,
          onToggleFavorite: _toggleFavoriteTvShow,
        );
      },
    );
  }

  Widget _buildTvShowsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _favoriteTvShows.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final tvShow = _favoriteTvShows[index];
        return Dismissible(
          key: Key('tvshow_${tvShow.id}'),
          background: Container(
            color: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _toggleFavoriteTvShow(tvShow.id);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: Hero(
                tag: 'tvshow_list_${tvShow.id}',
                child: Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: tvShow.posterPath.isNotEmpty
                        ? Image.network(
                            ApiEndpoints.getPosterUrl(tvShow.posterPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primaryDark,
                            child: const Icon(
                              Icons.tv,
                              size: 30,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                ),
              ),
              title: Text(
                tvShow.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (tvShow.firstAirDate.isNotEmpty)
                    Text(
                      tvShow.firstAirDate.split('-')[0],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.starYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tvShow.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.accent),
                onPressed: () => _toggleFavoriteTvShow(tvShow.id),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/tv_show_detail',
                  arguments: tvShow.id,
                ).then((_) => _loadFavorites());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(value * math.pi * 2) * 5),
                child: Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.accent.withOpacity(0.5),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Ajoutez des contenus à vos favoris pour les retrouver ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Découvrir des films et séries'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}