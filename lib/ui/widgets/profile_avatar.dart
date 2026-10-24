import 'package:flutter/material.dart';

import '../colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.imageAsset,
    this.semanticLabel = 'Profile photo',
  });

  final double size;
  final String? imageAsset;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: asset == null
            ? Semantics(
                image: true,
                label: semanticLabel,
                child: ColoredBox(
                  color: sand,
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: size * 0.62,
                      color: muted,
                    ),
                  ),
                ),
              )
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
              ),
      ),
    );
  }
}
