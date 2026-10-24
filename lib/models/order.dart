import 'cart_item.dart';

enum OrderStatus {
  processing('Processing'),
  packed('Packed'),
  shipping('On the way'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;
}

enum PaymentMethod {
  cashOnDelivery('Cash on delivery'),
  bankTransfer('Bank transfer'),
  eWallet('E-wallet');

  const PaymentMethod(this.label);

  final String label;
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.status,
    required this.addressLabel,
    required this.addressDetail,
    required this.paymentMethod,
  });

  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final int subtotal;
  final int discount;
  final int delivery;
  final OrderStatus status;
  final String addressLabel;
  final String addressDetail;
  final PaymentMethod paymentMethod;

  int get total => subtotal - discount + delivery;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canCancel =>
      status == OrderStatus.processing || status == OrderStatus.packed;

  OrderStatus? get nextStatus => switch (status) {
    OrderStatus.processing => OrderStatus.packed,
    OrderStatus.packed => OrderStatus.shipping,
    OrderStatus.shipping => OrderStatus.delivered,
    _ => null,
  };

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      createdAt: createdAt,
      items: items,
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      status: status ?? this.status,
      addressLabel: addressLabel,
      addressDetail: addressDetail,
      paymentMethod: paymentMethod,
    );
  }
}
