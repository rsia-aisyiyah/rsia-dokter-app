import 'dart:ui';

import 'package:flutter/material.dart';

class BlurWidget extends StatelessWidget {
  final Widget child;
  final bool applyBlur;

  BlurWidget({required this.child, this.applyBlur = true});

  @override
  Widget build(BuildContext context) {
    if (applyBlur) {
      return ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(tileMode: TileMode.decal, sigmaX: 3, sigmaY: 2),
          child: child,
        ),
      );
    } else {
      return child;
    }
  }
}
