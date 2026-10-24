import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'models/app_notification.dart';
import 'services/notification_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = getIt<NotificationService>();

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: service,
        builder: (context, _) {
          final today = service.notifications
              .where((item) => item.isToday)
              .toList();
          final earlier = service.notifications
              .where((item) => !item.isToday)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Notifications', style: h1)),
                        if (service.unreadCount > 0)
                          IconButton(
                            tooltip: 'Mark all as read',
                            onPressed: service.markAllRead,
                            icon: const Icon(Icons.done_all_rounded),
                            color: forest,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        service.unreadCount > 0
                            ? '${service.unreadCount} unread ${service.unreadCount == 1 ? 'message' : 'messages'} · fresh news and order updates.'
                            : 'All caught up. Fresh news and order updates.',
                        style: bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (today.isNotEmpty) ...[
                      const _GroupLabel(label: 'Today'),
                      const SizedBox(height: 8),
                      for (final item in today) ...[
                        _NotificationTile(
                          notification: item,
                          onTap: () => service.markRead(item),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                    if (earlier.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const _GroupLabel(label: 'Earlier'),
                      const SizedBox(height: 8),
                      for (final item in earlier) ...[
                        _NotificationTile(
                          notification: item,
                          onTap: () => service.markRead(item),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(label.toUpperCase(), style: overline),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.type) {
      AppNotificationType.promo => Icons.local_offer_outlined,
      AppNotificationType.order => Icons.receipt_long_outlined,
      AppNotificationType.stock => Icons.eco_outlined,
      AppNotificationType.delivery => Icons.local_shipping_outlined,
      AppNotificationType.tip => Icons.lightbulb_outline_rounded,
    };

    final (tint, iconColor) = switch (notification.type) {
      AppNotificationType.promo => (lime, forest),
      AppNotificationType.order => (tomatoSoft, tomato),
      AppNotificationType.stock => (goldSoft, const Color(0xFF8A5A00)),
      AppNotificationType.delivery => (lime, forest),
      AppNotificationType.tip => (sand, forest),
    };

    return Semantics(
      button: true,
      label:
          '${notification.title}. ${notification.message} '
          '${notification.timeLabel}. '
          '${notification.isRead ? 'Read' : 'Unread'}',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? surface
                  : lime.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: notification.isRead
                    ? line
                    : limeDeep.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
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
                              notification.title,
                              style: titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: tomato,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: bodySmall.copyWith(height: 1.45),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notification.timeLabel,
                        style: caption.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
