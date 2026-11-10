import 'package:flutter/material.dart';

/// Paints [color] behind [child] when it's set, and adjusts the theme below it so the
/// default text, icons, dividers and sheets stay readable on that color.
class CourierBackground extends StatelessWidget {
  final Color? color;
  final Widget child;

  const CourierBackground({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    if (color == null) return child;
    return Theme(
      data: courierThemeForBackground(Theme.of(context), color),
      child: ColoredBox(color: color, child: child),
    );
  }
}

/// [base] with [background] as the surface color. When [background] is dark in a light theme,
/// or light in a dark theme, the default foreground colors switch to white or black.
ThemeData courierThemeForBackground(ThemeData base, Color background) {
  final brightness = ThemeData.estimateBrightnessForColor(background);

  final theme = base.copyWith(
    scaffoldBackgroundColor: background,
    canvasColor: background,
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: background,
      modalBackgroundColor: background,
    ),
  );

  if (brightness == base.brightness) return theme;

  final foreground = brightness == Brightness.dark ? Colors.white : Colors.black;

  return theme.copyWith(
    // Resolve the accent before the brightness changes
    primaryColor: base.courierAccentColor,
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      surface: background,
      onSurface: foreground,
      onSurfaceVariant: foreground.withValues(alpha: 0.7),
      outline: foreground.withValues(alpha: 0.5),
      outlineVariant: foreground.withValues(alpha: 0.12),
    ),
    textTheme: base.textTheme.apply(bodyColor: foreground, displayColor: foreground),
    iconTheme: base.iconTheme.copyWith(color: foreground),
    dividerColor: foreground.withValues(alpha: 0.12),
  );
}

extension CourierThemeColors on ThemeData {
  /// The color the SDK uses for indicators and loading spinners when no theme or brand sets one.
  ///
  /// That's [primaryColor], except in a Material dark theme that doesn't set it. There it
  /// defaults to the surface color, which can't be seen on the background, so this uses
  /// [ColorScheme.primary] instead.
  Color get courierAccentColor => primaryColor == colorScheme.surface ? colorScheme.primary : primaryColor;
}

/// [style] on top of [base], so a style that leaves fields out keeps the default's values for
/// them instead of falling back to the surrounding text style.
TextStyle? mergeCourierTextStyle(TextStyle? base, TextStyle? style) {
  if (style == null) return base;
  return base?.merge(style) ?? style;
}
