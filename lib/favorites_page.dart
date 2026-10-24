import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection.dart';
import 'detail_page.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'ui/typography.dart';
import 'ui/widgets/empty_state.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.onOpenCart});

  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    final favorites = getIt<FavoritesService>();
    final cart = getIt<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: title.copyWith(fontSize: 18)),
      ),
      body: AnimatedBuilder(
        animation: favorites,
        builder: (context, _) {
          final items = favorites.items;
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              message:
                  'Tap the heart on any vegetable and it will wait for you here.',
              actionLabel: 'Browse vegetables',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 640
                        ? 3
                        : 2;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'vegetable' : 'vegetables'} saved',
                              style: bodySmall,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: 272,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final vegetable = items[index];
                              return ProductCard(
                                vegetable: vegetable,
                                isFavorite: true,
                                onFavoriteToggle: () =>
                                    favorites.toggle(vegetable),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailPage(vegetable: vegetable),
                                  ),
                                ),
                                onAdd: () {
                                  cart.add(vegetable);
                                  HapticFeedback.selectionClick();
                                  showAppSnackBar(
                                    context,
                                    '${vegetable.name} added to your basket.',
                                    actionLabel: 'View cart',
                                    onAction: () {
                                      Navigator.of(context).pop();
                                      onOpenCart();
                                    },
                                  );
                                },
                              );
                            }, childCount: items.length),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
