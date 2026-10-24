enum AppNotificationType { promo, order, stock, delivery, tip }

class AppNotification {
  AppNotification({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.type,
    required this.isToday,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String timeLabel;
  final AppNotificationType type;
  final bool isToday;
  bool isRead;
}
