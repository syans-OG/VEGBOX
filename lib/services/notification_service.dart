import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [
    AppNotification(
      title: 'Pay Day is here',
      message:
          'Extra 10% off your basket with code PAYDAY. Valid until Sunday.',
      timeLabel: 'Just now',
      type: AppNotificationType.promo,
      isToday: true,
    ),
    AppNotification(
      title: 'Your order is on the way',
      message:
          '#VB24031 is packed and heading to your door. Estimated arrival 25–35 min.',
      timeLabel: '1h ago',
      type: AppNotificationType.delivery,
      isToday: true,
    ),
    AppNotification(
      title: 'Just harvested: sweet corn',
      message:
          'New stock from our local farm has landed. Pick some up before it sells out.',
      timeLabel: '2h ago',
      type: AppNotificationType.stock,
      isToday: true,
    ),
    AppNotification(
      title: 'Weekend veggie box',
      message:
          'Build your own box and save more. Choose any six vegetables for a fixed price.',
      timeLabel: 'Yesterday',
      type: AppNotificationType.promo,
      isToday: false,
      isRead: true,
    ),
    AppNotification(
      title: 'Order delivered',
      message: '#VB24028 has arrived. Enjoy your greens!',
      timeLabel: 'Yesterday',
      type: AppNotificationType.order,
      isToday: false,
      isRead: true,
    ),
    AppNotification(
      title: 'Keep greens crisp for longer',
      message:
          'Wrap leafy greens in a damp cloth and store them in the crisper drawer.',
      timeLabel: '2 days ago',
      type: AppNotificationType.tip,
      isToday: false,
      isRead: true,
    ),
  ];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  void markRead(AppNotification notification) {
    if (notification.isRead) return;
    notification.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    for (final notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }
}
