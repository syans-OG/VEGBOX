import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: lime,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: forest),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: h3),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: bodySmall),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 210,
                  child: AppButton(
                    label: actionLabel!,
                    onPressed: onAction,
                    icon: Icons.arrow_forward_rounded,
                    height: 50,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
