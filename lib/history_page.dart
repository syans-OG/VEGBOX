import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/utils/formatters.dart';
import 'models/order.dart';
import 'order_detail_page.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/empty_state.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/order_status_badge.dart';
import 'ui/widgets/vegetable_image.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({
    super.key,
    required this.onOpenCart,
    required this.onBrowse,
  });

  final VoidCallback onOpenCart;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final orderService = getIt<OrderService>();
    final cart = getIt<CartService>();

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: orderService,
        builder: (context, _) {
          final orders = orderService.orders;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order history', style: h1),
                    const SizedBox(height: 5),
                    Text(
                      'Every basket, right where you left it.',
                      style: bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No orders yet',
                        message:
                            'Your first basket of fresh picks is only a few taps away.',
                        actionLabel: 'Start shopping',
                        onAction: onBrowse,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (final order in orders) ...[
                            _OrderCard(
                              order: order,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailPage(
                                    orderId: order.id,
                                    onOpenCart: onOpenCart,
                                  ),
                                ),
                              ),
                              onBuyAgain: () {
                                for (final item in order.items) {
                                  cart.addItem(item);
                                }
                                showAppSnackBar(
                                  context,
                                  '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} added to your basket.',
                                  actionLabel: 'View cart',
                                  onAction: onOpenCart,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onBuyAgain,
  });

  final Order order;
  final VoidCallback onTap;
  final VoidCallback onBuyAgain;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: titleSmall),
                        const SizedBox(height: 2),
                        Text(dateTimeLabel(order.createdAt), style: caption),
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (
                    var index = 0;
                    index < order.items.length && index < 3;
                    index++
                  ) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: VegetableImage(
                          asset: order.items[index].imageAsset,
                          url: order.items[index].imageUrl,
                          semanticLabel: order.items[index].name,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (order.items.length > 3)
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: line),
                      ),
                      child: Text(
                        '+${order.items.length - 3}',
                        style: label.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order.items.map((item) => item.name).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: bodySmall.copyWith(color: muted),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                          style: caption,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          rupiah(order.total),
                          style: price.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: background,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: const BorderSide(color: line),
                    ),
                    child: InkWell(
                      onTap: onBuyAgain,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Center(
                          widthFactor: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.replay_rounded,
                                  size: 15,
                                  color: forest,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Buy again',
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
