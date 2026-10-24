import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

enum AppButtonVariant { solid, outline, soft }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.solid,
    this.expand = true,
    this.width,
    this.height = 54,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;
  final double? width;
  final double height;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final baseBackground = switch (variant) {
      AppButtonVariant.solid => backgroundColor ?? forest,
      AppButtonVariant.soft => backgroundColor ?? lime,
      AppButtonVariant.outline => backgroundColor ?? surface,
    };
    final baseForeground = switch (variant) {
      AppButtonVariant.solid => foregroundColor ?? white,
      AppButtonVariant.soft => foregroundColor ?? forest,
      AppButtonVariant.outline => foregroundColor ?? ink,
    };
    final buttonBackground = isEnabled
        ? baseBackground
        : (variant == AppButtonVariant.outline
              ? baseBackground
              : line.withValues(alpha: 0.55));
    final foreground = isEnabled ? baseForeground : muted;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isLoading ? '$label, loading' : label,
      onTap: isEnabled ? onPressed : null,
      excludeSemantics: true,
      child: Container(
        width: expand ? double.infinity : width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled && variant == AppButtonVariant.solid
              ? [
                  BoxShadow(
                    color: forest.withValues(alpha: 0.15),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: buttonBackground,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: variant == AppButtonVariant.outline
                ? const BorderSide(color: line)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      )
                    else if (icon != null)
                      Icon(icon, size: 19, color: foreground),
                    if (isLoading || icon != null) const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        isLoading ? 'Please wait…' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: button.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
