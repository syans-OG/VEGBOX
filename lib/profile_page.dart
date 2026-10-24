import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/utils/validators.dart';
import 'favorites_page.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/app_button.dart';
import 'ui/widgets/app_text_field.dart';
import 'ui/widgets/brand_mark.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/profile_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onOpenOrders,
    required this.onOpenCart,
    required this.onLoggedOut,
  });

  final VoidCallback onOpenOrders;
  final VoidCallback onOpenCart;
  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context) {
    final user = getIt<UserService>();
    final orders = getIt<OrderService>();
    final cart = getIt<CartService>();
    final favorites = getIt<FavoritesService>();
    final notifications = getIt<NotificationService>();

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          user,
          orders,
          cart,
          favorites,
          notifications,
        ]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  Expanded(child: Text('Profile', style: h1)),
                  const BrandMark(size: 32, showWordmark: false),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileHeader(
                user: user,
                orderCount: orders.count,
                basketCount: cart.itemCount,
                updateCount: notifications.unreadCount,
                onEdit: () => _editProfile(context, user),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('ACCOUNT', style: overline),
              ),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: line),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit profile',
                      subtitle: 'Name and phone number',
                      onTap: () => _editProfile(context, user),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.receipt_long_outlined,
                      title: 'My orders',
                      subtitle:
                          '${orders.count} ${orders.count == 1 ? 'order' : 'orders'} placed',
                      onTap: onOpenOrders,
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      subtitle:
                          '${favorites.count} ${favorites.count == 1 ? 'vegetable' : 'vegetables'} saved',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FavoritesPage(onOpenCart: onOpenCart),
                        ),
                      ),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification settings',
                      subtitle: 'Order updates and fresh offers',
                      onTap: () => _showSettings(context, user),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & FAQ',
                      subtitle: 'Answers to common questions',
                      onTap: () => _showFaq(context),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'See you soon',
                      destructive: true,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'vegbox v1.0.0 · fresh from local farms',
                  style: caption.copyWith(fontSize: 10.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, UserService user) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(user: user),
    );
    if (saved == true && context.mounted) {
      showAppSnackBar(context, 'Profile updated.');
    }
  }

  Future<void> _showSettings(BuildContext context, UserService user) async {
    var orderUpdates = user.orderUpdates;
    var promotions = user.promotions;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SheetHandle(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Notification settings', style: h2),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose what lands in your notifications.',
                      style: bodySmall,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: orderUpdates,
                            onChanged: (value) {
                              setSheetState(() => orderUpdates = value);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            title: Text('Order updates', style: titleSmall),
                            subtitle: Text(
                              'Packing, delivery, and arrival updates.',
                              style: caption,
                            ),
                          ),
                          const Divider(indent: 16, endIndent: 16),
                          SwitchListTile(
                            value: promotions,
                            onChanged: (value) {
                              setSheetState(() => promotions = value);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            title: Text(
                              'Promotions & fresh drops',
                              style: titleSmall,
                            ),
                            subtitle: Text(
                              'Seasonal offers and new harvests.',
                              style: caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Save preferences',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        user.updatePreferences(
                          orderUpdates: orderUpdates,
                          promotions: promotions,
                        );
                        Navigator.pop(sheetContext, true);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true && context.mounted) {
      showAppSnackBar(context, 'Notification preferences saved.');
    }
  }

  void _showFaq(BuildContext context) {
    const faqs = [
      (
        question: 'Where do the vegetables come from?',
        answer:
            'We work with local farms around Semarang. Produce is harvested close to your delivery day, so it arrives fresh and stays crisp for longer.',
      ),
      (
        question: 'How long does delivery take?',
        answer:
            'Most orders arrive in 25–35 minutes during opening hours. You can follow every status from the Orders tab.',
      ),
      (
        question: 'Can I change my delivery address?',
        answer:
            'Yes. Tap the address card on the Home tab and choose another saved address before checkout.',
      ),
      (
        question: 'Is the payment real?',
        answer:
            'No. VegBox is a Flutter learning project. Checkout, orders, and notifications are simulated, so no payment is ever taken.',
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Column(
                    children: [
                      const _SheetHandle(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Text('Help & FAQ', style: h2)),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Everything you need to know before checkout.',
                          style: bodySmall,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: line),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < faqs.length;
                              index++
                            ) ...[
                              ExpansionTile(
                                shape: const Border(),
                                collapsedShape: const Border(),
                                iconColor: forest,
                                collapsedIconColor: muted,
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                title: Text(
                                  faqs[index].question,
                                  style: titleSmall,
                                ),
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      faqs[index].answer,
                                      style: bodySmall.copyWith(height: 1.6),
                                    ),
                                  ),
                                ],
                              ),
                              if (index < faqs.length - 1)
                                const Divider(indent: 16, endIndent: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'You can sign back in anytime with your phone number. Your order history will be waiting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: tomato),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      onLoggedOut();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.orderCount,
    required this.basketCount,
    required this.updateCount,
    required this.onEdit,
  });

  final UserService user;
  final int orderCount;
  final int basketCount;
  final int updateCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [forestDeep, forest, leaf],
          stops: [0, 0.62, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: forestDeep.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -52,
            right: -34,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lime.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: lime, width: 2),
                      ),
                      child: ProfileAvatar(
                        size: 69,
                        semanticLabel: '${user.name} profile photo',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: h3.copyWith(color: white, fontSize: 24),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.phone,
                            style: bodySmall.copyWith(
                              color: white.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Edit profile',
                      child: Material(
                        color: white.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: white,
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HeaderStat(
                          value: '$orderCount',
                          label: 'Orders',
                        ),
                      ),
                      const _HeaderDivider(),
                      Expanded(
                        child: _HeaderStat(
                          value: '$basketCount',
                          label: 'In basket',
                        ),
                      ),
                      const _HeaderDivider(),
                      Expanded(
                        child: _HeaderStat(
                          value: '$updateCount',
                          label: 'Updates',
                        ),
                      ),
                    ],
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: title.copyWith(color: white, fontSize: 17)),
        const SizedBox(height: 1),
        Text(
          label,
          style: caption.copyWith(
            color: white.withValues(alpha: 0.62),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: white.withValues(alpha: 0.14),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? tomato : forest;
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: destructive ? tomatoSoft : background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleSmall.copyWith(
                        color: destructive ? tomato : ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(subtitle, style: caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 66, endIndent: 14);
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final UserService user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.user.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text('Edit profile', style: h2)),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Keep your details up to date.', style: bodySmall),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Full name',
                  hint: 'Your full name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: validateName,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Phone number',
                  hint: '08xx xxxx xxxx',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: validatePhone,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 22),
                AppButton(
                  label: 'Save changes',
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
