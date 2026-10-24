import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/core/di/injection.dart';
import 'package:vegbox/models/order.dart';
import 'package:vegbox/order_detail_page.dart';
import 'package:vegbox/services/order_service.dart';

import 'support/app_test_harness.dart';

void main() {
  setUp(resetApp);

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('order detail cancels an active order', (tester) async {
    final orders = getIt<OrderService>();
    orders.placeOrder(
      items: const [testCartItem],
      discount: 0,
      delivery: 12000,
      addressLabel: 'Kost athena',
      addressDetail: 'Jl. Imam Bonjol No. 5, Semarang',
      paymentMethod: PaymentMethod.cashOnDelivery,
    );
    final orderId = orders.orders.first.id;

    await tester.pumpWidget(
      appWith(OrderDetailPage(orderId: orderId, onOpenCart: () {})),
    );

    expect(find.text('Order details'), findsOneWidget);
    expect(find.text('Processing'), findsWidgets);

    final cancel = find.text('Cancel order');
    await tester.dragUntilVisible(
      cancel,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(cancel, findsOneWidget);

    expect(find.text('Advance status (demo)'), findsNothing);

    orders.advanceStatus(orderId);
    await tester.pumpAndSettle();

    expect(orders.orderById(orderId)?.status, OrderStatus.packed);

    final packed = find.text('Packed');
    await tester.dragUntilVisible(
      packed,
      find.byType(Scrollable).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();
    expect(packed, findsWidgets);

    await tester.dragUntilVisible(
      cancel,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();

    expect(find.text('Cancel this order?'), findsOneWidget);
    await tester.tap(find.text('Cancel order').last);
    await tester.pumpAndSettle();

    expect(orders.orderById(orderId)?.status, OrderStatus.cancelled);

    final cancelled = find.text('Cancelled');
    await tester.dragUntilVisible(
      cancelled,
      find.byType(Scrollable).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();
    expect(cancelled, findsWidgets);

    final buyAgain = find.text('Buy again');
    await tester.dragUntilVisible(
      buyAgain,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(buyAgain, findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
