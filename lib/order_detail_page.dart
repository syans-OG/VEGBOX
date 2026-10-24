import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/utils/formatters.dart';
import 'models/cart_item.dart';
import 'models/order.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/app_button.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/order_status_badge.dart';
import 'ui/widgets/vegetable_image.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.onOpenCart,
  });

  final String orderId;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    final orders = getIt<OrderService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order details', style: title.copyWith(fontSize: 18)),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AnimatedBuilder(
              animation: orders,
              builder: (context, _) {
                final order = orders.orderById(orderId);
                if (order == null) {
                  return const _OrderNotFound();
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _OrderHeader(order: order),
                    const SizedBox(height: 16),
                    if (order.status == OrderStatus.cancelled)
                      const _CancelledNotice()
                    else
                      _StatusTimeline(status: order.status),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'DELIVER TO',
                      value: order.addressLabel,
                      subtitle: order.addressDetail,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.credit_card_outlined,
                      title: 'PAYMENT',
                      value: order.paymentMethod.label,
                      subtitle: 'Simulated payment method.',
                    ),
                    const SizedBox(height: 12),
                    _ItemsCard(items: order.items),
                    const SizedBox(height: 12),
                    _SummaryCard(order: order),
                    const SizedBox(height: 20),
                    if (order.canCancel) ...[
                      AppButton(
                        label: 'Cancel order',
                        variant: AppButtonVariant.outline,
                        foregroundColor: tomato,
                        onPressed: () => _confirmCancel(context, orders, order),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (order.status == OrderStatus.delivered ||
                        order.status == OrderStatus.cancelled) ...[
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'Buy again',
                        icon: Icons.replay_rounded,
                        variant: AppButtonVariant.soft,
                        onPressed: () {
                          final cart = getIt<CartService>();
                          for (final item in order.items) {
                            cart.addItem(item);
                          }
                          Navigator.of(context).pop();
                          onOpenCart();
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderNotFound extends StatelessWidget {
  const _OrderNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 40, color: muted),
            const SizedBox(height: 12),
            Text('Order not found', style: title),
            const SizedBox(height: 4),
            Text(
              'This order may no longer be available.',
              textAlign: TextAlign.center,
              style: bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ORDER', style: overline),
              const SizedBox(height: 3),
              Text(order.id, style: h2),
              const SizedBox(height: 3),
              Text(dateTimeLabel(order.createdAt), style: bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OrderStatusBadge(status: order.status),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.processing,
    OrderStatus.packed,
    OrderStatus.shipping,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(status);

    return Semantics(
      label: 'Order status: ${status.label}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: line),
        ),
        child: Column(
          children: [
            for (var index = 0; index < _steps.length; index++)
              SizedBox(
                height: 58,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _TimelineDot(
                          state: index < currentIndex
                              ? _TimelineStep.completed
                              : index == currentIndex
                              ? _TimelineStep.current
                              : _TimelineStep.upcoming,
                        ),
                        if (index < _steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: index < currentIndex ? forest : line,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _steps[index].label,
                              style: titleSmall.copyWith(
                                color: index <= currentIndex ? ink : muted,
                              ),
                            ),
                            if (index == currentIndex) ...[
                              const SizedBox(height: 1),
                              Text(
                                'Current status',
                                style: caption.copyWith(color: leaf),
                              ),
                            ],
                          ],
                        ),
                      ),
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

enum _TimelineStep { completed, current, upcoming }

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.state});

  final _TimelineStep state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _TimelineStep.completed;
    final isCurrent = state == _TimelineStep.current;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? forest : (isCurrent ? lime : surface),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted || isCurrent ? forest : line,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 15, color: lime)
          : isCurrent
          ? const Center(
              child: SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: forest,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _CancelledNotice extends StatelessWidget {
  const _CancelledNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tomatoSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tomato.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 20, color: tomato),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order cancelled',
                  style: titleSmall.copyWith(color: tomato),
                ),
                const SizedBox(height: 2),
                Text(
                  'This order will not be delivered.',
                  style: bodySmall.copyWith(color: tomato),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
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
            child: Icon(icon, size: 19, color: forest),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: overline.copyWith(fontSize: 8.5)),
                const SizedBox(height: 2),
                Text(value, style: titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ITEMS', style: overline.copyWith(fontSize: 8.5)),
          const SizedBox(height: 10),
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: VegetableImage(
                      asset: items[index].imageAsset,
                      url: items[index].imageUrl,
                      semanticLabel: items[index].name,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleSmall,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${items[index].quantity} × ${rupiah(items[index].price)}',
                        style: caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rupiah(items[index].lineTotal),
                  style: price.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          _SummaryLine(name: 'Subtotal', value: rupiah(order.subtotal)),
          if (order.discount > 0)
            _SummaryLine(
              name: 'Discount',
              value: '-${rupiah(order.discount)}',
              valueColor: leaf,
            ),
          _SummaryLine(
            name: 'Delivery',
            value: order.delivery == 0 ? 'Free' : rupiah(order.delivery),
            valueColor: order.delivery == 0 ? leaf : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Row(
            children: [
              Text('Total', style: title),
              const Spacer(),
              Text(rupiah(order.total), style: price.copyWith(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.name,
    required this.value,
    this.valueColor,
  });

  final String name;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(name, style: bodySmall),
          const Spacer(),
          Text(
            value,
            style: label.copyWith(
              color: valueColor ?? ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmCancel(
  BuildContext context,
  OrderService orders,
  Order order,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          'This cannot be undone. Your items will be released back to the farm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel order'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return;

  if (!orders.cancelOrder(order.id)) {
    showAppSnackBar(context, 'This order can no longer be cancelled.');
    return;
  }
  showAppSnackBar(context, 'Order ${order.id} cancelled.');
}
