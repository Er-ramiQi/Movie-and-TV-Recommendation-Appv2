import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import '../api/tmdb_api.dart';
import '../models/movie.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../widgets/movie_card.dart';
import '../widgets/rating_widget.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  final TMDBApi _api = TMDBApi();
  Movie? _movie;
  bool _isLoading = true;
  bool _isFavorite = false;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMovie();
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && _isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = false;
        });
      } else if (_scrollController.offset <= 200 && !_isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = true;
        });
      }
    });
  }

  Future<void> _loadMovie() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storage = Provider.of<LocalStorageService>(context, listen: false);
      final movie = await _api.getMovieDetails(widget.movieId);
      final isFavorite = await storage.isMovieFavorite(widget.movieId);

      if (mounted) {
        setState(() {
          _movie = movie;
          _isFavorite = isFavorite;
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

  Future<void> _toggleFavorite() async {
    if (_movie == null) return;

    final storage = Provider.of<LocalStorageService>(context, listen: false);
    final isFavoriteNow = await storage.toggleFavoriteMovie(_movie!.id);
    
    // Animation de rebond pour le bouton
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    final Animation<double> curve = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    );
    
    Animation<double> animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(curve);
    
    controller.forward();

    setState(() {
      _isFavorite = isFavoriteNow;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
        ),
        backgroundColor: _isFavorite ? AppColors.success : null,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () {
            // Naviguer vers l'écran des favoris
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushNamed('/favorites');
          },
        ),
      ),
    );
  }

  Future<void> _openTrailer() async {
    if (_movie == null || _movie!.trailerKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune bande-annonce disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final url = 'https://www.youtube.com/watch?v=${_movie!.trailerKey}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la bande-annonce'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _shareMovie() {
    if (_movie == null) return;
    
    final String title = _movie!.title;
    final String year = _movie!.releaseDate.isNotEmpty 
        ? _movie!.releaseDate.split('-')[0] 
        : '';
    
    Share.share(
      'Découvre "$title" ($year) sur CinéReco ! Une note de ${_movie!.voteAverage.toStringAsFixed(1)}/10',
      subject: 'Film recommandé : $title',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement du film...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : _movie == null
              ? const Center(
                  child: Text('Film non trouvé'),
                )
              : CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildQuickInfo(),
                          _buildTabBar(),
                          SizedBox(
                            height: 500,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildAboutTab(),
                                _buildCastTab(),
                                _buildSimilarTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _movie != null
          ? AnimatedOpacity(
              opacity: _isAppBarExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.extended(
                onPressed: _openTrailer,
                backgroundColor: AppColors.accent,
                elevation: 4,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bande-annonce'),
              ),
            )
          : null,
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: _isAppBarExpanded 
        ? Colors.transparent 
        : Theme.of(context).appBarTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'movie_${_movie!.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              _movie!.backdropPath.isNotEmpty
                  ? Image.network(
                      ApiEndpoints.getBackdropUrl(_movie!.backdropPath),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primaryDark,
                      child: const Icon(
                        Icons.movie,
                        size: 100,
                        color: AppColors.accent,
                      ),
                    ),
              // Ajout d'un overlay de gradient pour améliorer la lisibilité
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Titre du film en bas de l'image pour les appbars réduites
              if (!_isAppBarExpanded)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 56, // Espace pour les actions
                  child: Text(
                    _movie!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Effet de verre dépoli si l'AppBar est réduite
              if (!_isAppBarExpanded)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(_isFavorite),
              color: _isFavorite ? AppColors.accent : Colors.white,
              size: 28,
            ),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareMovie,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage de l'affiche avec bordure et ombre
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    height: 180,
                    child: _movie!.posterPath.isNotEmpty
                        ? Image.network(
                            ApiEndpoints.getPosterUrl(_movie!.posterPath),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Theme.of(context).cardTheme.color,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.accent,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.primaryDark,
                            child: const Icon(
                              Icons.movie,
                              size: 50,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _movie!.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_movie!.releaseDate.isNotEmpty)
                      Text(
                        'Sorti le ${_formatDate(_movie!.releaseDate)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Ajout d'une animation pour le rating
                        AnimatedRatingWidget(
                          rating: _movie!.voteAverage,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_movie!.genres != null && _movie!.genres!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _movie!.genres!.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryLight.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Nouvelles fonctions et widgets ajoutés
  
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    
    final Map<String, String> months = {
      '01': 'janvier', '02': 'février', '03': 'mars', '04': 'avril',
      '05': 'mai', '06': 'juin', '07': 'juillet', '08': 'août',
      '09': 'septembre', '10': 'octobre', '11': 'novembre', '12': 'décembre',
    };
    
    return '${parts[2]} ${months[parts[1]] ?? parts[1]} ${parts[0]}';
  }

  Widget _buildQuickInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_movie!.runtime != null)
            _buildInfoItem(
              icon: Icons.access_time,
              label: _formatRuntime(_movie!.runtime!),
            ),
          
          _buildInfoItem(
            icon: Icons.star,
            label: '${_movie!.voteAverage.toStringAsFixed(1)}/10',
            color: AppColors.starYellow,
          ),
          
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: _movie!.releaseDate.isNotEmpty 
                ? _movie!.releaseDate.split('-')[0] 
                : 'N/A',
          ),
        ],
      ),
    );
  }
  
  String _formatRuntime(int minutes) {
    final int hrs = minutes ~/ 60;
    final int mins = minutes % 60;
    return hrs > 0 ? '$hrs h ${mins > 0 ? '$mins min' : ''}' : '$mins min';
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.accent,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.accent,
        labelColor: AppColors.accent,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        tabs: const [
          Tab(text: 'À propos'),
          Tab(text: 'Casting'),
          Tab(text: 'Similaires'),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _movie!.overview,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          
          // Ajout d'un bouton d'action supplémentaire
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _movie!.trailerKey != null ? _openTrailer : null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Regarder la bande-annonce'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.accent,
              ),
            ),
          ),
          
          if (_movie!.trailerKey == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Aucune bande-annonce disponible',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCastTab() {
    if (_movie!.cast == null || _movie!.cast!.isEmpty) {
      return const Center(
        child: Text('Aucune information sur le casting disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movie!.cast!.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final cast = _movie!.cast![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Hero(
              tag: 'cast_${cast.id}',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                backgroundImage: cast.profilePath != null
                    ? NetworkImage(ApiEndpoints.getProfileUrl(cast.profilePath!))
                    : null,
                child: cast.profilePath == null
                    ? const Icon(Icons.person, color: AppColors.accent, size: 30)
                    : null,
              ),
            ),
            title: Text(
              cast.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  cast.character,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Action pour voir les détails de l'acteur
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Détails de ${cast.name} (à implémenter)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSimilarTab() {
    if (_movie!.similarMovies == null || _movie!.similarMovies!.isEmpty) {
      return const Center(
        child: Text('Aucun film similaire trouvé'),
      );
    }

    // Affichage en grille au lieu de liste horizontale
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _movie!.similarMovies!.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return FutureBuilder<bool>(
          future: Provider.of<LocalStorageService>(context, listen: false)
              .isMovieFavorite(_movie!.similarMovies![index].id),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            return MovieCard(
              movie: _movie!.similarMovies![index],
              isFavorite: isFavorite,
              onToggleFavorite: (id) async {
                final storage = Provider.of<LocalStorageService>(context, listen: false);
                await storage.toggleFavoriteMovie(id);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}