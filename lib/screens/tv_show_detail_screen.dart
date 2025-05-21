import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/rating_widget.dart';

class TVShowDetailScreen extends StatefulWidget {
  final int showId;

  const TVShowDetailScreen({super.key, required this.showId});

  @override
  State<TVShowDetailScreen> createState() => _TVShowDetailScreenState();
}

class _TVShowDetailScreenState extends State<TVShowDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> showDetails = {
      'id': widget.showId,
      'title': 'House of the Dragon',
      'firstAirYear': '2022',
      'seasons': 2,
      'episodes': 18,
      'runtime': '60 min',
      'rating': 8.4,
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/z2yahl2uefxDCl0nogcRBstwruJ.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/original/5PpDMfU2LEu7nV0Jksg9ysF9UOL.jpg',
      'overview':
          'L\'histoire des Targaryen, 200 ans avant les événements de Game of Thrones. Le roi Viserys Targaryen règne pacifiquement sur Westeros. Lorsqu\'il désigne sa fille Rhaenyra comme héritière du trône, un conflit de succession s\'amorce, menant à la sanglante guerre civile connue sous le nom de "Danse des Dragons".',
      'creator': 'Ryan Condal, George R. R. Martin',
      'cast': ['Matt Smith', 'Emma D\'Arcy', 'Olivia Cooke', 'Rhys Ifans'],
      'genres': ['Drame', 'Action', 'Fantastique'],
      'seasonData': [
        {
          'season': 1,
          'episodeCount': 10,
          'episodes': [
            {
              'number': 1,
              'title': 'Les Héritiers du Dragon',
              'runtime': '66 min',
            },
            {'number': 2, 'title': 'Le Prince Voyou', 'runtime': '54 min'},
            {'number': 3, 'title': 'Le Deuxième Du Nom', 'runtime': '63 min'},
          
          ],
        },
        {
          'season': 2,
          'episodeCount': 8,
          'episodes': [
            {
              'number': 1,
              'title': 'Une Fils pour un Fils',
              'runtime': '62 min',
            },
            {'number': 2, 'title': 'Renonciation', 'runtime': '59 min'},
            {'number': 3, 'title': 'Le Feu à la Panse', 'runtime': '57 min'},
            
          ],
        },
      ],
    };

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, showDetails),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShowInfo(context, showDetails),
                  const SizedBox(height: 20),
                  _buildOverview(context, showDetails),
                  const SizedBox(height: 20),
                  _buildCast(context, showDetails),
                  const SizedBox(height: 20),
                  _buildEpisodes(context, showDetails),
                  const SizedBox(height: 20),
                  _buildRecommendations(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement play trailer action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lecture de la bande-annonce...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Bande-annonce'),
        elevation: 4,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Map<String, dynamic> showDetails) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'tv-poster-${showDetails['id']}',
              child: Image.network(
                showDetails['backdropUrl'],
                fit: BoxFit.cover,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 180,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        showDetails['posterUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showDetails['title'],
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                showDetails['firstAirYear'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${showDetails['seasons']} saisons',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${showDetails['episodes']} épisodes',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_outline,
            color:
                _isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isFavorite
                      ? '${showDetails['title']} ajouté aux favoris'
                      : '${showDetails['title']} retiré des favoris',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Partage en cours...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShowInfo(
    BuildContext context,
    Map<String, dynamic> showDetails,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingWidget(rating: showDetails['rating']),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    showDetails['genres'].length,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        showDetails['genres'][index],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                'Créateurs: ',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  showDetails['creator'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    Map<String, dynamic> showDetails,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            showDetails['overview'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCast(BuildContext context, Map<String, dynamic> showDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: showDetails['cast'].length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(
                        'https://image.tmdb.org/t/p/w200/5M6thYHrDOthbHB5LpX4jfbnffs.jpg',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showDetails['cast'][index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodes(
    BuildContext context,
    Map<String, dynamic> showDetails,
  ) {
    var selectedSeasonData = showDetails['seasonData'].firstWhere(
      (season) => season['season'] == _selectedSeason,
      orElse: () => showDetails['seasonData'][0],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Épisodes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<int>(
                value: _selectedSeason,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedSeason = newValue!;
                  });
                },
                items: List.generate(
                  showDetails['seasons'],
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('Saison ${index + 1}'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedSeasonData['episodes'].length,
            itemBuilder: (context, index) {
              final episode = selectedSeasonData['episodes'][index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${episode['number']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    episode['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Durée: ${episode['runtime']}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.play_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Lecture de S${_selectedSeason}E${episode['number']} - ${episode['title']}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final List<Map<String, dynamic>> mockRecommendations = [
      {
        'id': 105,
        'title': 'Game of Thrones',
        'poster':
            'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        'rating': 8.4,
      },
      {
        'id': 106,
        'title': 'The Last of Us',
        'poster':
            'https://image.tmdb.org/t/p/w500/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
        'rating': 8.7,
      },
      {
        'id': 107,
        'title': 'The Witcher',
        'poster':
            'https://image.tmdb.org/t/p/w500/7vjaCdMw15FEbXyLQTVa04URsPm.jpg',
        'rating': 8.0,
      },
      {
        'id': 108,
        'title': 'The Crown',
        'poster':
            'https://image.tmdb.org/t/p/w500/hSdBmbZ9euViQQvLMq4uJpGqBUP.jpg',
        'rating': 8.2,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recommandations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mockRecommendations.length,
            itemBuilder: (context, index) {
              final show = mockRecommendations[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(show['poster'], fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 110,
                      child: Text(
                        show['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          show['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
