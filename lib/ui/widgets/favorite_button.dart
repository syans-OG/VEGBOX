import 'package:flutter/material.dart';

import '../colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.name,
    this.size = 44,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final itemName = name;
    final label = itemName == null
        ? (isFavorite ? 'Remove from favorites' : 'Save to favorites')
        : (isFavorite
              ? 'Remove $itemName from favorites'
              : 'Save $itemName to favorites');

    return Semantics(
      button: true,
      enabled: true,
      toggled: isFavorite,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: isFavorite ? 'Remove from favorites' : 'Save to favorites',
        child: Material(
          color: surface.withValues(alpha: 0.94),
          clipBehavior: Clip.antiAlias,
          shape: CircleBorder(
            side: BorderSide(color: line.withValues(alpha: 0.7)),
          ),
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: size * 0.46,
                color: isFavorite ? tomato : forest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
