import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Atura A on its own. Single-colour SVG, tinted to [color].
class AturaMark extends StatelessWidget {
  final double width;
  final Color color;
  const AturaMark({super.key, required this.width, required this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/branding/atura_mark.svg',
        width: width,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        excludeFromSemantics: true,
      );
}

/// The full "Atura" wordmark. It already starts with the A, so never put an [AturaMark] before it.
class AturaWordmark extends StatelessWidget {
  final double height;
  final Color color;
  const AturaWordmark({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/branding/atura_wordmark.svg',
        height: height,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'Atura',
      );
}
