import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../utils/constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFavorite;
  final Function(int) onToggleFavorite;
  final bool isHorizontal;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              MovieDetailScreen(movieId: movie.id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: AppConstants.animationDuration,
          ),
        );
      },
      child: Hero(
        tag: 'movie_${movie.id}',
        child: Container(
          width: isHorizontal ? 140 : 160,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: movie.posterPath.isNotEmpty
                    ? Image.network(
                        ApiEndpoints.getPosterUrl(movie.posterPath),
                        fit: BoxFit.cover,
                        height: isHorizontal ? 200 : 240,
                        width: isHorizontal ? 140 : 160,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Theme.of(context).colorScheme.surface,
                            height: isHorizontal ? 200 : 240,
                            width: isHorizontal ? 140 : 160,
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surface,
                            height: isHorizontal ? 200 : 240,
                            width: isHorizontal ? 140 : 160,
                            child: const Center(
                              child: Icon(Icons.movie, size: 50, color: AppColors.accent),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surface,
                        height: isHorizontal ? 200 : 240,
                        width: isHorizontal ? 140 : 160,
                        child: const Center(
                          child: Icon(Icons.movie, size: 50, color: AppColors.accent),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isFavorite),
                      color: isFavorite ? AppColors.accent : Colors.white,
                      size: 28,
                    ),
                  ),
                  onPressed: () => onToggleFavorite(movie.id),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (movie.releaseDate.isNotEmpty)
                            Text(
                              movie.releaseDate.split('-')[0],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}