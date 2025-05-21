import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.starYellow;
    final fullStars = rating ~/ 2;
    final hasHalfStar = (rating / 2) - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          fullStars,
          (index) => Icon(
            Icons.star,
            color: starColor,
            size: size,
          ),
        ),
        if (hasHalfStar)
          Icon(
            Icons.star_half,
            color: starColor,
            size: size,
          ),
        ...List.generate(
          emptyStars,
          (index) => Icon(
            Icons.star_border,
            color: starColor,
            size: size,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: size * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AnimatedRatingWidget extends StatefulWidget {
  final double rating;
  final double size;
  final Color? color;
  final Duration duration;

  const AnimatedRatingWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedRatingWidget> createState() => _AnimatedRatingWidgetState();
}

class _AnimatedRatingWidgetState extends State<AnimatedRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.rating).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.rating,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return RatingWidget(
          rating: _animation.value,
          size: widget.size,
          color: widget.color,
        );
      },
    );
  }
}