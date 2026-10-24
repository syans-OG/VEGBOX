import 'package:flutter/material.dart';

import 'auth_page.dart';
import 'cart_page.dart';
import 'core/di/injection.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'services/cart_service.dart';
import 'services/notification_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _select(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  Future<void> _logout() async {
    await getIt.reset();
    setupLocator();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(
            onOpenCart: () => _select(2),
            onOpenProfile: () => _select(4),
          ),
          const NotificationsPage(),
          CartPage(
            onBrowse: () => _select(0),
            onOrderPlaced: () => _select(3),
            onOpenCart: () => _select(2),
          ),
          HistoryPage(onOpenCart: () => _select(2), onBrowse: () => _select(0)),
          ProfilePage(
            onOpenOrders: () => _select(3),
            onOpenCart: () => _select(2),
            onLoggedOut: _logout,
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onSelect: _select,
        cart: getIt<CartService>(),
        notifications: getIt<NotificationService>(),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.onSelect,
    required this.cart,
    required this.notifications,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final CartService cart;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([cart, notifications]),
      builder: (context, _) {
        return ColoredBox(
          color: background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: line.withValues(alpha: 0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: forestDeep.withValues(alpha: 0.14),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _item(0, Icons.home_rounded, 'Home'),
                        _item(
                          1,
                          Icons.notifications_none_rounded,
                          'Notifications',
                          badge: notifications.unreadCount,
                        ),
                        _cartItem(),
                        _item(3, Icons.receipt_long_rounded, 'Orders'),
                        _item(4, Icons.person_outline_rounded, 'Profile'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _item(int position, IconData icon, String label, {int badge = 0}) {
    final active = index == position;
    return Expanded(
      child: Tooltip(
        message: label,
        child: Semantics(
          button: true,
          selected: active,
          label: label,
          child: InkWell(
            onTap: () => onSelect(position),
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: active ? lime : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: active ? forest : muted,
                      ),
                    ),
                    if (badge > 0)
                      Positioned(
                        top: 6,
                        right: 5,
                        child: _NavBadge(count: badge),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartItem() {
    final active = index == 2;
    return Expanded(
      child: Tooltip(
        message: 'Cart',
        child: Semantics(
          button: true,
          selected: active,
          label:
              'Cart, ${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: forest.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: forest,
                shape: CircleBorder(
                  side: BorderSide(
                    color: active ? lime : surface,
                    width: active ? 3 : 4,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(2),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 24,
                            color: lime,
                          ),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: _NavBadge(count: cart.itemCount),
                          ),
                      ],
                    ),
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

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
        decoration: BoxDecoration(
          color: tomato,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: surface, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 9 ? '9+' : '$count',
          style: caption.copyWith(
            color: white,
            fontSize: 8.5,
            height: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
