import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/utils/formatters.dart';
import 'models/cart_item.dart';
import 'models/order.dart';
import 'order_detail_page.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/app_button.dart';
import 'ui/widgets/empty_state.dart';
import 'ui/widgets/feedback.dart';
import 'ui/widgets/quantity_stepper.dart';
import 'ui/widgets/vegetable_image.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    required this.onBrowse,
    required this.onOrderPlaced,
    required this.onOpenCart,
  });

  final VoidCallback onBrowse;
  final VoidCallback onOrderPlaced;
  final VoidCallback onOpenCart;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cart = getIt<CartService>();
  final _orderService = getIt<OrderService>();
  final _user = getIt<UserService>();
  final _promoController = TextEditingController();

  String? _appliedPromo;
  String? _promoError;
  bool _isSubmitting = false;

  int get _discount => _appliedPromo == null
      ? 0
      : (_cart.subtotal * AppConstants.promoDiscount).round();

  int get _delivery => _cart.subtotal >= AppConstants.freeDeliveryMinimum
      ? 0
      : AppConstants.deliveryFee;

  int get _total => _cart.subtotal - _discount + _delivery;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    FocusScope.of(context).unfocus();
    if (code == AppConstants.promoCode) {
      setState(() {
        _appliedPromo = code;
        _promoError = null;
      });
      showAppSnackBar(context, 'PAYDAY applied — 10% off your basket.');
      return;
    }
    setState(() => _promoError = 'That code is not valid. Try PAYDAY.');
  }

  void _removePromo() {
    setState(() {
      _appliedPromo = null;
      _promoError = null;
      _promoController.clear();
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final items = List<CartItem>.from(_cart.items);
      final discount = _discount;
      final delivery = _delivery;
      final total = _total;

      final addressLabel = _user.addressLabel;
      final addressDetail = _user.addressDetail;

      final payment = await showModalBottomSheet<PaymentMethod>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _CheckoutSheet(
          items: items,
          subtotal: _cart.subtotal,
          discount: discount,
          delivery: delivery,
          total: total,
          addressLabel: addressLabel,
          addressDetail: addressDetail,
        ),
      );
      if (payment == null || !mounted) return;

      final order = _orderService.placeOrder(
        items: items,
        discount: discount,
        delivery: delivery,
        addressLabel: addressLabel,
        addressDetail: addressDetail,
        paymentMethod: payment,
      );

      try {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              icon: Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 32, color: forest),
              ),
              title: const Text('Order placed'),
              content: Text(
                'Your fresh picks are being packed for $addressLabel and will be on their way shortly.',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(
                          orderId: order.id,
                          onOpenCart: widget.onOpenCart,
                        ),
                      ),
                    );
                  },
                  child: const Text('View order'),
                ),
              ],
            );
          },
        );
      } catch (error, stack) {
        debugPrint('Checkout confirmation failed: $error\n$stack');
        _orderService.removeOrder(order.id);
        if (mounted) {
          showAppSnackBar(
            context,
            'Checkout could not be completed. Please try again.',
          );
        }
        return;
      }

      _cart.clear();
      if (!mounted) return;
      _promoController.clear();
      setState(() {
        _appliedPromo = null;
        _promoError = null;
      });
      widget.onOrderPlaced();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Your basket', style: h1),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lime,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_cart.itemCount} ${_cart.itemCount == 1 ? 'item' : 'items'}',
                            style: label.copyWith(
                              color: forest,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _cart.isEmpty
                          ? 'A good meal starts with a full basket.'
                          : 'From local farms to your kitchen, in one checkout.',
                      style: bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _cart.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_basket_outlined,
                        title: 'Your basket is empty',
                        message:
                            'Fill it with something fresh — leafy greens, sweet tomatoes, or roots for dinner.',
                        actionLabel: 'Browse vegetables',
                        onAction: widget.onBrowse,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (final item in _cart.items) ...[
                            _CartItemCard(
                              item: item,
                              onQuantityChanged: (quantity) {
                                _cart.setQuantity(item.vegetableId, quantity);
                              },
                              onRemove: () {
                                _cart.remove(item.vegetableId);
                                showAppSnackBar(
                                  context,
                                  '${item.name} removed from your basket.',
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 4),
                          _buildPromoCard(),
                          const SizedBox(height: 14),
                          _buildSummary(),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Checkout',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _isSubmitting ? null : _checkout,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Simulated checkout · no real payment is processed.',
                            textAlign: TextAlign.center,
                            style: caption,
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  size: 17,
                  color: forest,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Have a promo code?', style: titleSmall),
                    Text('Try PAYDAY for 10% off.', style: caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_appliedPromo == null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_promoError != null) {
                        setState(() => _promoError = null);
                      }
                    },
                    onSubmitted: (_) => _applyPromo(),
                    style: body.copyWith(fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Enter code',
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 88,
                  child: AppButton(
                    label: 'Apply',
                    height: 50,
                    onPressed: _applyPromo,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: lime.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: forest,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'PAYDAY applied · 10% off',
                    style: label.copyWith(color: forest, fontSize: 11.5),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Remove promo code',
                    onPressed: _removePromo,
                    icon: const Icon(Icons.close_rounded, size: 17),
                    color: forest,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                  ),
                ],
              ),
            ),
          if (_promoError != null) ...[
            const SizedBox(height: 6),
            Text(_promoError!, style: caption.copyWith(color: tomato)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Order summary', style: title),
              const Spacer(),
              Text(
                '${_cart.itemCount} ${_cart.itemCount == 1 ? 'item' : 'items'}',
                style: caption,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(name: 'Subtotal', value: rupiah(_cart.subtotal)),
          if (_discount > 0)
            _SummaryRow(
              name: 'Discount · PAYDAY',
              value: '-${rupiah(_discount)}',
              valueColor: leaf,
            ),
          _SummaryRow(
            name: 'Delivery',
            value: _delivery == 0 ? 'Free' : rupiah(_delivery),
            valueColor: _delivery == 0 ? leaf : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            children: [
              Text('Total', style: title),
              const Spacer(),
              Text(rupiah(_total), style: price.copyWith(fontSize: 21)),
            ],
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Free delivery on orders over ${rupiah(AppConstants.freeDeliveryMinimum)}.',
              style: caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 74,
              height: 92,
              child: VegetableImage(
                asset: item.imageAsset,
                url: item.imageUrl,
                semanticLabel: item.name,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleSmall,
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        tooltip: 'Remove ${item.name}',
                        onPressed: onRemove,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: muted,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(AppConstants.categoryLabel(item.category), style: caption),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            rupiah(item.price),
                            style: price.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    QuantityStepper(
                      value: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.name, required this.value, this.valueColor});

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

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    required this.addressLabel,
    required this.addressDetail,
  });

  final List<CartItem> items;
  final int subtotal;
  final int discount;
  final int delivery;
  final int total;
  final String addressLabel;
  final String addressDetail;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  PaymentMethod _payment = PaymentMethod.cashOnDelivery;

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.fold(0, (sum, item) => sum + item.quantity);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Confirm your order', style: h2),
              const SizedBox(height: 4),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'} from local farms.',
                style: bodySmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
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
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 19,
                        color: forest,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DELIVER TO',
                            style: overline.copyWith(fontSize: 8.5),
                          ),
                          const SizedBox(height: 2),
                          Text(widget.addressLabel, style: titleSmall),
                          const SizedBox(height: 1),
                          Text(
                            widget.addressDetail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: line),
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < widget.items.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: 10),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 38,
                              height: 38,
                              child: VegetableImage(
                                asset: widget.items[index].imageAsset,
                                url: widget.items[index].imageUrl,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.items[index].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleSmall.copyWith(fontSize: 13),
                            ),
                          ),
                          Text(
                            '×${widget.items[index].quantity}',
                            style: caption,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            rupiah(widget.items[index].lineTotal),
                            style: label.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Payment method', style: overline),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: line),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < PaymentMethod.values.length;
                      index++
                    ) ...[
                      _PaymentOption(
                        method: PaymentMethod.values[index],
                        selected: _payment == PaymentMethod.values[index],
                        onTap: () {
                          setState(() {
                            _payment = PaymentMethod.values[index];
                          });
                        },
                      ),
                      if (index < PaymentMethod.values.length - 1)
                        const Divider(indent: 12, endIndent: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SummaryRow(name: 'Subtotal', value: rupiah(widget.subtotal)),
              if (widget.discount > 0)
                _SummaryRow(
                  name: 'Discount · PAYDAY',
                  value: '-${rupiah(widget.discount)}',
                  valueColor: leaf,
                ),
              _SummaryRow(
                name: 'Delivery',
                value: widget.delivery == 0 ? 'Free' : rupiah(widget.delivery),
                valueColor: widget.delivery == 0 ? leaf : null,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Row(
                children: [
                  Text('Total', style: title),
                  const Spacer(),
                  Text(
                    rupiah(widget.total),
                    style: price.copyWith(fontSize: 21),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Place order · ${rupiah(widget.total)}',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.pop(context, _payment),
              ),
              const SizedBox(height: 8),
              Text(
                'This is a demo checkout. No payment will be taken.',
                textAlign: TextAlign.center,
                style: caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: method.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(_paymentIcon(method), size: 20, color: forest),
              const SizedBox(width: 10),
              Expanded(child: Text(method.label, style: titleSmall)),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? forest : line,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: forest,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _paymentIcon(PaymentMethod method) => switch (method) {
  PaymentMethod.cashOnDelivery => Icons.payments_outlined,
  PaymentMethod.bankTransfer => Icons.account_balance_outlined,
  PaymentMethod.eWallet => Icons.account_balance_wallet_outlined,
};
