import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../colors.dart';
import '../typography.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      OrderStatus.processing => (goldSoft, const Color(0xFF8A5A00)),
      OrderStatus.packed => (lime, forest),
      OrderStatus.shipping => (limeDeep, forest),
      OrderStatus.delivered => (const Color(0xFFE7EFE4), leaf),
      OrderStatus.cancelled => (tomatoSoft, tomato),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: label.copyWith(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
