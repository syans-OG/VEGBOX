import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/vegetable.dart';
import '../colors.dart';
import '../typography.dart';
import 'favorite_button.dart';
import 'vegetable_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.vegetable,
    required this.onTap,
    required this.onAdd,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Vegetable vegetable;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: line.withValues(alpha: 0.9)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'vegetable-${vegetable.id}',
                    child: VegetableImage(
                      asset: vegetable.localImage,
                      url: vegetable.imageUrl,
                      semanticLabel: vegetable.name,
                    ),
                  ),
                  const Positioned(top: 10, left: 10, child: _FreshTag()),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FavoriteButton(
                        isFavorite: isFavorite,
                        onPressed: onFavoriteToggle!,
                        name: vegetable.name,
                      ),
                    ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Semantics(
                      button: true,
                      label: 'Add ${vegetable.name} to cart',
                      child: Tooltip(
                        message: 'Add to cart',
                        child: Material(
                          color: forest,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onAdd,
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.add_rounded,
                                size: 23,
                                color: lime,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vegetable.categoryLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: overline.copyWith(color: leaf, fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vegetable.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleSmall.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          rupiah(vegetable.price),
                          style: price.copyWith(fontSize: 16),
                        ),
                      ),
                      Text('/kg', style: caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreshTag extends StatelessWidget {
  const _FreshTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: leaf,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'FRESH',
            style: overline.copyWith(
              fontSize: 8,
              color: forest,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
