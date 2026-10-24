import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection.dart';
import 'core/utils/formatters.dart';
import 'models/vegetable.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/app_button.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/glass_icon_button.dart';
import 'ui/widgets/quantity_stepper.dart';
import 'ui/widgets/vegetable_image.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.vegetable, this.heroTag});

  final Vegetable vegetable;
  final String? heroTag;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _cart = getIt<CartService>();
  final _favorites = getIt<FavoritesService>();
  int _quantity = 1;
  bool _collapsed = false;

  int get _total => widget.vegetable.price * _quantity;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  void _toggleFavorite() {
    _favorites.toggle(widget.vegetable);
    HapticFeedback.selectionClick();
  }

  void _addToCart() {
    _cart.add(widget.vegetable, quantity: _quantity);
    HapticFeedback.mediumImpact();
    showAppSnackBar(
      context,
      '$_quantity × ${widget.vegetable.name} added to your basket.',
    );
  }

  bool _onScroll(ScrollNotification notification) {
    final collapsed = notification.metrics.pixels > 230;
    if (collapsed != _collapsed) {
      setState(() => _collapsed = collapsed);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final vegetable = widget.vegetable;
    final heroTag = widget.heroTag ?? 'vegetable-${vegetable.id}';

    return Scaffold(
      extendBody: true,
      backgroundColor: background,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: background,
              surfaceTintColor: Colors.transparent,
              leadingWidth: 68,
              titleSpacing: 0,
              systemOverlayStyle: _collapsed
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              title: AnimatedOpacity(
                opacity: _collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Text(
                  vegetable.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: title.copyWith(fontSize: 15),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: GlassIconButton(
                      icon: _favorites.isFavorite(vegetable.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _favorites.isFavorite(vegetable.id)
                          ? tomato
                          : ink,
                      tooltip: _favorites.isFavorite(vegetable.id)
                          ? 'Remove from favorites'
                          : 'Save to favorites',
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                      child: Hero(
                        tag: heroTag,
                        child: VegetableImage(
                          asset: vegetable.localImage,
                          url: vegetable.imageUrl,
                          semanticLabel: vegetable.name,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(34),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              forestDeep.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.transparent,
                              forestDeep.withValues(alpha: 0.08),
                            ],
                            stops: const [0, 0.25, 0.75, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: leaf,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'FRESH TODAY',
                              style: overline.copyWith(
                                fontSize: 8.5,
                                color: forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lime,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        vegetable.categoryLabel.toUpperCase(),
                        style: overline.copyWith(color: forest, fontSize: 8.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(vegetable.name, style: h1),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rupiah(vegetable.price),
                          style: price.copyWith(fontSize: 25),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('/kg', style: bodySmall),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: leaf,
                              ),
                              const SizedBox(width: 4),
                              Text('Local harvest', style: caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text('About this vegetable', style: h3),
                    const SizedBox(height: 8),
                    Text(
                      vegetable.description,
                      style: body.copyWith(color: muted, height: 1.65),
                    ),
                    const SizedBox(height: 18),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AssuranceChip(
                          icon: Icons.public_rounded,
                          label: 'Locally grown',
                        ),
                        _AssuranceChip(
                          icon: Icons.spa_rounded,
                          label: 'Freshly picked',
                        ),
                        _AssuranceChip(
                          icon: Icons.verified_rounded,
                          label: 'Quality checked',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity', style: titleSmall),
                                const SizedBox(height: 2),
                                Text('Add as many as you need', style: caption),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            value: _quantity,
                            onChanged: (value) {
                              setState(() => _quantity = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: lime.withValues(alpha: 0.36),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: lime,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              size: 19,
                              color: forest,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivered in 25–35 minutes',
                                  style: titleSmall.copyWith(fontSize: 13),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Free delivery on orders over Rp 100.000',
                                  style: caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: background,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 74,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: line.withValues(alpha: 0.7)),
                    boxShadow: [
                      BoxShadow(
                        color: forestDeep.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total', style: caption),
                            Text(
                              rupiah(_total),
                              style: price.copyWith(fontSize: 19),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppButton(
                          label: 'Add to cart',
                          icon: Icons.shopping_bag_outlined,
                          height: 52,
                          onPressed: _addToCart,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssuranceChip extends StatelessWidget {
  const _AssuranceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: leaf),
          const SizedBox(width: 5),
          Text(label, style: caption.copyWith(color: ink)),
        ],
      ),
    );
  }
}
