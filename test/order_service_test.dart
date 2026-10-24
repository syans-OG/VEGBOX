import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/models/order.dart';
import 'package:vegbox/services/order_service.dart';

import 'support/app_test_harness.dart';

void main() {
  test('orders placed in the same second keep unique ids', () {
    final orders = OrderService();
    final ids = <String>{};

    for (var index = 0; index < 3; index++) {
      final order = orders.placeOrder(
        items: const [testCartItem],
        discount: 0,
        delivery: 12000,
        addressLabel: 'Kost athena',
        addressDetail: 'Jl. Imam Bonjol No. 5, Semarang',
        paymentMethod: PaymentMethod.cashOnDelivery,
      );
      ids.add(order.id);
    }

    expect(ids.length, 3);
  });

  test('unknown orders report failure and rollback removes the order', () {
    final orders = OrderService();
    final order = orders.placeOrder(
      items: const [testCartItem],
      discount: 0,
      delivery: 12000,
      addressLabel: 'Kost athena',
      addressDetail: 'Jl. Imam Bonjol No. 5, Semarang',
      paymentMethod: PaymentMethod.cashOnDelivery,
    );

    expect(orders.advanceStatus('missing'), isFalse);
    expect(orders.cancelOrder('missing'), isFalse);
    expect(orders.removeOrder('missing'), isFalse);

    expect(orders.removeOrder(order.id), isTrue);
    expect(orders.orderById(order.id), isNull);
  });
}
