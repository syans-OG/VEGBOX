import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/utils/formatters.dart';
import 'detail_page.dart';
import 'models/vegetable.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'services/user_service.dart';
import 'services/vegetable_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/brand_mark.dart';
import 'ui/widgets/empty_state.dart';
import 'ui/widgets/favorite_button.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/product_card.dart';
import 'ui/widgets/profile_avatar.dart';
import 'ui/widgets/vegetable_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onOpenCart,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenCart;
  final VoidCallback onOpenProfile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _vegetableService = getIt<VegetableService>();
  final _cart = getIt<CartService>();
  final _favorites = getIt<FavoritesService>();
  final _user = getIt<UserService>();
  final _searchController = TextEditingController();

  List<Vegetable> _vegetables = [];
  String _query = '';
  String? _category;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _remoteFailed = false;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onFavoritesChanged);
    _loadLocal();
    _loadRemote();
  }

  @override
  void dispose() {
    _favorites.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLocal() async {
    try {
      final items = await _vegetableService.loadLocal();
      if (!mounted) return;
      setState(() {
        _vegetables = items;
        _isLoading = false;
      });
    } catch (error, stack) {
      debugPrint('Local vegetable load failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _loadRemote() async {
    try {
      final items = await _vegetableService.fetchFromApi();
      if (!mounted) return;
      setState(() {
        _vegetables = items;
        _isLoading = false;
        _loadFailed = false;
        _remoteFailed = false;
      });
    } catch (error, stack) {
      debugPrint('Remote vegetable load failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = _vegetables.isEmpty;
        _remoteFailed = true;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final items = await _vegetableService.fetchFromApi();
      if (!mounted) return;
      setState(() {
        _vegetables = items;
        _loadFailed = false;
        _remoteFailed = false;
      });
    } catch (error, stack) {
      debugPrint('Vegetable refresh failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _loadFailed = _vegetables.isEmpty;
        _remoteFailed = true;
      });
      final message = error is FormatException
          ? 'The catalog response looked wrong. Showing your local picks.'
          : 'Could not reach the farm. Showing your local picks.';
      showAppSnackBar(context, message);
    }
  }

  List<Vegetable> get _filteredVegetables {
    final category = _category;
    return _vegetables
        .where(
          (item) =>
              (category == null || item.category == category) &&
              item.matches(_query),
        )
        .toList();
  }

  List<Vegetable> get _discoveryPicks {
    final picks = <Vegetable>[];
    final categories = <String>{};
    for (final vegetable in _vegetables) {
      if (categories.add(vegetable.category)) picks.add(vegetable);
      if (picks.length == 4) break;
    }
    return picks;
  }

  void _resetFilters() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
      _category = null;
    });
  }

  void _addToCart(Vegetable vegetable) {
    _cart.add(vegetable);
    HapticFeedback.selectionClick();
    showAppSnackBar(
      context,
      '${vegetable.name} added to your basket.',
      actionLabel: 'View cart',
      onAction: widget.onOpenCart,
    );
  }

  void _openDetail(Vegetable vegetable, {String? heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPage(vegetable: vegetable, heroTag: heroTag),
      ),
    );
  }

  void _toggleFavorite(Vegetable vegetable) {
    _favorites.toggle(vegetable);
    HapticFeedback.selectionClick();
  }

  Future<void> _copyPromoCode() async {
    await Clipboard.setData(const ClipboardData(text: AppConstants.promoCode));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    showAppSnackBar(
      context,
      'Code ${AppConstants.promoCode} copied. Use it at checkout.',
    );
  }

  void _showAddressPicker() {
    final addresses = [
      (
        label: AppConstants.defaultAddressLabel,
        detail: AppConstants.defaultAddressDetail,
      ),
      (label: 'Office · Dinus Hub', detail: 'Jl. Nakula I No. 5, Semarang'),
      (label: 'Parents house', detail: 'Banyumanik, Semarang'),
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Deliver to', style: h2),
                const SizedBox(height: 4),
                Text(
                  'Choose where your fresh picks should land.',
                  style: bodySmall,
                ),
                const SizedBox(height: 16),
                for (var index = 0; index < addresses.length; index++)
                  _AddressOption(
                    icon: index == 0
                        ? Icons.home_rounded
                        : index == 1
                        ? Icons.work_outline_rounded
                        : Icons.favorite_border_rounded,
                    title: addresses[index].label,
                    subtitle: addresses[index].detail,
                    selected: _user.addressLabel == addresses[index].label,
                    onTap: () {
                      _user.updateAddress(
                        label: addresses[index].label,
                        detail: addresses[index].detail,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredVegetables;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900
        ? 4
        : width >= 640
        ? 3
        : 2;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: forest,
        backgroundColor: surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildAddress(),
                  const SizedBox(height: 14),
                  _buildSearch(),
                  const SizedBox(height: 20),
                  _PromoBanner(onCopyCode: _copyPromoCode),
                  if (_remoteFailed &&
                      !_isLoading &&
                      _vegetables.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _StaleCatalogBanner(onRetry: () => _refresh()),
                  ],
                  if (!_isLoading &&
                      _query.trim().isEmpty &&
                      _category == null &&
                      _vegetables.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDiscovery(),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _CategoryChip(
                      text: 'All',
                      selected: _category == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    for (final category in AppConstants.categories) ...[
                      const SizedBox(width: 8),
                      _CategoryChip(
                        text: AppConstants.categoryShortLabel(category),
                        selected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(items.length),
              ),
            ),
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 272,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const _SkeletonCard(),
                    childCount: columns * 2,
                  ),
                ),
              )
            else if (_loadFailed && items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 36, bottom: 150),
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'The farm is offline',
                    message:
                        'We could not load your vegetables. Check your connection and try again.',
                    actionLabel: 'Try again',
                    onAction: () {
                      setState(() => _isLoading = true);
                      _loadLocal();
                      _loadRemote();
                    },
                  ),
                ),
              )
            else if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 150),
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No veggies here',
                    message:
                        'Try another search or explore a different category.',
                    actionLabel: 'Reset filters',
                    onAction: _resetFilters,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 272,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final vegetable = items[index];
                    return ProductCard(
                      vegetable: vegetable,
                      isFavorite: _favorites.isFavorite(vegetable.id),
                      onFavoriteToggle: () => _toggleFavorite(vegetable),
                      onTap: () => _openDetail(vegetable),
                      onAdd: () => _addToCart(vegetable),
                    );
                  }, childCount: items.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const BrandMark(size: 38),
        const Spacer(),
        Tooltip(
          message: 'Profile',
          child: Semantics(
            button: true,
            label: 'Open profile',
            excludeSemantics: true,
            child: InkWell(
              onTap: widget.onOpenProfile,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: limeDeep, width: 2),
                ),
                child: const ProfileAvatar(size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscovery() {
    final picks = _discoveryPicks;
    if (picks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Popular this week', style: h3),
        const SizedBox(height: 2),
        Text('A little inspiration for your next meal.', style: bodySmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: picks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final vegetable = picks[index];
              final heroTag = 'vegetable-${vegetable.id}-discovery';
              return _DiscoveryCard(
                vegetable: vegetable,
                heroTag: heroTag,
                isFavorite: _favorites.isFavorite(vegetable.id),
                onTap: () => _openDetail(vegetable, heroTag: heroTag),
                onFavoriteToggle: () => _toggleFavorite(vegetable),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return AnimatedBuilder(
      animation: _user,
      builder: (context, _) {
        return Semantics(
          button: true,
          label:
              'Change delivery address. ${_user.addressLabel}, '
              '${_user.addressDetail}',
          onTap: _showAddressPicker,
          excludeSemantics: true,
          child: Material(
            color: surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: line.withValues(alpha: 0.9)),
            ),
            child: InkWell(
              onTap: _showAddressPicker,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: lime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 19,
                        color: forest,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DELIVER TO',
                            style: overline.copyWith(fontSize: 8.5),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _user.addressLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleSmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: forestDeep.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: body.copyWith(fontWeight: FontWeight.w500),
        cursorColor: forest,
        decoration: InputDecoration(
          hintText: "What's for dinner tonight?",
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: muted, size: 21),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _query.trim().isEmpty ? 'Fresh picks' : 'Search results',
          style: h2,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: bodySmall,
          ),
        ),
      ],
    );
  }
}

class _StaleCatalogBanner extends StatelessWidget {
  const _StaleCatalogBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: goldSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 18, color: tomato),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Showing saved picks — latest sync failed.',
                style: bodySmall.copyWith(color: ink),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: forest,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? forest : surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: selected ? forest : line),
        ),
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: lime,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  text,
                  style: label.copyWith(
                    color: selected ? white : ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.vegetable,
    required this.heroTag,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Vegetable vegetable;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: Material(
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                      tag: heroTag,
                      child: VegetableImage(
                        asset: vegetable.localImage,
                        url: vegetable.imageUrl,
                        semanticLabel: vegetable.name,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(
                        isFavorite: isFavorite,
                        onPressed: onFavoriteToggle,
                        name: vegetable.name,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vegetable.categoryLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: overline.copyWith(color: leaf, fontSize: 8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vegetable.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleSmall.copyWith(fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rupiah(vegetable.price),
                      style: price.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onCopyCode});

  final VoidCallback onCopyCode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        final imageSize = compact ? 114.0 : 146.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [forestDeep, forest, leaf],
              stops: [0, 0.6, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: forestDeep.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: -40,
                bottom: -80,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lime.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: white.withValues(alpha: 0.08)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: lime,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'PAY DAY SPECIAL',
                                style: overline.copyWith(
                                  color: lime,
                                  fontSize: 8.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pay Day\nShop Day',
                            style: h1.copyWith(
                              color: white,
                              fontSize: compact ? 27 : 30,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Extra 10% off with code\nPAYDAY at checkout.',
                            style: bodySmall.copyWith(
                              color: white.withValues(alpha: 0.72),
                              fontSize: 10.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _CopyCodeButton(onPressed: onCopyCode),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: imageSize,
                      child: Center(
                        child: SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: white.withValues(alpha: 0.28),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: forestDeep.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: const VegetableImage(
                                      asset: 'asset/image/vegetables/6.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: compact ? -2 : -4,
                                bottom: compact ? 2 : 4,
                                child: Container(
                                  width: compact ? 38 : 46,
                                  height: compact ? 38 : 46,
                                  decoration: BoxDecoration(
                                    color: lime,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: forest, width: 3),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '10%',
                                    style: label.copyWith(
                                      color: forest,
                                      fontWeight: FontWeight.w700,
                                      fontSize: compact ? 10 : 11.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CopyCodeButton extends StatelessWidget {
  const _CopyCodeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy promo code',
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: lime,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.content_copy_rounded, size: 14, color: forest),
                const SizedBox(width: 6),
                Text(
                  'Copy code',
                  style: label.copyWith(
                    color: forest,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: selected ? lime.withValues(alpha: 0.4) : surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: selected ? limeDeep : line),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 19, color: forest),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleSmall),
                        const SizedBox(height: 2),
                        Text(subtitle, style: caption),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: forest,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ColoredBox(color: sand)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 8,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: 110,
                  height: 13,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: 74,
                  height: 12,
                  decoration: BoxDecoration(
                    color: sand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
