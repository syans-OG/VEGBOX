import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService extends ChangeNotifier {
  OrderService() {
    _orders.addAll(_seedOrders());
  }

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  int get count => _orders.length;

  Order? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Order placeOrder({
    required List<CartItem> items,
    required int discount,
    required int delivery,
    required String addressLabel,
    required String addressDetail,
    required PaymentMethod paymentMethod,
    OrderStatus status = OrderStatus.processing,
  }) {
    final now = DateTime.now();
    final subtotal = items.fold(0, (sum, item) => sum + item.lineTotal);
    final order = Order(
      id: _nextOrderId(now),
      createdAt: now,
      items: List.unmodifiable(items),
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      status: status,
      addressLabel: addressLabel,
      addressDetail: addressDetail,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  String _nextOrderId(DateTime now) {
    var serial = (now.millisecondsSinceEpoch ~/ 1000) % 100000;
    while (orderById('#VB${serial.toString().padLeft(5, '0')}') != null) {
      serial = (serial + 1) % 100000;
    }
    return '#VB${serial.toString().padLeft(5, '0')}';
  }

  bool advanceStatus(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return false;

    final next = _orders[index].nextStatus;
    if (next == null) return false;

    _orders[index] = _orders[index].copyWith(status: next);
    notifyListeners();
    return true;
  }

  bool cancelOrder(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0 || !_orders[index].canCancel) return false;

    _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
    notifyListeners();
    return true;
  }

  bool removeOrder(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return false;

    _orders.removeAt(index);
    notifyListeners();
    return true;
  }

  List<Order> _seedOrders() {
    final now = DateTime.now();
    return [
      _seed(
        id: '#VB24031',
        createdAt: now.subtract(const Duration(hours: 3)),
        status: OrderStatus.shipping,
        paymentMethod: PaymentMethod.bankTransfer,
        delivery: AppConstants.deliveryFee,
        items: [
          _line(1, 'Bayam Hijau', 'Sayuran Daun', 3500, 2),
          _line(6, 'Tomat Merah', 'Sayuran Buah', 7000, 1),
        ],
      ),
      _seed(
        id: '#VB24028',
        createdAt: now.subtract(const Duration(days: 4, hours: 2)),
        status: OrderStatus.delivered,
        paymentMethod: PaymentMethod.eWallet,
        items: [
          _line(10, 'Wortel Berastagi', 'Sayuran Umbi', 8000, 1),
          _line(11, 'Kentang Dieng', 'Sayuran Umbi', 14000, 1),
          _line(12, 'Bawang Merah Brebes', 'Sayuran Umbi', 18000, 1),
        ],
      ),
      _seed(
        id: '#VB24019',
        createdAt: now.subtract(const Duration(days: 12)),
        status: OrderStatus.cancelled,
        items: [
          _line(4, 'Selada Keriting', 'Sayuran Daun', 6000, 2),
          _line(8, 'Mentimun', 'Sayuran Buah', 4500, 2),
          _line(14, 'Buncis Manis', 'Sayuran Polong', 6500, 2),
        ],
      ),
    ];
  }

  Order _seed({
    required String id,
    required DateTime createdAt,
    required List<CartItem> items,
    required OrderStatus status,
    PaymentMethod paymentMethod = PaymentMethod.cashOnDelivery,
    int discount = 0,
    int delivery = 0,
  }) {
    final subtotal = items.fold(0, (sum, item) => sum + item.lineTotal);
    return Order(
      id: id,
      createdAt: createdAt,
      items: List.unmodifiable(items),
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      status: status,
      addressLabel: AppConstants.defaultAddressLabel,
      addressDetail: AppConstants.defaultAddressDetail,
      paymentMethod: paymentMethod,
    );
  }

  CartItem _line(
    int id,
    String name,
    String category,
    int price,
    int quantity,
  ) {
    return CartItem(
      vegetableId: id,
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      imageAsset: AppConstants.imageFor(id),
      imageUrl: '',
    );
  }
}
