import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

const _snackBarDuration = Duration(seconds: 3);

class _SnackBarMessage {
  const _SnackBarMessage({
    required this.message,
    required this.width,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final double? width;
  final String? actionLabel;
  final VoidCallback? onAction;
}

final Map<ScaffoldMessengerState, Queue<_SnackBarMessage>> _queues = {};
final Set<ScaffoldMessengerState> _showing = {};

void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final width = MediaQuery.sizeOf(context).width > 600 ? 560.0 : null;
  final queue = _queues.putIfAbsent(messenger, () => Queue<_SnackBarMessage>());

  queue.add(
    _SnackBarMessage(
      message: message,
      width: width,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );

  if (!_showing.contains(messenger)) _showNext(messenger);
}

void _showNext(ScaffoldMessengerState messenger) {
  final queue = _queues[messenger];
  if (queue == null || queue.isEmpty) {
    _queues.remove(messenger);
    _showing.remove(messenger);
    return;
  }

  _showing.add(messenger);
  final next = queue.removeFirst();

  messenger.showSnackBar(
    SnackBar(
      width: next.width,
      behavior: SnackBarBehavior.floating,
      content: Text(next.message),
      action: next.actionLabel == null
          ? null
          : SnackBarAction(
              label: next.actionLabel!,
              textColor: const Color(0xFFDDF2B4),
              onPressed: next.onAction ?? () {},
            ),
      duration: _snackBarDuration,
    ),
  );

  Timer(_snackBarDuration, () {
    if (!messenger.mounted) {
      _queues.remove(messenger);
      _showing.remove(messenger);
      return;
    }
    messenger.hideCurrentSnackBar();
    _showNext(messenger);
  });
}
