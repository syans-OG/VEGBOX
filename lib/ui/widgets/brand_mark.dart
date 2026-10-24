import 'package:flutter/material.dart';

import '../colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 38,
    this.onDark = false,
    this.showWordmark = true,
  });

  final double size;
  final bool onDark;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? lime : forest,
        borderRadius: BorderRadius.circular(size * 0.29),
        boxShadow: onDark
            ? null
            : [
                BoxShadow(
                  color: forest.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: Icon(
        Icons.eco_rounded,
        size: size * 0.55,
        color: onDark ? forest : lime,
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          'vegbox',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.56,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1,
            color: onDark ? white : ink,
          ),
        ),
      ],
    );
  }
}
