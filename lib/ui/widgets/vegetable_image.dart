import 'package:flutter/material.dart';

import '../colors.dart';

class VegetableImage extends StatelessWidget {
  const VegetableImage({
    super.key,
    this.asset,
    this.url,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String? asset;
  final String? url;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: sand,
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 34,
          color: leaf.withValues(alpha: 0.45),
        ),
      ),
    );

    Widget networkImage() {
      final imageUrl = url;
      if (imageUrl == null || imageUrl.isEmpty) return placeholder;
      return Image.network(
        imageUrl,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder;
        },
      );
    }

    final imageAsset = asset;
    if (imageAsset == null || imageAsset.isEmpty) return networkImage();

    return Image.asset(
      imageAsset,
      fit: fit,
      semanticLabel: semanticLabel,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => networkImage(),
    );
  }
}
