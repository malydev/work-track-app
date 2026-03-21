import 'package:flutter/material.dart';

abstract final class UiSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xxl = 16;
  static const double section = 20;
  static const double screenTop = 24;
  static const double card = 18;
  static const double cardLg = 24;
  static const double cardXl = 28;
  static const double navBottom = 24;
  static const double pageBottomInset = 140;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    section,
    screenTop,
    section,
    pageBottomInset,
  );
  static const EdgeInsets navOuterPadding = EdgeInsets.fromLTRB(
    section,
    0,
    section,
    navBottom,
  );
  static const EdgeInsets navInnerPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  static const EdgeInsets navItemPadding = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(card);
  static const EdgeInsets cardLargePadding = EdgeInsets.all(cardLg);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: card);
}

abstract final class UiRadius {
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double card = 24;
  static const double panel = 28;
  static const double sheet = 30;
  static const double hero = 32;
  static const double circleAvatar = 88;
}

abstract final class UiMotion {
  static const Duration fast = Duration(milliseconds: 220);
}

abstract final class UiEffects {
  static const double navBlurSigma = 28;
  static const double navShadowBlur = 18;
  static const Offset navShadowOffset = Offset(0, 10);
  static const double navSurfaceAlpha = 0.80;
  static const double navBorderAlpha = 0.28;
  static const double navShadowAlpha = 0.04;
  static const double navSelectedAlpha = 0.18;
}
