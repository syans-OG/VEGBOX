import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/cart_page.dart';
import 'package:vegbox/core/di/injection.dart';
import 'package:vegbox/models/order.dart';
import 'package:vegbox/services/cart_service.dart';
import 'package:vegbox/services/order_service.dart';

import 'support/app_test_harness.dart';

void main() {
  setUp(resetApp);

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('checkout places the order and clears the basket', (
    tester,
  ) async {
    final cart = getIt<CartService>();
    final orders = getIt<OrderService>();
    cart.add(testVegetable, quantity: 2);
    var openedOrders = false;

    await tester.pumpWidget(
      appWith(
        Scaffold(
          body: CartPage(
            onBrowse: () {},
            onOrderPlaced: () => openedOrders = true,
            onOpenCart: () {},
          ),
        ),
      ),
    );

    expect(find.text('Your basket'), findsOneWidget);

    final checkout = find.text('Checkout');
    await tester.dragUntilVisible(
      checkout,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(checkout);
    await tester.pumpAndSettle();

    expect(find.text('Confirm your order'), findsOneWidget);

    final bankTransfer = find.text('Bank transfer');
    await tester.ensureVisible(bankTransfer);
    await tester.tap(bankTransfer);
    await tester.pumpAndSettle();

    final placeOrder = find.textContaining('Place order');
    await tester.ensureVisible(placeOrder);
    await tester.pumpAndSettle();
    await tester.tap(placeOrder);
    await tester.pumpAndSettle();

    expect(find.text('Order placed'), findsOneWidget);
    expect(orders.orders.first.paymentMethod, PaymentMethod.bankTransfer);

    await tester.tap(find.text('View order'));
    await tester.pumpAndSettle();

    expect(cart.isEmpty, isTrue);
    expect(openedOrders, isTrue);
    expect(find.text('Order details'), findsOneWidget);
  });

  testWidgets('PAYDAY applies a ten percent discount', (tester) async {
    getIt<CartService>().add(testVegetable, quantity: 2);

    await tester.pumpWidget(
      appWith(
        Scaffold(
          body: CartPage(
            onBrowse: () {},
            onOrderPlaced: () {},
            onOpenCart: () {},
          ),
        ),
      ),
    );

    final promoField = find.byType(TextField);
    await tester.dragUntilVisible(
      promoField,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.enterText(promoField, 'PAYDAY');

    final apply = find.text('Apply');
    await tester.ensureVisible(apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();

    expect(find.textContaining('PAYDAY applied'), findsWidgets);
    expect(find.text('Rp 18.300'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
